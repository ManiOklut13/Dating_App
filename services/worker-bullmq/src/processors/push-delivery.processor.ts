/**
 * YoUnMe Worker — Firebase Cloud Messaging (FCM) Push Delivery Processor
 *
 * Responsibilities:
 *  1. Validates PushDeliveryJob payload.
 *  2. Looks up recipient's active device tokens from Supabase `device_tokens` table.
 *  3. Constructs privacy-preserving, categorized FCM push payloads.
 *  4. Dispatches multicast notifications using Firebase Admin SDK `sendEachForMulticast`.
 *  5. Automatically prunes unregistered or invalid tokens from Supabase.
 *  6. Distinguishes permanent errors from transient FCM server errors (for BullMQ retries).
 *
 * Security & Privacy:
 *  - Device registration tokens and private message bodies are NEVER logged.
 *  - Service account credentials remain strictly server-side.
 */

import { z } from 'zod';
import { getMessagingClient } from '../fcm.js';
import { getSupabaseClient } from '../supabase.js';
import type { PushDeliveryJob, PushDeliveryResult } from '../types.js';

// ─── Payload Validation ──────────────────────────────────────────────────────

export const PushDeliveryJobSchema = z.object({
  recipient_id: z.string().uuid('recipient_id must be a valid UUID'),
  category: z.enum(['match', 'message', 'call', 'system']),
  title: z.string().min(1).max(128),
  body: z.string().min(1).max(512),
  data: z.record(z.string()).default({}),
  notification_id: z.string().uuid().optional(),
});

// Stale token error codes defined by Firebase Cloud Messaging
const STALE_TOKEN_CODES = new Set([
  'messaging/registration-token-not-registered',
  'messaging/invalid-registration-token',
]);

// Transient error codes that warrant BullMQ backoff retry
const RETRYABLE_FCM_CODES = new Set([
  'messaging/server-unavailable',
  'messaging/internal-error',
  'messaging/quota-exceeded',
  'messaging/device-message-rate-exceeded',
]);

// ─── Main Processor ──────────────────────────────────────────────────────────

export async function processPushDelivery(rawJob: unknown): Promise<PushDeliveryResult> {
  // 1. Validate payload
  const parseResult = PushDeliveryJobSchema.safeParse(rawJob);
  if (!parseResult.success) {
    const issues = parseResult.error.issues.map((i) => i.message).join('; ');
    throw new Error(`[PushDelivery] Invalid job payload: ${issues}`);
  }
  const job: PushDeliveryJob = parseResult.data;

  console.log(
    `[PushDelivery] Processing — recipient=${job.recipient_id} category=${job.category}` +
      (job.notification_id ? ` notif_id=${job.notification_id}` : ''),
  );

  const supabase = getSupabaseClient();
  if (!supabase) {
    console.log(
      `[PushDelivery] Supabase not configured. Push delivery skipped. recipient=${job.recipient_id}`,
    );
    return {
      recipient_id: job.recipient_id,
      delivered_count: 0,
      failed_count: 0,
      pruned_tokens: 0,
      reason: 'supabase_not_configured',
    };
  }

  // 2. Query active device tokens for the recipient
  const { data: tokenRows, error: tokenError } = await supabase
    .from('device_tokens')
    .select('token, platform')
    .eq('user_id', job.recipient_id);

  if (tokenError) {
    throw new Error(`[PushDelivery] Failed to query device tokens: ${tokenError.message}`);
  }

  if (!tokenRows || tokenRows.length === 0) {
    console.log(
      `[PushDelivery] No registered device tokens for recipient=${job.recipient_id}. Skipping FCM dispatch.`,
    );
    return {
      recipient_id: job.recipient_id,
      delivered_count: 0,
      failed_count: 0,
      pruned_tokens: 0,
      reason: 'no_tokens',
    };
  }

  // 3. Obtain Firebase Messaging client
  const messaging = getMessagingClient();
  if (!messaging) {
    console.warn(
      `[PushDelivery] FCM not configured. Cannot dispatch push to ${tokenRows.length} device(s) ` +
        `for recipient=${job.recipient_id}. Set FIREBASE_SERVICE_ACCOUNT_KEY to enable.`,
    );
    return {
      recipient_id: job.recipient_id,
      delivered_count: 0,
      failed_count: 0,
      pruned_tokens: 0,
      reason: 'fcm_not_configured',
    };
  }

  // 4. Construct payload and dispatch multicast message
  const tokens = tokenRows.map((r) => r.token);
  const dataPayload: Record<string, string> = {
    ...job.data,
    category: job.category,
    ...(job.notification_id ? { notification_id: job.notification_id } : {}),
  };

  let response;
  try {
    response = await messaging.sendEachForMulticast({
      tokens,
      notification: {
        title: job.title,
        body: job.body,
      },
      data: dataPayload,
      android: {
        priority: job.category === 'call' ? 'high' : 'normal',
        notification: {
          channelId: `younme_${job.category}`,
        },
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
          },
        },
      },
    });
  } catch (err: unknown) {
    const msg = err instanceof Error ? err.message : String(err);
    throw new Error(`[PushDelivery] FCM multicast transport error (will retry): ${msg}`);
  }

  // 5. Evaluate response & prune invalid tokens
  const staleTokens: string[] = [];
  let retryableCount = 0;

  response.responses.forEach((res, idx) => {
    if (!res.success && res.error) {
      const code = res.error.code;
      if (STALE_TOKEN_CODES.has(code)) {
        staleTokens.push(tokens[idx]);
      } else if (RETRYABLE_FCM_CODES.has(code)) {
        retryableCount++;
      }
    }
  });

  // Prune stale tokens from Supabase asynchronously
  if (staleTokens.length > 0) {
    const { error: pruneError } = await supabase
      .from('device_tokens')
      .delete()
      .in('token', staleTokens);

    if (pruneError) {
      console.error(`[PushDelivery] Failed to prune stale tokens: ${pruneError.message}`);
    } else {
      console.log(
        `[PushDelivery] Pruned ${staleTokens.length} unregistered/invalid token(s) ` +
          `for recipient=${job.recipient_id}`,
      );
    }
  }

  console.log(
    `[PushDelivery] Dispatched — recipient=${job.recipient_id} ` +
      `success=${response.successCount} failure=${response.failureCount}`,
  );

  // If ALL targeted tokens failed and failures were retryable, trigger BullMQ backoff retry
  if (response.successCount === 0 && retryableCount > 0 && retryableCount === response.failureCount) {
    throw new Error(
      `[PushDelivery] All FCM targets experienced retryable provider errors (${retryableCount} failed)`,
    );
  }

  return {
    recipient_id: job.recipient_id,
    delivered_count: response.successCount,
    failed_count: response.failureCount,
    pruned_tokens: staleTokens.length,
  };
}

