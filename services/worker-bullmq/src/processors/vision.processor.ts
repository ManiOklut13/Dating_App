/**
 * YoUnMe Worker — Google Cloud Vision Processor
 *
 * Handles VisionScanJob:
 *  1. Validates and authorises image_url (SSRF guard).
 *  2. Calls Vision API: SafeSearch + TEXT_DETECTION.
 *  3. Applies contact-detection to OCR output (mirrors Go/NestJS logic).
 *  4. Persists moderation outcome to Supabase `media_moderation` table.
 *  5. Returns a structured result that the BullMQ worker logs.
 *
 * Design rules:
 *  - Never logs raw image URLs or raw OCR text (privacy).
 *  - On transient Vision API errors → throws (BullMQ retries with backoff).
 *  - On permanent failures (bad URL, invalid image) → marks as blocked with
 *    status 'pending_review' so a human can decide.
 *  - Never auto-approves if Vision API fails.
 */

import vision from '@google-cloud/vision';
import type { ImageAnnotatorClient, protos } from '@google-cloud/vision';
import { z } from 'zod';
import { env, visionConfigured, supabaseConfigured } from '../config.js';
import { getSupabaseClient } from '../supabase.js';
import type { VisionScanJob, ModerationOutcome } from '../types.js';

// ─── Payload Validation ──────────────────────────────────────────────────────

export const VisionScanJobSchema = z.object({
  asset_id: z.string().uuid('asset_id must be a valid UUID'),
  user_id: z.string().uuid('user_id must be a valid UUID'),
  image_url: z.string().url('image_url must be a valid URL'),
  type: z.enum(['profile_photo', 'chat_media', 'video_call_preview']),
});

// ─── Safe-Search Likelihood mapping ─────────────────────────────────────────

type Likelihood = 'UNKNOWN' | 'VERY_UNLIKELY' | 'UNLIKELY' | 'POSSIBLE' | 'LIKELY' | 'VERY_LIKELY';

const LIKELIHOOD_NAMES: Record<number, Likelihood> = {
  0: 'UNKNOWN',
  1: 'VERY_UNLIKELY',
  2: 'UNLIKELY',
  3: 'POSSIBLE',
  4: 'LIKELY',
  5: 'VERY_LIKELY',
};

function normalizeLikelihood(val: unknown): Likelihood {
  if (typeof val === 'number') {
    return LIKELIHOOD_NAMES[val] ?? 'UNKNOWN';
  }
  if (typeof val === 'string') {
    return val as Likelihood;
  }
  return 'UNKNOWN';
}

const BLOCK_THRESHOLDS: Record<string, readonly Likelihood[]> = {
  adult: ['LIKELY', 'VERY_LIKELY'],
  racy: ['VERY_LIKELY'],
  violence: ['LIKELY', 'VERY_LIKELY'],
};

function exceedsThreshold(likelihood: unknown, category: string): boolean {
  const norm = normalizeLikelihood(likelihood);
  const thresholds = BLOCK_THRESHOLDS[category] ?? [];
  return thresholds.includes(norm);
}

// ─── OCR Contact Detection ────────────────────────────────────────────────────
// Mirror of the Go NormalizeText + phone/social regex logic.

const PHONE_DIGIT_REGEX = /\d{10,}/;
const PHONE_SPACED_REGEX = /\+?\d[\d\s\-().]{8,}\d/;
const SOCIAL_HANDLE_REGEX =
  /(insta|ig|telegram|snap|snapchat|t\.me|wa\.me|whatsapp|sc)\s*[:\s_-]*@?[a-zA-Z0-9_.]{3,}/i;

function detectContactInOcr(texts: string[]): boolean {
  for (const text of texts) {
    const digitsOnly = text.replace(/\D/g, '');
    if (PHONE_DIGIT_REGEX.test(digitsOnly)) return true;
    if (PHONE_SPACED_REGEX.test(text)) return true;
    if (SOCIAL_HANDLE_REGEX.test(text)) return true;
  }
  return false;
}

// ─── URL Allowlist Guard (SSRF prevention) ────────────────────────────────────

function isAllowedImageUrl(url: string): boolean {
  if (!env.SUPABASE_STORAGE_BUCKET_PREFIX) {
    // In production, never accept arbitrary HTTPS URLs when bucket prefix is omitted.
    if (env.NODE_ENV === 'production') {
      if (env.SUPABASE_URL) {
        const storageBase = `${env.SUPABASE_URL.replace(/\/+$/, '')}/storage/v1/object/`;
        return url.startsWith(storageBase);
      }
      return false;
    }
    // In development/test, allow HTTPS URLs when no bucket prefix is set.
    return url.startsWith('https://');
  }
  return url.startsWith(env.SUPABASE_STORAGE_BUCKET_PREFIX);
}

// ─── Vision Client (lazy) ────────────────────────────────────────────────────

let _visionClient: ImageAnnotatorClient | null = null;

function getVisionClient(): ImageAnnotatorClient {
  if (_visionClient) return _visionClient;
  _visionClient = new vision.ImageAnnotatorClient({
    ...(env.GCLOUD_PROJECT_ID ? { projectId: env.GCLOUD_PROJECT_ID } : {}),
    // GOOGLE_APPLICATION_CREDENTIALS is read automatically from the environment.
  });
  return _visionClient;
}

// ─── Supabase Persistence ─────────────────────────────────────────────────────

async function persistOutcome(outcome: ModerationOutcome): Promise<void> {
  const supabase = getSupabaseClient();
  if (!supabase) {
    // No Supabase client in dev/test — log only.
    console.log(
      `[Vision] Supabase not configured. Outcome for asset ${outcome.asset_id}: ${outcome.status}`,
    );
    return;
  }

  const { error } = await supabase.from('media_moderation').upsert(
    {
      asset_id: outcome.asset_id,
      user_id: outcome.user_id,
      status: outcome.status,
      safe_search_adult: outcome.safe_search_adult,
      safe_search_racy: outcome.safe_search_racy,
      safe_search_violence: outcome.safe_search_violence,
      contact_detected: outcome.contact_detected,
      action_taken: outcome.action_taken,
      reviewed_at: outcome.reviewed_at,
    },
    { onConflict: 'asset_id' }, // idempotent upsert
  );

  if (error) {
    // Surface to BullMQ for retry if it's a transient DB error.
    throw new Error(`[Vision] Failed to persist moderation outcome: ${error.message}`);
  }
}

// ─── Main Processor ──────────────────────────────────────────────────────────

export async function processVisionScan(rawJob: unknown): Promise<ModerationOutcome> {
  // 1. Validate payload
  const parseResult = VisionScanJobSchema.safeParse(rawJob);
  if (!parseResult.success) {
    const issues = parseResult.error.issues.map((i) => i.message).join('; ');
    throw new Error(`[Vision] Invalid job payload: ${issues}`);
  }
  const job: VisionScanJob = parseResult.data;

  // 2. SSRF guard: validate image URL is within approved storage
  if (!isAllowedImageUrl(job.image_url)) {
    const outcome: ModerationOutcome = {
      asset_id: job.asset_id,
      user_id: job.user_id,
      status: 'blocked',
      safe_search_adult: 'UNKNOWN',
      safe_search_racy: 'UNKNOWN',
      safe_search_violence: 'UNKNOWN',
      contact_detected: false,
      action_taken: 'REJECTED_DISALLOWED_URL',
      reviewed_at: new Date().toISOString(),
    };
    await persistOutcome(outcome);
    return outcome;
  }

  // 3. If Vision API not configured, mark pending_review (do NOT auto-approve)
  if (!visionConfigured) {
    console.warn(
      `[Vision] Google Cloud credentials not configured. ` +
        `Marking asset ${job.asset_id} as pending_review. ` +
        `Set GOOGLE_APPLICATION_CREDENTIALS or GCLOUD_PROJECT_ID to enable real scanning.`,
    );
    const outcome: ModerationOutcome = {
      asset_id: job.asset_id,
      user_id: job.user_id,
      status: 'pending_review',
      safe_search_adult: 'UNKNOWN',
      safe_search_racy: 'UNKNOWN',
      safe_search_violence: 'UNKNOWN',
      contact_detected: false,
      action_taken: 'PENDING_VISION_NOT_CONFIGURED',
      reviewed_at: new Date().toISOString(),
    };
    await persistOutcome(outcome);
    return outcome;
  }

  // 4. Call Google Cloud Vision API
  let safeSearchAnnotation: protos.google.cloud.vision.v1.ISafeSearchAnnotation | null = null;
  let ocrTexts: string[] = [];

  try {
    const client = getVisionClient();
    const [response] = await client.annotateImage({
      image: { source: { imageUri: job.image_url } },
      features: [
        { type: 'SAFE_SEARCH_DETECTION' },
        { type: 'TEXT_DETECTION' },
      ],
    });

    safeSearchAnnotation = response.safeSearchAnnotation ?? null;
    ocrTexts = (response.textAnnotations ?? [])
      .slice(0, 1) // first annotation is the full-image text block
      .map((a: protos.google.cloud.vision.v1.IEntityAnnotation) => a.description ?? '');
  } catch (err: unknown) {
    // Transient Vision API error — rethrow so BullMQ retries with backoff
    const msg = err instanceof Error ? err.message : String(err);
    throw new Error(`[Vision] Transient Vision API error (will retry): ${msg}`);
  }

  // 5. Apply moderation rules
  const adult = normalizeLikelihood(safeSearchAnnotation?.adult);
  const racy = normalizeLikelihood(safeSearchAnnotation?.racy);
  const violence = normalizeLikelihood(safeSearchAnnotation?.violence);

  const isExplicit =
    exceedsThreshold(adult, 'adult') ||
    exceedsThreshold(racy, 'racy') ||
    exceedsThreshold(violence, 'violence');

  const contactDetected = detectContactInOcr(ocrTexts);

  let status: ModerationOutcome['status'];
  let actionTaken: string;

  if (isExplicit) {
    status = 'blocked';
    actionTaken = 'BLOCKED_EXPLICIT_CONTENT';
  } else if (contactDetected) {
    status = 'blocked';
    actionTaken = 'BLOCKED_OCR_CONTACT_DETECTED';
  } else {
    status = 'approved';
    actionTaken = 'APPROVED';
  }

  const outcome: ModerationOutcome = {
    asset_id: job.asset_id,
    user_id: job.user_id,
    status,
    safe_search_adult: adult,
    safe_search_racy: racy,
    safe_search_violence: violence,
    contact_detected: contactDetected,
    action_taken: actionTaken,
    reviewed_at: new Date().toISOString(),
  };

  // 6. Persist (idempotent upsert)
  await persistOutcome(outcome);

  // Log only non-sensitive summary (no URLs, no OCR text)
  console.log(
    `[Vision] asset=${job.asset_id} type=${job.type} ` +
      `status=${status} action=${actionTaken}`,
  );

  return outcome;
}
