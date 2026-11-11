/**
 * YoUnMe Worker — FCM Push Delivery Processor Tests
 *
 * Uses jest.unstable_mockModule for proper ESM mocking.
 */

import { jest, describe, it, expect, beforeEach } from '@jest/globals';

// ─── Mock Supabase (must be before import of the processor) ──────────────────

const mockDeleteIn = jest.fn<() => Promise<any>>();
const mockDeleteChain = jest.fn(() => ({ in: mockDeleteIn }));
const mockDelete = jest.fn(() => mockDeleteChain());

const mockEq = jest.fn<() => Promise<any>>();
const mockSelect = jest.fn(() => ({ eq: mockEq }));

const mockSupabaseFrom = jest.fn((table: string) => {
  if (table === 'device_tokens') {
    return {
      select: mockSelect,
      delete: mockDelete,
    };
  }
  return {};
});

let mockSupabaseClient: any = { from: mockSupabaseFrom };

jest.unstable_mockModule('../supabase.js', () => ({
  getSupabaseClient: () => mockSupabaseClient,
}));

// ─── Mock FCM ─────────────────────────────────────────────────────────────────

const mockSendEachForMulticast = jest.fn<() => Promise<any>>();
let mockMessagingClient: any = {
  sendEachForMulticast: mockSendEachForMulticast,
};

jest.unstable_mockModule('../fcm.js', () => ({
  getMessagingClient: () => mockMessagingClient,
}));

// ─── Import after mocks ───────────────────────────────────────────────────────

const { processPushDelivery } = await import('../processors/push-delivery.processor.js');

// ─── Helpers ──────────────────────────────────────────────────────────────────

const VALID_PUSH_JOB = {
  recipient_id: '00000000-0000-0000-0000-000000000001',
  category: 'match' as const,
  title: 'New Match! 🔥',
  body: 'You and Priya liked each other!',
  data: { match_id: 'm123' },
  notification_id: '00000000-0000-0000-0000-000000000099',
};

// ─── Tests ────────────────────────────────────────────────────────────────────

describe('processPushDelivery', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockSupabaseClient = { from: mockSupabaseFrom };
    mockMessagingClient = { sendEachForMulticast: mockSendEachForMulticast };

    mockSupabaseFrom.mockReturnValue({
      select: mockSelect,
      delete: mockDelete,
    });
    mockSelect.mockReturnValue({ eq: mockEq });
    mockDelete.mockReturnValue({ in: mockDeleteIn });
    mockDeleteIn.mockResolvedValue({ error: null });
  });

  it('delivers push notification successfully to registered device tokens', async () => {
    mockEq.mockResolvedValueOnce({
      data: [
        { token: 'fcm_tok_111', platform: 'android' },
        { token: 'fcm_tok_222', platform: 'ios' },
      ],
      error: null,
    });

    mockSendEachForMulticast.mockResolvedValueOnce({
      successCount: 2,
      failureCount: 0,
      responses: [
        { success: true, messageId: 'msg_1' },
        { success: true, messageId: 'msg_2' },
      ],
    });

    const result = await processPushDelivery(VALID_PUSH_JOB);
    expect(result.delivered_count).toBe(2);
    expect(result.failed_count).toBe(0);
    expect(result.pruned_tokens).toBe(0);

    expect(mockSendEachForMulticast).toHaveBeenCalledWith(
      expect.objectContaining({
        tokens: ['fcm_tok_111', 'fcm_tok_222'],
        notification: {
          title: VALID_PUSH_JOB.title,
          body: VALID_PUSH_JOB.body,
        },
        data: expect.objectContaining({
          category: 'match',
          notification_id: VALID_PUSH_JOB.notification_id,
        }),
      }),
    );
  });

  it('skips FCM dispatch if recipient has no registered tokens', async () => {
    mockEq.mockResolvedValueOnce({ data: [], error: null });

    const result = await processPushDelivery(VALID_PUSH_JOB);
    expect(result.delivered_count).toBe(0);
    expect(result.reason).toBe('no_tokens');
    expect(mockSendEachForMulticast).not.toHaveBeenCalled();
  });

  it('prunes stale or unregistered device tokens from Supabase', async () => {
    mockEq.mockResolvedValueOnce({
      data: [
        { token: 'valid_tok', platform: 'android' },
        { token: 'stale_tok', platform: 'ios' },
      ],
      error: null,
    });

    mockSendEachForMulticast.mockResolvedValueOnce({
      successCount: 1,
      failureCount: 1,
      responses: [
        { success: true, messageId: 'msg_valid' },
        {
          success: false,
          error: { code: 'messaging/registration-token-not-registered' },
        },
      ],
    });

    const result = await processPushDelivery(VALID_PUSH_JOB);
    expect(result.delivered_count).toBe(1);
    expect(result.failed_count).toBe(1);
    expect(result.pruned_tokens).toBe(1);
    expect(mockDeleteIn).toHaveBeenCalledWith('token', ['stale_tok']);
  });

  it('throws for retry if all targets experienced retryable FCM server errors', async () => {
    mockEq.mockResolvedValueOnce({
      data: [{ token: 'tok_server_err', platform: 'android' }],
      error: null,
    });

    mockSendEachForMulticast.mockResolvedValueOnce({
      successCount: 0,
      failureCount: 1,
      responses: [
        {
          success: false,
          error: { code: 'messaging/server-unavailable' },
        },
      ],
    });

    await expect(processPushDelivery(VALID_PUSH_JOB)).rejects.toThrow(
      /All FCM targets experienced retryable provider errors/,
    );
  });

  it('rethrows FCM multicast transport exceptions for retry', async () => {
    mockEq.mockResolvedValueOnce({
      data: [{ token: 'tok_conn', platform: 'android' }],
      error: null,
    });

    mockSendEachForMulticast.mockRejectedValueOnce(new Error('ECONNRESET: socket closed'));

    await expect(processPushDelivery(VALID_PUSH_JOB)).rejects.toThrow(
      /FCM multicast transport error/,
    );
  });

  it('handles unconfigured FCM safely without throwing', async () => {
    mockEq.mockResolvedValueOnce({
      data: [{ token: 'tok_1', platform: 'android' }],
      error: null,
    });
    mockMessagingClient = null;

    const result = await processPushDelivery(VALID_PUSH_JOB);
    expect(result.delivered_count).toBe(0);
    expect(result.reason).toBe('fcm_not_configured');
  });

  it('handles unconfigured Supabase safely without throwing', async () => {
    mockSupabaseClient = null;

    const result = await processPushDelivery(VALID_PUSH_JOB);
    expect(result.delivered_count).toBe(0);
    expect(result.reason).toBe('supabase_not_configured');
  });

  it('rejects invalid job payload with invalid UUID', async () => {
    await expect(
      processPushDelivery({ ...VALID_PUSH_JOB, recipient_id: 'not-a-uuid' }),
    ).rejects.toThrow(/Invalid job payload/);
  });

  it('does not log device registration tokens (privacy)', async () => {
    const logSpy = jest.spyOn(console, 'log').mockImplementation(() => {});
    mockEq.mockResolvedValueOnce({
      data: [{ token: 'SUPER_SECRET_FCM_REGISTRATION_TOKEN_XYZ', platform: 'android' }],
      error: null,
    });
    mockSendEachForMulticast.mockResolvedValueOnce({
      successCount: 1,
      failureCount: 0,
      responses: [{ success: true, messageId: 'm1' }],
    });

    await processPushDelivery(VALID_PUSH_JOB);

    const logged = logSpy.mock.calls.map((args) => String(args[0])).join(' ');
    expect(logged).not.toContain('SUPER_SECRET_FCM_REGISTRATION_TOKEN_XYZ');
    logSpy.mockRestore();
  });
});

