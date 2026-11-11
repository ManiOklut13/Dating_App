/**
 * YoUnMe Worker — Contact Guard Audit Processor
 *
 * Responsibility: Write an immutable, deduplicated audit record for every
 * Contact Guard violation that was blocked in the NestJS REST layer or the
 * Go real-time layer.
 *
 * This worker does NOT perform contact detection — that is the responsibility
 * of the NestJS chat.controller.ts and Go guard/link_guard.go which act
 * in-flight before message delivery. This processor only persists the audit
 * trail so violations survive process restarts and are queryable.
 *
 * Strike accumulation logic (suspension thresholds, cooldowns) lives in
 * the NestJS API layer where it is authoritative. This processor only writes
 * to the audit table.
 *
 * Idempotency: The `idempotency_key` field maps to a UNIQUE constraint on
 * `contact_guard_audits.idempotency_key`. A duplicate enqueue is silently
 * ignored (no double-strike).
 */

import { z } from 'zod';
import { getSupabaseClient } from '../supabase.js';

// ─── Payload Validation ──────────────────────────────────────────────────────

export const ContactGuardAuditJobSchema = z.object({
  user_id: z.string().uuid('user_id must be a valid UUID'),
  conversation_id: z.string().uuid('conversation_id must be a valid UUID'),
  detected_type: z.enum(['phone_number', 'social_handle', 'external_url']),
  /**
   * Normalised excerpt from the NestJS producer.
   * Must NOT contain raw phone numbers or personal data.
   * Max 200 chars enforced here as a safety net.
   */
  normalised_excerpt: z.string().max(200),
  idempotency_key: z.string().min(1).max(128),
});

export type ContactGuardAuditJob = z.infer<typeof ContactGuardAuditJobSchema>;

// ─── Result ──────────────────────────────────────────────────────────────────

export interface AuditResult {
  idempotency_key: string;
  duplicate: boolean;
  persisted: boolean;
}

// ─── Main Processor ──────────────────────────────────────────────────────────

export async function processContactGuardAudit(rawJob: unknown): Promise<AuditResult> {
  // 1. Validate payload
  const parseResult = ContactGuardAuditJobSchema.safeParse(rawJob);
  if (!parseResult.success) {
    const issues = parseResult.error.issues.map((i) => i.message).join('; ');
    throw new Error(`[ContactGuard] Invalid job payload: ${issues}`);
  }
  const job: ContactGuardAuditJob = parseResult.data;

  console.log(
    `[ContactGuard] Audit — user=${job.user_id} conv=${job.conversation_id} ` +
      `type=${job.detected_type} key=${job.idempotency_key}`,
  );

  const supabase = getSupabaseClient();

  if (!supabase) {
    // No Supabase in dev/test — log only
    console.log(
      `[ContactGuard] Supabase not configured. Audit record NOT persisted. ` +
        `key=${job.idempotency_key}`,
    );
    return { idempotency_key: job.idempotency_key, duplicate: false, persisted: false };
  }

  // 2. Check for existing record (idempotency)
  const { data: existing, error: selectError } = await supabase
    .from('contact_guard_audits')
    .select('idempotency_key')
    .eq('idempotency_key', job.idempotency_key)
    .maybeSingle();

  if (selectError) {
    throw new Error(`[ContactGuard] DB read error: ${selectError.message}`);
  }

  if (existing) {
    console.log(`[ContactGuard] Duplicate audit — key=${job.idempotency_key} ignored.`);
    return { idempotency_key: job.idempotency_key, duplicate: true, persisted: false };
  }

  // 3. Insert audit record
  const { error: insertError } = await supabase.from('contact_guard_audits').insert({
    user_id: job.user_id,
    conversation_id: job.conversation_id,
    detected_type: job.detected_type,
    normalised_excerpt: job.normalised_excerpt,
    idempotency_key: job.idempotency_key,
    created_at: new Date().toISOString(),
  });

  if (insertError) {
    // Unique constraint violation = race-condition duplicate → treat as idempotent
    if (insertError.code === '23505') {
      return { idempotency_key: job.idempotency_key, duplicate: true, persisted: false };
    }
    throw new Error(`[ContactGuard] DB insert error: ${insertError.message}`);
  }

  console.log(`[ContactGuard] Audit persisted — key=${job.idempotency_key}`);
  return { idempotency_key: job.idempotency_key, duplicate: false, persisted: true };
}
