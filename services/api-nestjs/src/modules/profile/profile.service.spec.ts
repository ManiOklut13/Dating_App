import { jest } from '@jest/globals';
import { Test, TestingModule } from '@nestjs/testing';
import { BadRequestException, ForbiddenException, NotFoundException } from '@nestjs/common';
import { ProfileService, UploadedFileItem } from './profile.service.js';
import { SupabaseService } from '../../supabase/supabase.service.js';
import { WorkerService } from '../worker/worker.service.js';
import { db } from '../../database/db.js';

describe('ProfileService', () => {
  let service: ProfileService;

  const mockSupabaseService = {
    hasClient: false,
    uploadPhoto: jest.fn(),
  };

  const mockWorkerService = {
    processVisionScan: jest.fn().mockImplementation(() => Promise.resolve({ success: true })),
  };

  const testUserId = '11111111-1111-1111-1111-111111111111';
  const partnerId = '22222222-2222-2222-2222-222222222222';

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ProfileService,
        { provide: SupabaseService, useValue: mockSupabaseService },
        { provide: WorkerService, useValue: mockWorkerService },
      ],
    }).compile();

    service = module.get<ProfileService>(ProfileService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('updateProfile', () => {
    it('should update bio, job, and preferences in profile', async () => {
      const res = await service.updateProfile(testUserId, {
        bio: 'Updated bio testing suite',
        job: 'Lead Architect',
        interests: ['hiking', 'espresso'],
      });

      expect(res.success).toBe(true);
      expect(res.profile.bio).toBe('Updated bio testing suite');
      expect(res.profile.profession).toBe('Lead Architect');
      expect(res.profile.interests).toEqual(['hiking', 'espresso']);
    });
  });

  describe('uploadPhotos', () => {
    it('should throw BadRequestException if fewer than 2 photos are uploaded', async () => {
      const singleFile: UploadedFileItem[] = [
        {
          originalname: 'photo1.jpg',
          mimetype: 'image/jpeg',
          size: 1024,
          buffer: Buffer.from('fake-data'),
        },
      ];

      await expect(service.uploadPhotos(testUserId, singleFile)).rejects.toThrow(
        BadRequestException,
      );
    });

    it('should throw BadRequestException if more than 6 photos are uploaded', async () => {
      const sevenFiles: UploadedFileItem[] = Array.from({ length: 7 }, (_, i) => ({
        originalname: `photo${i + 1}.jpg`,
        mimetype: 'image/jpeg',
        size: 1024,
        buffer: Buffer.from('fake-data'),
      }));

      await expect(service.uploadPhotos(testUserId, sevenFiles)).rejects.toThrow(
        BadRequestException,
      );
    });

    it('should upload 3 photos, save records, and dispatch vision jobs to worker-bullmq', async () => {
      const threeFiles: UploadedFileItem[] = [
        { originalname: 'p1.jpg', mimetype: 'image/jpeg', size: 1024, buffer: Buffer.from('d1') },
        { originalname: 'p2.jpg', mimetype: 'image/jpeg', size: 1024, buffer: Buffer.from('d2') },
        { originalname: 'p3.jpg', mimetype: 'image/jpeg', size: 1024, buffer: Buffer.from('d3') },
      ];

      const res = await service.uploadPhotos(testUserId, threeFiles);

      expect(res.success).toBe(true);
      expect(res.count).toBe(3);
      expect(res.photos.length).toBe(3);
      expect(res.photos[0].is_primary).toBe(true);
      expect(mockWorkerService.processVisionScan).toHaveBeenCalledTimes(3);
    });
  });

  describe('verifyBiometrics', () => {
    it('should update verification flags and Bitmoji avatar object key', async () => {
      const res = await service.verifyBiometrics(testUserId, {
        is_voice_verified: true,
        liveness_verified: true,
        avatar_object_key: 'avatar_bitmoji_3d_test',
      });

      expect(res.success).toBe(true);
      expect(res.verification.is_voice_verified).toBe(true);
      expect(res.verification.liveness_verified).toBe(true);
      expect(res.verification.avatar_object_key).toBe('avatar_bitmoji_3d_test');
    });
  });

  describe('getPublicUserProfile', () => {
    it('should return public profile for matched user respecting visibility', async () => {
      const profile = await service.getPublicUserProfile(testUserId, partnerId);

      expect(profile.success).toBe(true);
      expect(profile.user_id).toBe(partnerId);
      expect(profile.nickname).toBe('Ananya');
      expect(profile.is_matched).toBe(true);
    });

    it('should throw ForbiddenException if user is blocked', async () => {
      // Simulate block in in-memory store
      db.blocksReports.push({
        id: 'block_test_1',
        actor_user_id: testUserId,
        target_user_id: 'blocked_user_999',
        action_type: 'block',
        action_location: 'chat',
        status: 'open',
        created_at: new Date().toISOString(),
      });

      await expect(
        service.getPublicUserProfile(testUserId, 'blocked_user_999'),
      ).rejects.toThrow(ForbiddenException);
    });

    it('should throw NotFoundException for non-existent user', async () => {
      await expect(
        service.getPublicUserProfile(testUserId, '00000000-0000-0000-0000-000000000000'),
      ).rejects.toThrow(NotFoundException);
    });
  });
});

