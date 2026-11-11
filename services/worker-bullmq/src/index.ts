/**
 * YoUnMe Worker — Main Worker Entry Point
 *
 * Registers BullMQ workers for all supported job queues:
 *   - younme:vision-scan       → Vision API moderation
 *   - younme:notification      → In-app notification persistence
 *   - younme:contact-guard-audit → Contact Guard violation audit trail
 *
 * Features:
 *  - Single IORedis connection shared across all workers (no per-worker connections)
 *  - Exponential backoff on all queues
 *  - QueueEvents listener for failed-job observability
 *  - Graceful shutdown on SIGTERM / SIGINT (Cloud Run termination signal)
 *  - Worker stays alive after processing (suitable for Cloud Run always-on or min-instances=1)
 */

import http from 'node:http';
import { Worker, QueueEvents, type Job } from 'bullmq';
import IORedis from 'ioredis';
import { env, fcmConfigured, visionConfigured, supabaseConfigured } from './config.js';
import { closeProducerQueues } from './queue-producer.js';
import {
  QUEUE_VISION_SCAN,
  QUEUE_NOTIFICATION,
  QUEUE_CONTACT_GUARD_AUDIT,
  QUEUE_PUSH_DELIVERY,
} from './types.js';
import { processVisionScan } from './processors/vision.processor.js';
import { processNotification } from './processors/notification.processor.js';
import { processContactGuardAudit } from './processors/contact-guard.processor.js';
import { processPushDelivery } from './processors/push-delivery.processor.js';

// ─── Redis Connection ─────────────────────────────────────────────────────────

const connection = new IORedis(env.REDIS_URL, {
  maxRetriesPerRequest: null, // required by BullMQ
  enableReadyCheck: false,
  lazyConnect: false,
  retryStrategy(times) {
    const delay = Math.min(times * 500, 10_000); // max 10s between retries
    console.warn(`[Worker] Redis reconnect attempt #${times}, waiting ${delay}ms`);
    return delay;
  },
});

connection.on('connect', () => console.log('[Worker] Redis connected.'));
connection.on('error', (err) => console.error('[Worker] Redis error:', err.message));

// ─── Generic Job Runner ───────────────────────────────────────────────────────

async function runJob<T>(
  job: Job,
  processor: (data: unknown) => Promise<T>,
  label: string,
): Promise<T> {
  const start = Date.now();
  console.log(`[Worker] ▶ job_id=${job.id} queue=${job.queueName} attempt=${job.attemptsMade + 1}`);

  try {
    const result = await processor(job.data);
    const ms = Date.now() - start;
    console.log(`[Worker] ✅ job_id=${job.id} queue=${label} duration=${ms}ms`);
    return result;
  } catch (err) {
    const ms = Date.now() - start;
    const msg = err instanceof Error ? err.message : String(err);
    console.error(
      `[Worker] ❌ job_id=${job.id} queue=${label} attempt=${job.attemptsMade + 1} ` +
        `duration=${ms}ms error="${msg}"`,
    );
    throw err; // rethrow so BullMQ applies retry/backoff
  }
}

// ─── Queue Workers ────────────────────────────────────────────────────────────

const visionWorker = new Worker(
  QUEUE_VISION_SCAN,
  (job) => runJob(job, processVisionScan, 'vision-scan'),
  {
    connection,
    concurrency: env.WORKER_CONCURRENCY,
  },
);

const notificationWorker = new Worker(
  QUEUE_NOTIFICATION,
  (job) => runJob(job, processNotification, 'notification'),
  {
    connection,
    concurrency: env.WORKER_CONCURRENCY,
  },
);

const contactGuardWorker = new Worker(
  QUEUE_CONTACT_GUARD_AUDIT,
  (job) => runJob(job, processContactGuardAudit, 'contact-guard-audit'),
  {
    connection,
    concurrency: env.WORKER_CONCURRENCY,
  },
);

const pushDeliveryWorker = new Worker(
  QUEUE_PUSH_DELIVERY,
  (job) => runJob(job, processPushDelivery, 'push-delivery'),
  {
    connection,
    concurrency: env.WORKER_CONCURRENCY,
  },
);

const allWorkers = [visionWorker, notificationWorker, contactGuardWorker, pushDeliveryWorker];

// ─── QueueEvents — Failed Job Observability ───────────────────────────────────

const queueEvents: QueueEvents[] = [];

function attachQueueEvents(queueName: string): void {
  const events = new QueueEvents(queueName, { connection });
  events.on('failed', ({ jobId, failedReason }) => {
    console.error(
      `[Worker] ☠ PERMANENTLY FAILED job_id=${jobId} queue=${queueName} reason="${failedReason}"`,
    );
    // In production: send alert to Sentry / Cloud Logging / PagerDuty here.
  });
  events.on('stalled', ({ jobId }) => {
    console.warn(`[Worker] ⚠ STALLED job_id=${jobId} queue=${queueName} — will be retried`);
  });
  queueEvents.push(events);
}

[
  QUEUE_VISION_SCAN,
  QUEUE_NOTIFICATION,
  QUEUE_CONTACT_GUARD_AUDIT,
  QUEUE_PUSH_DELIVERY,
].forEach(attachQueueEvents);

// ─── Cloud Run HTTP Health Server ─────────────────────────────────────────────

let isShuttingDown = false;

const healthServer = http.createServer((req, res) => {
  if (req.url === '/health' || req.url === '/') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(
      JSON.stringify({
        status: isShuttingDown ? 'shutting_down' : 'healthy',
        service: 'younme-worker-bullmq',
        queues: [
          QUEUE_VISION_SCAN,
          QUEUE_NOTIFICATION,
          QUEUE_CONTACT_GUARD_AUDIT,
          QUEUE_PUSH_DELIVERY,
        ],
      }),
    );
    return;
  }
  res.writeHead(404, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({ error: 'Not Found' }));
});

healthServer.listen(env.PORT, () => {
  console.log(`[Worker] 🩺 Health endpoint listening on :${env.PORT}/health`);
});

// ─── Startup Banner ───────────────────────────────────────────────────────────

console.log('================================================================');
console.log('🔧 YoUnMe Background Worker v2.0 — Starting');
console.log(
  `📍 Queues: ${QUEUE_VISION_SCAN} | ${QUEUE_NOTIFICATION} | ` +
    `${QUEUE_CONTACT_GUARD_AUDIT} | ${QUEUE_PUSH_DELIVERY}`,
);
console.log(`🔗 Redis: ${env.REDIS_URL.replace(/:\/\/.*@/, '://<credentials>@')}`);
console.log(`⚙  Concurrency: ${env.WORKER_CONCURRENCY}`);
console.log(
  `🛡  Services: Supabase=${supabaseConfigured ? '✅' : '⚠️ disabled'} | ` +
    `Vision=${visionConfigured ? '✅' : '⚠️ disabled'} | ` +
    `FCM=${fcmConfigured ? '✅' : '⚠️ disabled'}`,
);
if (env.NODE_ENV === 'production' && !env.SUPABASE_STORAGE_BUCKET_PREFIX) {
  console.warn(
    '[Worker] ⚠ SUPABASE_STORAGE_BUCKET_PREFIX is not set in production; ' +
      'falling back to SUPABASE_URL storage path or rejecting untrusted URLs.',
  );
}
console.log('================================================================');

// ─── Graceful Shutdown ────────────────────────────────────────────────────────

async function shutdown(signal: string): Promise<void> {
  if (isShuttingDown) return;
  isShuttingDown = true;

  console.log(`\n[Worker] ${signal} received — graceful shutdown starting…`);

  // Stop accepting new HTTP health probes
  await new Promise<void>((resolve) => {
    healthServer.close(() => resolve());
  });

  // Close workers & QueueEvents (finish current jobs, reject new ones)
  await Promise.allSettled([
    ...allWorkers.map((w) => w.close()),
    ...queueEvents.map((e) => e.close()),
    closeProducerQueues(),
  ]);

  // Close Redis
  await connection.quit().catch(() => connection.disconnect());

  console.log('[Worker] Shutdown complete. Exiting.');
  process.exit(0);
}

process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));
process.on('uncaughtException', (err) => {
  console.error('[Worker] Uncaught exception:', err);
  shutdown('uncaughtException').catch(() => process.exit(1));
});
process.on('unhandledRejection', (reason) => {
  console.error('[Worker] Unhandled rejection:', reason);
});
