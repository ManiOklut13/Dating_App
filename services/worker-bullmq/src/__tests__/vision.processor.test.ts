/**
 * YoUnMe Worker — Vision Processor Tests
 *
 * Uses jest.unstable_mockModule with the EXACT specifier strings as written
 * in the processor source file (relative to the processor, not the test file).
 * This is the correct pattern for ESM mocking with jest.
 */

import { jest, describe, it, expect, beforeEach } from '@jest/globals';

// ─── Mock @google-cloud/vision ────────────────────────────────────────────────

const mockAnnotateImage = jest.fn<() => Promise<any>>();

jest.unstable_mockModule('@google-cloud/vision', () => ({
  default: {
    ImageAnnotatorClient: jest.fn().mockImplementation(() => ({
      annotateImage: mockAnnotateImage,
    })),
  },
}));

// ─── Mock ../config.js (as seen from src/processors/vision.processor.ts) ──────

jest.unstable_mockModule('../config.js', () => ({
  env: {
    REDIS_URL: 'redis://localhost:6379',
    SUPABASE_STORAGE_BUCKET_PREFIX: 'https://storage.supabase.co/younme/',
    WORKER_CONCURRENCY: 3,
    VISION_MAX_RETRIES: 3,
    NODE_ENV: 'test',
  },
  supabaseConfigured: true,
  visionConfigured: true,
}));

// ─── Mock ../supabase.js (as seen from src/processors/vision.processor.ts) ───

const mockUpsert = jest.fn<() => Promise<any>>();

jest.unstable_mockModule('../supabase.js', () => ({
  getSupabaseClient: () => ({
    from: () => ({ upsert: mockUpsert }),
  }),
}));

// ─── Dynamic import AFTER all mocks are registered ───────────────────────────

const { processVisionScan } = await import('../processors/vision.processor.js');

// ─── Helpers ──────────────────────────────────────────────────────────────────

const VALID_JOB = {
  asset_id: '00000000-0000-0000-0000-000000000001',
  user_id: '00000000-0000-0000-0000-000000000002',
  image_url: 'https://storage.supabase.co/younme/profiles/photo.jpg',
  type: 'profile_photo' as const,
};

function mockVisionResponse(adult: string, racy: string, violence: string, ocrText = '') {
  mockAnnotateImage.mockResolvedValueOnce([
    {
      safeSearchAnnotation: { adult, racy, violence },
      textAnnotations: ocrText ? [{ description: ocrText }] : [],
    },
  ]);
}

// ─── Tests ────────────────────────────────────────────────────────────────────

describe('processVisionScan', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockUpsert.mockResolvedValue({ error: null });
  });

  it('approves a clean image', async () => {
    mockVisionResponse('VERY_UNLIKELY', 'VERY_UNLIKELY', 'VERY_UNLIKELY');
    const result = await processVisionScan(VALID_JOB);
    expect(result.status).toBe('approved');
    expect(result.action_taken).toBe('APPROVED');
    expect(result.contact_detected).toBe(false);
    expect(mockUpsert).toHaveBeenCalledTimes(1);
  });

  it('blocks an explicit image (adult VERY_LIKELY)', async () => {
    mockVisionResponse('VERY_LIKELY', 'UNLIKELY', 'VERY_UNLIKELY');
    const result = await processVisionScan(VALID_JOB);
    expect(result.status).toBe('blocked');
    expect(result.action_taken).toBe('BLOCKED_EXPLICIT_CONTENT');
  });

  it('blocks an image with racy VERY_LIKELY', async () => {
    mockVisionResponse('VERY_UNLIKELY', 'VERY_LIKELY', 'VERY_UNLIKELY');
    const result = await processVisionScan(VALID_JOB);
    expect(result.status).toBe('blocked');
    expect(result.action_taken).toBe('BLOCKED_EXPLICIT_CONTENT');
  });

  it('blocks when OCR detects a 10-digit phone number', async () => {
    mockVisionResponse('VERY_UNLIKELY', 'VERY_UNLIKELY', 'VERY_UNLIKELY', '9820012345');
    const result = await processVisionScan(VALID_JOB);
    expect(result.status).toBe('blocked');
    expect(result.action_taken).toBe('BLOCKED_OCR_CONTACT_DETECTED');
    expect(result.contact_detected).toBe(true);
  });

  it('blocks when OCR detects an Instagram handle reference', async () => {
    mockVisionResponse('VERY_UNLIKELY', 'VERY_UNLIKELY', 'VERY_UNLIKELY', 'insta: @cooluser123');
    const result = await processVisionScan(VALID_JOB);
    expect(result.status).toBe('blocked');
    expect(result.contact_detected).toBe(true);
  });

  it('rejects a disallowed image URL without calling Vision API', async () => {
    const result = await processVisionScan({
      ...VALID_JOB,
      image_url: 'https://evil.attacker.com/ssrf.jpg',
    });
    expect(result.status).toBe('blocked');
    expect(result.action_taken).toBe('REJECTED_DISALLOWED_URL');
    expect(mockAnnotateImage).not.toHaveBeenCalled();
  });

  it('rejects invalid job payload', async () => {
    await expect(processVisionScan({ asset_id: 'not-a-uuid' })).rejects.toThrow(
      /Invalid job payload/,
    );
  });

  it('rethrows transient Vision API errors so BullMQ retries', async () => {
    mockAnnotateImage.mockRejectedValueOnce(new Error('UNAVAILABLE: upstream timeout'));
    await expect(processVisionScan(VALID_JOB)).rejects.toThrow(/Transient Vision API error/);
  });

  it('calls Supabase upsert with the correct asset_id', async () => {
    mockVisionResponse('VERY_UNLIKELY', 'VERY_UNLIKELY', 'VERY_UNLIKELY');
    await processVisionScan(VALID_JOB);
    expect(mockUpsert).toHaveBeenCalledWith(
      expect.objectContaining({ asset_id: VALID_JOB.asset_id }),
      { onConflict: 'asset_id' },
    );
  });
});
