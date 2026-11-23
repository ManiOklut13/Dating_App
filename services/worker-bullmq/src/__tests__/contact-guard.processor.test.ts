/**
 * YoUnMe Worker — Contact Guard Audit Processor Tests
 *
 * Uses jest.unstable_mockModule for proper ESM mocking.
 */

import { jest, describe, it, expect, beforeEach } from '@jest/globals';

// ─── Mock Supabase (must be before import of the processor) ──────────────────

const mockMaybeSingle = jest.fn<() => Promise<any>>();
const mockEq = jest.fn(() => ({ maybeSingle: mockMaybeSingle }));
const mockSelectChain = jest.fn(() => ({ eq: mockEq }));
const mockInsert = jest.fn<() => Promise<any>>();

const mockSupabaseFrom = jest.fn(() => ({
  select: mockSelectChain,
  insert: mockInsert,
}));

jest.unstable_mockModule('../supabase.js', () => ({
  getSupabaseClient: () => ({ from: mockSupabaseFrom }),
}));

// ─── Import after mocks ───────────────────────────────────────────────────────

const { processContactGuardAudit } = await import('../processors/contact-guard.processor.js');

// ─── Helpers ──────────────────────────────────────────────────────────────────

const VALID_JOB = {
  user_id: '00000000-0000-0000-0000-000000000001',
  conversation_id: '00000000-0000-0000-0000-000000000002',
  detected_type: 'phone_number' as const,
  normalised_excerpt: 'call me on',
  idempotency_key: 'guard_evt_abc123',
};

// ─── Tests ────────────────────────────────────────────────────────────────────

describe('processContactGuardAudit', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockSupabaseFrom.mockReturnValue({
      select: mockSelectChain,
      insert: mockInsert,
    });
    mockSelectChain.mockReturnValue({ eq: mockEq });
    mockEq.mockReturnValue({ maybeSingle: mockMaybeSingle });
  });

  it('persists a new audit record and returns persisted=true', async () => {
    mockMaybeSingle.mockResolvedValueOnce({ data: null, error: null });
    mockInsert.mockResolvedValueOnce({ error: null });

    const result = await processContactGuardAudit(VALID_JOB);
    expect(result.persisted).toBe(true);
    expect(result.duplicate).toBe(false);
    expect(mockInsert).toHaveBeenCalledTimes(1);
  });

  it('detects duplicate by idempotency_key and returns duplicate=true without inserting', async () => {
    mockMaybeSingle.mockResolvedValueOnce({
      data: { idempotency_key: VALID_JOB.idempotency_key },
      error: null,
    });

    const result = await processContactGuardAudit(VALID_JOB);
    expect(result.duplicate).toBe(true);
    expect(result.persisted).toBe(false);
    expect(mockInsert).not.toHaveBeenCalled();
  });

  it('handles Postgres unique constraint race (23505) as a duplicate', async () => {
    mockMaybeSingle.mockResolvedValueOnce({ data: null, error: null });
    mockInsert.mockResolvedValueOnce({ error: { code: '23505', message: 'unique violation' } });

    const result = await processContactGuardAudit(VALID_JOB);
    expect(result.duplicate).toBe(true);
    expect(result.persisted).toBe(false);
  });

  it('throws on non-unique DB insert error so BullMQ can retry', async () => {
    mockMaybeSingle.mockResolvedValueOnce({ data: null, error: null });
    mockInsert.mockResolvedValueOnce({ error: { code: '08006', message: 'connection failure' } });

    await expect(processContactGuardAudit(VALID_JOB)).rejects.toThrow(/DB insert error/);
  });

  it('rejects invalid payload', async () => {
    await expect(processContactGuardAudit({ user_id: 'bad-uuid' })).rejects.toThrow(
      /Invalid job payload/,
    );
  });

  it('rejects normalised_excerpt longer than 200 chars', async () => {
    await expect(
      processContactGuardAudit({ ...VALID_JOB, normalised_excerpt: 'x'.repeat(201) }),
    ).rejects.toThrow(/Invalid job payload/);
  });
});
