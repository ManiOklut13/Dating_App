/**
 * YoUnMe Worker — Notification Processor Tests
 *
 * Uses jest.unstable_mockModule for proper ESM mocking.
 */

import { jest, describe, it, expect, beforeEach } from '@jest/globals';

// ─── Mock Supabase (must be before import of the processor) ──────────────────

const mockSingle = jest.fn<() => Promise<any>>();
const mockSelectChain = jest.fn(() => ({ single: mockSingle }));
const mockInsert = jest.fn(() => ({ select: mockSelectChain }));

const mockSupabaseFrom = jest.fn(() => ({ insert: mockInsert }));

jest.unstable_mockModule('../supabase.js', () => ({
  getSupabaseClient: () => ({ from: mockSupabaseFrom }),
}));

// ─── Mock Queue Producer ──────────────────────────────────────────────────────

const mockEnqueuePushDelivery = jest.fn<() => Promise<any>>();

jest.unstable_mockModule('../queue-producer.js', () => ({
  enqueuePushDelivery: mockEnqueuePushDelivery,
}));

// ─── Import after mocks ───────────────────────────────────────────────────────

const { processNotification } = await import('../processors/notification.processor.js');

// ─── Helpers ──────────────────────────────────────────────────────────────────

const VALID_JOB = {
  recipient_id: '00000000-0000-0000-0000-000000000001',
  category: 'match' as const,
  title: 'You have a new match! 🔥',
  body: 'Start a conversation now.',
  data: { match_id: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa' },
};

// ─── Tests ────────────────────────────────────────────────────────────────────

describe('processNotification', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockSupabaseFrom.mockReturnValue({ insert: mockInsert });
    mockInsert.mockReturnValue({ select: mockSelectChain });
    mockSelectChain.mockReturnValue({ single: mockSingle });
    mockEnqueuePushDelivery.mockResolvedValue('push-job-123');
  });

  it('persists notification and enqueues native push delivery', async () => {
    mockSingle.mockResolvedValueOnce({ data: { id: 'notif-uuid-001' }, error: null });

    const result = await processNotification(VALID_JOB);
    expect(result.in_app_delivered).toBe(true);
    expect(result.notification_id).toBe('notif-uuid-001');
    expect(result.push_enqueued).toBe(true);
    expect(mockInsert).toHaveBeenCalledTimes(1);
    expect(mockEnqueuePushDelivery).toHaveBeenCalledWith(
      expect.objectContaining({
        recipient_id: VALID_JOB.recipient_id,
        category: 'match',
        title: VALID_JOB.title,
        body: VALID_JOB.body,
        notification_id: 'notif-uuid-001',
      }),
    );
  });

  it('preserves in-app persistence even if push enqueue fails', async () => {
    mockSingle.mockResolvedValueOnce({ data: { id: 'notif-uuid-002' }, error: null });
    mockEnqueuePushDelivery.mockRejectedValueOnce(new Error('Redis connection refused'));

    const result = await processNotification(VALID_JOB);
    expect(result.in_app_delivered).toBe(true);
    expect(result.notification_id).toBe('notif-uuid-002');
    expect(result.push_enqueued).toBe(false);
  });

  it('throws on DB error so BullMQ can retry', async () => {
    mockSingle.mockResolvedValueOnce({ data: null, error: { message: 'db error' } });

    await expect(processNotification(VALID_JOB)).rejects.toThrow(/DB insert error/);
    expect(mockEnqueuePushDelivery).not.toHaveBeenCalled();
  });

  it('rejects invalid payload — bad UUID', async () => {
    await expect(processNotification({ recipient_id: 'bad-uuid' })).rejects.toThrow(
      /Invalid job payload/,
    );
  });

  it('rejects title longer than 128 chars', async () => {
    await expect(
      processNotification({ ...VALID_JOB, title: 'x'.repeat(129) }),
    ).rejects.toThrow(/Invalid job payload/);
  });

  it('does not log body content (privacy)', async () => {
    const logSpy = jest.spyOn(console, 'log').mockImplementation(() => {});
    mockSingle.mockResolvedValueOnce({ data: { id: 'n1' }, error: null });

    await processNotification({ ...VALID_JOB, body: 'SECRET_BODY_CONTENT' });

    const logged = logSpy.mock.calls.map((args) => String(args[0])).join(' ');
    expect(logged).not.toContain('SECRET_BODY_CONTENT');
    logSpy.mockRestore();
  });
});
