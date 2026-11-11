/**
 * YoUnMe Dating App — Backward-Compatibility Re-export
 *
 * IMPORTANT — ARCHITECTURAL NOTE:
 *   The NestJS server.ts currently imports `workerService` from this file and
 *   calls it inline. This was a development shortcut. The worker is now a
 *   proper standalone BullMQ process (src/index.ts) and should NOT run inside
 *   NestJS in production.
 *
 *   This file provides a no-op shim so that the existing server.ts import
 *   does not break. The workerService.start() call in server.ts becomes a
 *   harmless log statement.
 *
 *   Production path:
 *     NestJS → enqueues jobs to Redis → Worker process consumes them.
 *     See src/queue-producer.ts for the NestJS-side job enqueuing helper.
 *
 * @deprecated This shim will be removed once server.ts is updated to use
 *             the queue producer pattern.
 */

export type { VisionScanJob, PushNotificationJob } from './types-compat.js';

class BackgroundWorkerShim {
  public start(): void {
    console.log(
      '[Worker Shim] ⚠  workerService.start() called inside NestJS. ' +
        'In production, run the worker as a separate process: npm run dev (in worker-bullmq). ' +
        'The actual BullMQ workers are in src/index.ts.',
    );
  }

  /** @deprecated Use BullMQ queue producer in src/queue-producer.ts instead */
  public async processVisionScan(job: unknown): Promise<{
    passed: boolean;
    safe_search: { adult: string; racy: string; violence: string };
    detected_text: string[];
    action_taken: string;
  }> {
    console.warn(
      '[Worker Shim] processVisionScan() called inline inside NestJS. ' +
        'Enqueue a VisionScanJob to the BullMQ queue instead.',
    );
    // Return a safe pending_review status — never auto-approve
    return {
      passed: false,
      safe_search: { adult: 'UNKNOWN', racy: 'UNKNOWN', violence: 'UNKNOWN' },
      detected_text: [],
      action_taken: 'PENDING_REVIEW_ENQUEUE_VIA_BULLMQ',
    };
  }
}

export const workerService = new BackgroundWorkerShim();

// Re-export queue names and types for NestJS producer usage
export {
  QUEUE_VISION_SCAN,
  QUEUE_NOTIFICATION,
  QUEUE_CONTACT_GUARD_AUDIT,
  QUEUE_PUSH_DELIVERY,
} from './types.js';
export type {
  VisionScanJob as VisionScanJobType,
  NotificationJob,
  ContactGuardAuditJob,
  PushDeliveryJob,
} from './types.js';
