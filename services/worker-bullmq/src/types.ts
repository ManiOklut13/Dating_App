/**
 * YoUnMe Worker — Queue Names & Job Payload Contracts
 *
 * This file is the single source of truth for queue names and payload shapes.
 * Both the NestJS producer and this worker must agree on these contracts.
 *
 * Queue names follow the format: "younme:<domain>"
 */

// ─── Queue Names ────────────────────────────────────────────────────────────

export const QUEUE_VISION_SCAN = 'younme:vision-scan';
export const QUEUE_NOTIFICATION = 'younme:notification';
export const QUEUE_CONTACT_GUARD_AUDIT = 'younme:contact-guard-audit';
export const QUEUE_PUSH_DELIVERY = 'younme:push-delivery';

// ─── Job Payload Interfaces ──────────────────────────────────────────────────

/**
 * Enqueued by NestJS when a user uploads media (profile photo, chat image,
 * or a video-call thumbnail capture). The worker fetches the image from
 * Supabase Storage, calls Vision API, and persists the result.
 */
export interface VisionScanJob {
  /** UUID of the stored asset record (used for idempotency) */
  asset_id: string;
  /** UUID of the owning user */
  user_id: string;
  /**
   * Full Supabase Storage URL.
   * The worker validates this is within the expected bucket before fetching.
   */
  image_url: string;
  /** Context for the moderation decision */
  type: 'profile_photo' | 'chat_media' | 'video_call_preview';
}

/**
 * Moderation verdict persisted after Vision scan.
 * Written to the `media_moderation` table via the Supabase service role.
 */
export interface ModerationOutcome {
  asset_id: string;
  user_id: string;
  status: 'approved' | 'blocked' | 'pending_review';
  safe_search_adult: string;
  safe_search_racy: string;
  safe_search_violence: string;
  /** True when OCR detected suspicious contact information */
  contact_detected: boolean;
  action_taken: string;
  reviewed_at: string;
}

/**
 * Enqueued by NestJS for in-app notification persistence.
 * Once persisted to Supabase, this job triggers push delivery to the
 * `younme:push-delivery` queue for mobile client delivery via FCM.
 */
export interface NotificationJob {
  /** UUID of the receiving user */
  recipient_id: string;
  /** Notification category; used to route to the correct delivery channel */
  category: 'match' | 'message' | 'call' | 'system';
  title: string;
  body: string;
  /** Arbitrary extra data forwarded to the Flutter client */
  data: Record<string, string>;
}

/**
 * Result returned by the notification processor.
 */
export interface NotificationResult {
  recipient_id: string;
  notification_id: string | null;
  in_app_delivered: boolean;
  push_enqueued: boolean;
}

/**
 * Enqueued to deliver native mobile push notifications via Firebase Cloud Messaging.
 * Triggered automatically by the notification processor or directly for real-time alerts.
 */
export interface PushDeliveryJob {
  /** UUID of the receiving user */
  recipient_id: string;
  /** Notification category */
  category: 'match' | 'message' | 'call' | 'system';
  title: string;
  body: string;
  /** Custom data payload passed to the Flutter app */
  data?: Record<string, string>;
  /** Optional reference to the in-app notification row in Supabase */
  notification_id?: string;
}

/**
 * Result returned by the push delivery processor.
 */
export interface PushDeliveryResult {
  recipient_id: string;
  delivered_count: number;
  failed_count: number;
  pruned_tokens: number;
  reason?: string;
}

/**
 * Enqueued by NestJS when the REST Contact Guard flags a message as a
 * violation. The worker persists an auditable strike record.
 *
 * Note: Real-time blocking happens in Go and NestJS; the worker only writes
 * the audit trail so the violation cannot be lost on process restart.
 */
export interface ContactGuardAuditJob {
  /** UUID of the user who sent the blocked message */
  user_id: string;
  /** UUID of the conversation (matches.id) */
  conversation_id: string;
  /** Category of the detected violation */
  detected_type: 'phone_number' | 'social_handle' | 'external_url';
  /**
   * Normalised (homoglyph-resolved) excerpt — must NOT contain raw phone
   * numbers or personal data. The NestJS producer is responsible for
   * stripping sensitive content before enqueueing.
   */
  normalised_excerpt: string;
  /** BullMQ job ID of the originating request — used to prevent duplicate strikes */
  idempotency_key: string;
}
