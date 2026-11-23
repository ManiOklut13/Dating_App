/**
 * YoUnMe Worker — Queue Producer Tests
 *
 * Verifies BullMQ job options (especially custom jobId validation against the
 * real BullMQ Job.prototype.validateOptions check) and clean queue lifecycle.
 */

import { jest, describe, it, expect, beforeEach } from '@jest/globals';
import { createRequire } from 'node:module';

const require = createRequire(import.meta.url);
// Use CommonJS entry for synchronous validator reference check without Redis
const { Job } = require('../../node_modules/bullmq/dist/cjs/index.js') as {
  Job: {
    prototype: {
      validateOptions: (this: { name: string; opts: Record<string, unknown> }, jobData: { data: string }) => void;
    };
  };
};

// ─── Mock BullMQ & IORedis (no live Redis required) ───────────────────────────

const mockAdd = jest.fn<(name: string, data: unknown, opts?: Record<string, unknown>) => Promise<{ id: string | undefined }>>();
const mockQueueClose = jest.fn<() => Promise<void>>();
const mockRedisQuit = jest.fn<() => Promise<'OK'>>();
const mockRedisDisconnect = jest.fn<() => void>();

jest.unstable_mockModule('bullmq', () => ({
  Queue: jest.fn().mockImplementation(() => ({
    add: mockAdd,
    close: mockQueueClose,
  })),
}));

jest.unstable_mockModule('ioredis', () => ({
  default: jest.fn().mockImplementation(() => ({
    quit: mockRedisQuit,
    disconnect: mockRedisDisconnect,
  })),
}));

const {
  enqueueVisionScan,
  enqueueNotification,
  enqueueContactGuardAudit,
  enqueuePushDelivery,
  buildJobId,
  closeProducerQueues,
} = await import('../queue-producer.js');

function assertValidBullMqJobId(jobId: unknown, name = 'test-job'): void {
  expect(typeof jobId).toBe('string');
  expect(String(jobId)).not.toContain(':');
  Job.prototype.validateOptions.call(
    { name, opts: { jobId } },
    { data: '{}' },
  );
}

describe('queue-producer', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockQueueClose.mockResolvedValue();
    mockRedisQuit.mockResolvedValue('OK');
    mockAdd.mockImplementation(async (_name, _data, opts) => ({
      id: (opts?.jobId as string | undefined) ?? 'auto-1',
    }));
  });

  it('builds BullMQ-safe custom jobIds without colons', () => {
    const id = buildJobId('guard', 'evt:2026:abc');
    expect(id).toBe('guard_evt_2026_abc');
    assertValidBullMqJobId(id);
  });

  it('enqueues vision scan with a valid BullMQ jobId', async () => {
    const assetId = '00000000-0000-0000-0000-000000000001';
    const id = await enqueueVisionScan({
      asset_id: assetId,
      user_id: '00000000-0000-0000-0000-000000000002',
      image_url: 'https://storage.supabase.co/younme/photo.jpg',
      type: 'profile_photo',
    });

    expect(id).toBe(`vision_${assetId}`);
    const opts = mockAdd.mock.calls[0][2];
    assertValidBullMqJobId(opts?.jobId, 'vision-scan');
  });

  it('enqueues contact guard audit with a valid BullMQ jobId even if key has colons', async () => {
    const id = await enqueueContactGuardAudit({
      user_id: '00000000-0000-0000-0000-000000000001',
      conversation_id: '00000000-0000-0000-0000-000000000002',
      detected_type: 'phone_number',
      normalised_excerpt: 'redacted',
      idempotency_key: 'msg:123:blocked',
    });

    expect(id).toBe('guard_msg_123_blocked');
    const opts = mockAdd.mock.calls[0][2];
    assertValidBullMqJobId(opts?.jobId, 'contact-guard-audit');
  });

  it('enqueues push delivery with valid BullMQ jobId with and without notification_id', async () => {
    const notifId = '00000000-0000-0000-0000-000000000099';
    const idWithNotif = await enqueuePushDelivery({
      recipient_id: '00000000-0000-0000-0000-000000000001',
      category: 'match',
      title: 'Match',
      body: 'Body',
      notification_id: notifId,
    });
    expect(idWithNotif).toBe(`push_${notifId}`);
    assertValidBullMqJobId(mockAdd.mock.calls[0][2]?.jobId, 'push-delivery');

    const idWithoutNotif = await enqueuePushDelivery({
      recipient_id: '00000000-0000-0000-0000-000000000001',
      category: 'call',
      title: 'Call',
      body: 'Incoming call',
    });
    assertValidBullMqJobId(idWithoutNotif, 'push-delivery');
  });

  it('enqueues notification job and closes producer queues cleanly', async () => {
    const id = await enqueueNotification({
      recipient_id: '00000000-0000-0000-0000-000000000001',
      category: 'system',
      title: 'Notice',
      body: 'Hello',
      data: {},
    });
    expect(id).toBe('auto-1');

    await closeProducerQueues();
    expect(mockQueueClose).toHaveBeenCalledTimes(4);
    expect(mockRedisQuit).toHaveBeenCalledTimes(1);
  });
});

