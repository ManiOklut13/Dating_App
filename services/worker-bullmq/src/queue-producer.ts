/**
 * YoUnMe — BullMQ Queue Producer Helper for NestJS
 *
 * Import this module from any NestJS controller or service to enqueue jobs
 * to the background worker. This is the correct pattern for production.
 *
 * Usage in NestJS:
 *
 *   import { enqueueVisionScan, enqueueNotification } from '../../worker-bullmq/src/queue-producer.js';
 *
 *   // After user uploads a photo:
 *   await enqueueVisionScan({ asset_id, user_id, image_url, type: 'profile_photo' });
 *
 *   // After a match is created:
 *   await enqueueNotification({
 *     recipient_id: otherUserId,
 *     category: 'match',
 *     title: 'You have a new match! 🔥',
 *     body: 'Start a conversation now.',
 *     data: { match_id: matchId },
 *   });
 *
 * The producer uses the same Redis connection string as the worker.
 * In production both services point to the same Redis instance.
 */

import { Queue, type JobsOptions } from 'bullmq';
import IORedis from 'ioredis';
import {
  QUEUE_VISION_SCAN,
  QUEUE_NOTIFICATION,
  QUEUE_CONTACT_GUARD_AUDIT,
  QUEUE_PUSH_DELIVERY,
  type VisionScanJob,
  type NotificationJob,
  type ContactGuardAuditJob,
  type PushDeliveryJob,
} from './types.js';

// ─── Lazy Redis Connection & Queues for Producers ────────────────────────────

const REDIS_URL = process.env.REDIS_URL ?? 'redis://localhost:6379';

let producerConnection: IORedis | null = null;
let visionQueue: Queue | null = null;
let notificationQueue: Queue | null = null;
let contactGuardQueue: Queue | null = null;
let pushDeliveryQueue: Queue | null = null;

function getProducerConnection(): IORedis {
  if (!producerConnection) {
    producerConnection = new IORedis(REDIS_URL, {
      maxRetriesPerRequest: null,
      enableReadyCheck: false,
      lazyConnect: true,
    });
  }
  return producerConnection;
}

function getQueues() {
  const connection = getProducerConnection();
  visionQueue ??= new Queue(QUEUE_VISION_SCAN, { connection });
  notificationQueue ??= new Queue(QUEUE_NOTIFICATION, { connection });
  contactGuardQueue ??= new Queue(QUEUE_CONTACT_GUARD_AUDIT, { connection });
  pushDeliveryQueue ??= new Queue(QUEUE_PUSH_DELIVERY, { connection });
  return { visionQueue, notificationQueue, contactGuardQueue, pushDeliveryQueue };
}

/**
 * BullMQ v5 rejects custom jobIds containing `:` (unless 3-part legacy format).
 * Build collision-safe, colon-free custom jobIds for deduplication.
 */
export function buildJobId(prefix: string, ...parts: Array<string | number>): string {
  return [prefix, ...parts]
    .map((p) => String(p).replace(/:/g, '_'))
    .join('_');
}

/**
 * Close producer Queue instances and shared Redis connection cleanly during shutdown.
 */
export async function closeProducerQueues(): Promise<void> {
  const queues = [visionQueue, notificationQueue, contactGuardQueue, pushDeliveryQueue].filter(
    (q): q is Queue => q !== null,
  );
  visionQueue = null;
  notificationQueue = null;
  contactGuardQueue = null;
  pushDeliveryQueue = null;

  await Promise.allSettled(queues.map((q) => q.close()));

  if (producerConnection) {
    const conn = producerConnection;
    producerConnection = null;
    await conn.quit().catch(() => conn.disconnect());
  }
}

// ─── Default Job Options ──────────────────────────────────────────────────────

const defaultOpts: JobsOptions = {
  attempts: 4,
  backoff: { type: 'exponential', delay: 2000 },
  removeOnComplete: { age: 3600 }, // keep completed jobs for 1h for debugging
  removeOnFail: { age: 86400 },   // keep failed jobs for 24h for ops review
};

// ─── Producer Functions ───────────────────────────────────────────────────────

/**
 * Enqueue an image moderation job.
 * Call this immediately after a user uploads media to Supabase Storage.
 */
export async function enqueueVisionScan(job: VisionScanJob): Promise<string | undefined> {
  const { visionQueue: queue } = getQueues();
  const added = await queue.add('vision-scan', job, {
    ...defaultOpts,
    // asset_id as job ID ensures only one scan per asset (deduplication)
    jobId: buildJobId('vision', job.asset_id),
  });
  return added.id;
}

/**
 * Enqueue an in-app notification.
 * The worker persists the record to Supabase; Realtime delivers it to Flutter.
 */
export async function enqueueNotification(job: NotificationJob): Promise<string | undefined> {
  const { notificationQueue: queue } = getQueues();
  const added = await queue.add('notification', job, defaultOpts);
  return added.id;
}

/**
 * Enqueue a Contact Guard audit record.
 * Call this from chat.controller.ts when a message is blocked.
 * The `idempotency_key` must be unique per blocking event.
 */
export async function enqueueContactGuardAudit(
  job: ContactGuardAuditJob,
): Promise<string | undefined> {
  const { contactGuardQueue: queue } = getQueues();
  const added = await queue.add('contact-guard-audit', job, {
    ...defaultOpts,
    jobId: buildJobId('guard', job.idempotency_key), // BullMQ-level deduplication
  });
  return added.id;
}

/**
 * Enqueue a native mobile push notification via Firebase Cloud Messaging.
 * Call this directly for push notifications or let `processNotification` fan out automatically.
 */
export async function enqueuePushDelivery(
  job: PushDeliveryJob,
): Promise<string | undefined> {
  const { pushDeliveryQueue: queue } = getQueues();
  const added = await queue.add('push-delivery', job, {
    ...defaultOpts,
    attempts: 5, // extra retries for mobile push network resilience
    jobId: job.notification_id
      ? buildJobId('push', job.notification_id)
      : buildJobId('push', job.recipient_id, Date.now()),
  });
  return added.id;
}
