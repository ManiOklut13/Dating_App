/**
 * YoUnMe Worker — Notification Processor
 *
 * Handles NotificationJob:
 *  1. Persists an in-app notification record to Supabase `notifications` table
 *     (which Supabase Realtime broadcasts to connected Flutter clients).
 *  2. Enqueues native mobile push delivery to the `younme:push-delivery` queue
 *     via Firebase Cloud Messaging (FCM).
 *
 * Decoupled Architecture:
 *  - Failure isolation: In-app persistence is guaranteed even if Redis or FCM
 *    has transient delivery issues.
 *  - Independent retries: Push delivery retries in its own queue without
 *    re-inserting duplicate database rows.
 */

import { z } from 'zod';
import { getSupabaseClient } from '../supabase.js';
import { enqueuePushDelivery } from '../queue-producer.js';
import type { NotificationResult } from '../types.js';

// ─── Payload Validation ──────────────────────────────────────────────────────

export const NotificationJobSchema = z.object({
  recipient_id: z.string().uuid('recipient_id must be a valid UUID'),
  category: z.enum(['match', 'message', 'call', 'system']),
  title: z.string().min(1).max(128),
  body: z.string().min(1).max(512),
  data: z.record(z.string()).default({}),
});

export type NotificationJob = z.infer<typeof NotificationJobSchema>;

// ─── Main Processor ──────────────────────────────────────────────────────────

export async function processNotification(rawJob: unknown): Promise<NotificationResult> {
  // 1. Validate payload
  const parseResult = NotificationJobSchema.safeParse(rawJob);
  if (!parseResult.success) {
    const issues = parseResult.error.issues.map((i) => i.message).join('; ');
    throw new Error(`[Notification] Invalid job payload: ${issues}`);
  }
  const job: NotificationJob = parseResult.data;

  // Log category and recipient only — do NOT log body content (privacy)
  console.log(
    `[Notification] Processing — recipient=${job.recipient_id} category=${job.category}`,
  );

  const supabase = getSupabaseClient();

  if (!supabase) {
    console.log(
      `[Notification] Supabase not configured. Notification NOT persisted. ` +
        `recipient=${job.recipient_id}`,
    );
    return {
      recipient_id: job.recipient_id,
      notification_id: null,
      in_app_delivered: false,
      push_enqueued: false,
    };
  }

  // 2. Persist in-app notification (Realtime will broadcast to connected client)
  const { data, error } = await supabase
    .from('notifications')
    .insert({
      recipient_id: job.recipient_id,
      category: job.category,
      title: job.title,
      body: job.body,
      data: job.data,
      is_read: false,
      created_at: new Date().toISOString(),
    })
    .select('id')
    .single();

  if (error) {
    throw new Error(`[Notification] DB insert error: ${error.message}`);
  }

  const notificationId: string | undefined =
    typeof data?.id === 'string' && data.id.length > 0 ? data.id : undefined;

  console.log(
    `[Notification] Persisted — id=${notificationId ?? 'unknown'} recipient=${job.recipient_id} ` +
      `category=${job.category}`,
  );

  // 3. Enqueue native push delivery to the push-delivery queue
  let pushEnqueued = false;
  try {
    await enqueuePushDelivery({
      recipient_id: job.recipient_id,
      category: job.category,
      title: job.title,
      body: job.body,
      data: job.data,
      ...(notificationId ? { notification_id: notificationId } : {}),
    });
    pushEnqueued = true;
    console.log(
      `[Notification] Enqueued push delivery — recipient=${job.recipient_id} notif_id=${notificationId ?? 'none'}`,
    );
  } catch (pushErr: unknown) {
    const msg = pushErr instanceof Error ? pushErr.message : String(pushErr);
    console.warn(
      `[Notification] Failed to enqueue push delivery for recipient=${job.recipient_id}: ${msg}`,
    );
  }

  return {
    recipient_id: job.recipient_id,
    notification_id: notificationId ?? null,
    in_app_delivered: true,
    push_enqueued: pushEnqueued,
  };
}
