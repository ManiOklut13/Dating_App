/**
 * YoUnMe Worker — Environment Configuration
 *
 * All secrets come from environment variables. Never hardcode credentials.
 * Fails fast at startup with clear error messages if required vars are absent.
 */

import { z } from 'zod';

const envSchema = z.object({
  // ── Redis ────────────────────────────────────────────────────────────────
  REDIS_URL: z
    .string()
    .url('REDIS_URL must be a valid URL, e.g. redis://localhost:6379')
    .default('redis://localhost:6379'),

  // ── Supabase ─────────────────────────────────────────────────────────────
  SUPABASE_URL: z.string().url('SUPABASE_URL must be a valid URL').optional(),
  /**
   * Service-role key — grants privileged write access.
   * Keep strictly server-side. Never expose to clients.
   */
  SUPABASE_SERVICE_ROLE_KEY: z
    .string()
    .min(1, 'SUPABASE_SERVICE_ROLE_KEY must not be empty')
    .optional(),

  // ── Google Cloud Vision ──────────────────────────────────────────────────
  /**
   * Path to a Google Cloud service-account JSON key file.
   * Alternatively, set GOOGLE_APPLICATION_CREDENTIALS in the environment.
   * When deployed to Cloud Run with Workload Identity, omit this variable
   * and assign the Vision API role to the Cloud Run service account instead.
   */
  GOOGLE_APPLICATION_CREDENTIALS: z.string().optional(),
  GCLOUD_PROJECT_ID: z.string().optional(),

  // ── Supabase Storage Bucket ──────────────────────────────────────────────
  /**
   * Allowed Supabase Storage bucket URL prefix.
   * The worker rejects any image_url that does not start with this value,
   * preventing server-side request forgery via enqueued jobs.
   */
  SUPABASE_STORAGE_BUCKET_PREFIX: z.string().optional(),

  // ── Firebase Cloud Messaging (FCM) ──────────────────────────────────────
  /**
   * Firebase Service Account Key as a JSON string, base64-encoded string,
   * or path to a credentials file. In Cloud Run with Workload Identity,
   * this can be omitted if GOOGLE_APPLICATION_CREDENTIALS or ADC is present.
   */
  FIREBASE_SERVICE_ACCOUNT_KEY: z.string().optional(),
  FIREBASE_PROJECT_ID: z.string().optional(),

  // ── Worker Tuning ────────────────────────────────────────────────────────
  /** Number of jobs processed concurrently per queue. Default: 3 */
  WORKER_CONCURRENCY: z.coerce.number().int().positive().default(3),
  /** Maximum Vision API retries before a job moves to failed state */
  VISION_MAX_RETRIES: z.coerce.number().int().nonnegative().default(3),
  /** Maximum FCM Push Delivery retries before moving to failed state */
  PUSH_MAX_RETRIES: z.coerce.number().int().nonnegative().default(3),
  /** HTTP health-check port for Cloud Run startup/liveness probes */
  PORT: z.coerce.number().int().positive().default(8082),

  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
});

type Env = z.infer<typeof envSchema>;

function loadEnv(): Env {
  const parsed = envSchema.safeParse(process.env);
  if (!parsed.success) {
    const issues = parsed.error.issues
      .map((i) => `  • ${i.path.join('.')}: ${i.message}`)
      .join('\n');
    console.error(`[Worker] ❌ Invalid environment configuration:\n${issues}`);
    process.exit(1);
  }
  return parsed.data;
}

export const env = loadEnv();

/** True when Supabase credentials are fully configured */
export const supabaseConfigured =
  Boolean(env.SUPABASE_URL) && Boolean(env.SUPABASE_SERVICE_ROLE_KEY);

/** True when Google Cloud Vision is likely configured */
export const visionConfigured = Boolean(
  env.GOOGLE_APPLICATION_CREDENTIALS || env.GCLOUD_PROJECT_ID || process.env.K_SERVICE,
);

/** True when Firebase Cloud Messaging is likely configured */
export const fcmConfigured = Boolean(
  env.FIREBASE_SERVICE_ACCOUNT_KEY ||
  env.FIREBASE_PROJECT_ID ||
  env.GOOGLE_APPLICATION_CREDENTIALS,
);
