import { jest } from '@jest/globals';
import { Test, TestingModule } from '@nestjs/testing';
import { ConfigService } from '@nestjs/config';
import { ProfileController } from './profile.controller.js';
import { UsersController } from './users.controller.js';
import { ProfileService } from './profile.service.js';
import { SupabaseService } from '../../supabase/supabase.service.js';
import { SupabaseAuthGuard } from '../../auth/guards/supabase-auth.guard.js';
import { AuthenticatedUser } from '../../auth/interfaces/authenticated-user.interface.js';

describe('ProfileController & UsersController', () => {
  let profileController: ProfileController;
  let usersController: UsersController;
  let profileService: ProfileService;

  const mockUser: AuthenticatedUser = {
    id: '11111111-1111-1111-1111-111111111111',
    authentication_uid: 'supabase-user-111',
    uid: '11111111-1111-1111-1111-111111111111',
    email: 'arjun@younme.social',
  };

  const mockProfileService = {
    updateProfile: jest.fn().mockImplementation(() =>
      Promise.resolve({
        success: true,
        message: 'Profile updated successfully',
        profile: { bio: 'New bio' },
      }),
    ),
    uploadPhotos: jest.fn().mockImplementation(() =>
      Promise.resolve({
        success: true,
        message: 'Photos uploaded and queued for vision scan',
        count: 2,
        photos: [{ id: 'p1' }, { id: 'p2' }],
      }),
    ),
    verifyBiometrics: jest.fn().mockImplementation(() =>
      Promise.resolve({
        success: true,
        message: 'Biometrics and avatar verified successfully',
        verification: { is_verified: true },
      }),
    ),
    getPublicUserProfile: jest.fn().mockImplementation(() =>
      Promise.resolve({
        success: true,
        user_id: '22222222-2222-2222-2222-222222222222',
        nickname: 'Ananya',
        photos: [{ id: 'photo-1' }],
      }),
    ),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [ProfileController, UsersController],
      providers: [
        { provide: ProfileService, useValue: mockProfileService },
        { provide: SupabaseService, useValue: { getUser: jest.fn() } },
        { provide: ConfigService, useValue: { get: jest.fn() } },
        SupabaseAuthGuard,
      ],
    }).compile();

    profileController = module.get<ProfileController>(ProfileController);
    usersController = module.get<UsersController>(UsersController);
    profileService = module.get<ProfileService>(ProfileService);
  });

  describe('updateProfile', () => {
    it('should call profileService.updateProfile', async () => {
      const dto = { bio: 'New bio', job: 'Tech Founder' };
      const res = await profileController.updateProfile(mockUser, dto);

      expect(res.success).toBe(true);
      expect(profileService.updateProfile).toHaveBeenCalledWith(mockUser.id, dto);
    });
  });

  describe('uploadPhotos', () => {
    it('should reject if fewer than 2 photos are provided', async () => {
      const files: any[] = [{ originalname: 'p1.jpg' }];
      await expect(profileController.uploadPhotos(mockUser, files)).rejects.toThrow();
    });

    it('should process upload when 2-6 photos are provided', async () => {
      const files: any[] = [{ originalname: 'p1.jpg' }, { originalname: 'p2.jpg' }];
      const res = await profileController.uploadPhotos(mockUser, files);

      expect(res.success).toBe(true);
      expect(profileService.uploadPhotos).toHaveBeenCalledWith(mockUser.id, files);
    });
  });

  describe('verifyBiometrics', () => {
    it('should call profileService.verifyBiometrics', async () => {
      const dto = { is_voice_verified: true, liveness_verified: true };
      const res = await profileController.verifyBiometrics(mockUser, dto);

      expect(res.success).toBe(true);
      expect(profileService.verifyBiometrics).toHaveBeenCalledWith(mockUser.id, dto);
    });
  });

  describe('getPublicUserProfile', () => {
    it('should fetch public profile of target user', async () => {
      const targetUserId = '22222222-2222-2222-2222-222222222222';
      const res = await usersController.getPublicUserProfile(mockUser, targetUserId);

      expect(res.success).toBe(true);
      expect(profileService.getPublicUserProfile).toHaveBeenCalledWith(
        mockUser.id,
        targetUserId,
      );
    });
  });
});

