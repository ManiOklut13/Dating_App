/**
 * Comprehensive Integration Test Suite:
 * - Unified Authentication & OTP Module (signin, otp/send, otp/verify, google, apple)
 * - Password Recovery Flow (forgot-password, reset-password)
 * - Profile Management Module (me, users/:targetUserId, profile/me)
 * - Multi-Step Onboarding Wizard Module (demographics with >18 validation, photos, verify-biometrics)
 */

import { jest } from '@jest/globals';
import { Test, TestingModule } from '@nestjs/testing';
import { BadRequestException, ForbiddenException, NotFoundException } from '@nestjs/common';
import { AppModule } from '../../app.module.js';
import { AuthController } from '../../auth/auth.controller.js';
import { AuthService } from '../../auth/auth.service.js';
import { ProfileController } from './profile.controller.js';
import { UsersController } from './users.controller.js';
import { ProfileService, UploadedFileItem } from './profile.service.js';
import { OnboardingController } from '../../onboarding/onboarding.controller.js';
import { OnboardingService } from '../../onboarding/onboarding.service.js';
import { AuthenticatedUser } from '../../auth/interfaces/authenticated-user.interface.js';
import { db } from '../../database/db.js';

describe('YoUnMe Auth, Profile & Onboarding Modules (Integration Spec)', () => {
  let moduleRef: TestingModule;
  let authController: AuthController;
  let profileController: ProfileController;
  let usersController: UsersController;
  let onboardingController: OnboardingController;

  const mockArjun: AuthenticatedUser = {
    id: '11111111-1111-1111-1111-111111111111',
    authentication_uid: 'supabase_uid_arjun_111',
    uid: '11111111-1111-1111-1111-111111111111',
    email: 'arjun.mehta@younme.social',
    email_verified: true,
  };

  const ananyaId = '22222222-2222-2222-2222-222222222222';

  beforeAll(async () => {
    moduleRef = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    authController = moduleRef.get<AuthController>(AuthController);
    profileController = moduleRef.get<ProfileController>(ProfileController);
    usersController = moduleRef.get<UsersController>(UsersController);
    onboardingController = moduleRef.get<OnboardingController>(OnboardingController);
  });

  afterAll(async () => {
    await moduleRef.close();
  });

  // =========================================================================
  // 1. Unified Authentication & OTP Module
  // =========================================================================
  describe('1. Unified Authentication & OTP Module', () => {
    it('POST /v1/auth/signin: should validate email/password and return Supabase JWT session', async () => {
      const res = await authController.signIn(undefined, {
        email: 'arjun.mehta@younme.social',
        password: 'password123',
      });

      expect(res.success).toBe(true);
      expect(res.message).toBe('Sign in successful');
      expect(res.user.email).toBe('arjun.mehta@younme.social');
      expect(res.session).toBeDefined();
      expect(res.session.access_token).toBeDefined();
      expect(res.session.token_type).toBe('bearer');
    });

    it('POST /v1/auth/signin: should exchange Bearer token when called in authenticated context', async () => {
      const res = await authController.signIn(mockArjun);

      expect(res.success).toBe(true);
      expect(res.user.uid).toBe(mockArjun.id);
      expect(res.user.email).toBe(mockArjun.email);
    });

    it('POST /v1/auth/otp/send: should dispatch OTP via email', async () => {
      const res = await authController.sendOtp({
        type: 'email',
        identifier: 'priya.sharma@younme.social',
      });

      expect(res.success).toBe(true);
      expect(res.type).toBe('email');
      expect(res.identifier).toBe('priya.sharma@younme.social');
    });

    it('POST /v1/auth/otp/send: should dispatch OTP via phone', async () => {
      const res = await authController.sendOtp({
        type: 'phone',
        identifier: '+919820055555',
      });

      expect(res.success).toBe(true);
      expect(res.type).toBe('phone');
      expect(res.identifier).toBe('+919820055555');
    });

    it('POST /v1/auth/otp/verify: should validate OTP token and provision user session', async () => {
      const res = await authController.verifyOtp({
        type: 'email',
        identifier: 'priya.sharma@younme.social',
        token: '123456',
      });

      expect(res.success).toBe(true);
      expect(res.session).toBeDefined();
      expect(res.session.access_token).toBeDefined();
      expect(res.user.email).toBe('priya.sharma@younme.social');
    });

    it('POST /v1/auth/google: should handle Google OAuth token exchange and return session', async () => {
      const res = await authController.signInWithGoogle({
        id_token: 'google-oauth-test-token-xyz',
      });

      expect(res.success).toBe(true);
      expect(res.session).toBeDefined();
      expect(res.session.access_token).toBeDefined();
      expect(res.user.id).toBeDefined();
    });

    it('POST /v1/auth/apple: should handle Apple OAuth token exchange and return session', async () => {
      const res = await authController.signInWithApple({
        id_token: 'apple-oauth-test-token-xyz',
      });

      expect(res.success).toBe(true);
      expect(res.session).toBeDefined();
      expect(res.session.access_token).toBeDefined();
      expect(res.user.id).toBeDefined();
    });
  });

  // =========================================================================
  // 2. Password Recovery Flow
  // =========================================================================
  describe('2. Password Recovery Flow', () => {
    it('POST /v1/auth/forgot-password: should dispatch password reset OTP/link', async () => {
      const res = await authController.forgotPassword({
        identifier: 'arjun.mehta@younme.social',
      });

      expect(res.success).toBe(true);
      expect(res.message).toContain('Password reset');
    });

    it('POST /v1/auth/reset-password: should validate token and update password securely', async () => {
      const res = await authController.resetPassword({
        identifier: 'arjun.mehta@younme.social',
        token: '123456',
        new_password: 'BrandNewSecurePassword@123',
      });

      expect(res.success).toBe(true);
      expect(res.message).toBe('Password updated successfully');
    });

    it('POST /v1/auth/reset-password: should reject passwords shorter than 6 characters', async () => {
      await expect(
        authController.resetPassword({
          identifier: 'arjun.mehta@younme.social',
          token: '123456',
          new_password: '123',
        }),
      ).rejects.toThrow(BadRequestException);
    });
  });

  // =========================================================================
  // 3. Profile Management Module
  // =========================================================================
  describe('3. Profile Management Module', () => {
    it('GET /v1/auth/me: should fetch logged-in user complete profile, wallet balance, and settings', async () => {
      const res = await authController.getCurrentUser(mockArjun);

      expect(res.success).toBe(true);
      expect(res.user).toBeDefined();
      expect(res.user.uid).toBe(mockArjun.id);
      expect(res.profile).toBeDefined();
      expect(res.profile.nickname).toBe('Arjun');
      expect(res.wallet).toBeDefined();
      expect(res.wallet.coin_balance).toBeGreaterThanOrEqual(0);
      expect(res.settings).toBeDefined();
      expect(res.settings.profile_visibility).toBeDefined();
      expect(res.photos).toBeDefined();
    });

    it('PUT /v1/profile/me: should update personal bio, job, and preferences', async () => {
      const res = await profileController.updateProfile(mockArjun, {
        bio: 'Updated bio: Building AI applications & exploring third wave coffee.',
        job: 'Founder & AI Architect',
        interests: ['ai', 'specialty_coffee', 'indie_music'],
        languages: ['English', 'Hindi', 'Marathi'],
        looking_for: ['relationship'],
        profile_visibility: 'everyone',
      });

      expect(res.success).toBe(true);
      expect(res.profile.bio).toContain('Building AI applications');
      expect(res.profile.profession).toBe('Founder & AI Architect');
      expect(res.profile.interests).toContain('specialty_coffee');
      expect(res.profile_progress).toBeGreaterThan(0);
    });

    it('GET /v1/users/:targetUserId: should fetch another user public profile with visibility masking', async () => {
      const res = await usersController.getPublicUserProfile(mockArjun, ananyaId);

      expect(res.success).toBe(true);
      expect(res.user_id).toBe(ananyaId);
      expect(res.nickname).toBe('Ananya');
      expect(res.is_matched).toBe(true); // Pre-seeded match
      expect(res.photos.length).toBeGreaterThan(0);
      expect((res as any).wallet).toBeUndefined(); // Never expose private wallet
      expect((res as any).phone_number).toBeUndefined(); // Never expose private phone
    });

    it('GET /v1/users/:targetUserId: should enforce block restrictions and throw ForbiddenException', async () => {
      const blockedUserId = 'blocked-user-id-999';
      db.users.set(blockedUserId, {
        id: blockedUserId,
        authentication_uid: 'auth_blocked_999',
        email: 'blocked@younme.social',
        email_verified: true,
        phone_country_code: '+91',
        phone_number: '9820099999',
        full_phone_number: '+919820099999',
        phone_verified: true,
        account_status: 'active',
        role: 'user',
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      });
      db.profiles.set(blockedUserId, {
        user_id: blockedUserId,
        nickname: 'BlockedUser',
        sexual_orientations: [],
        looking_for: [],
        languages: [],
        interests: [],
        app_language: 'en',
        app_theme: 'dark',
        read_receipts_status: true,
        profile_visibility: 'everyone',
        show_online_status: true,
        who_can_message: 'everyone',
        who_can_message_request: 'everyone',
        push_notifications_enabled: true,
        push_notifications: {},
        email_notifications_enabled: true,
        email_notifications: {},
        is_verified: false,
        verification_status: 'not_started',
        is_voice_verified: false,
        liveness_verified: false,
        profile_progress: 50,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      });

      db.blocksReports.push({
        id: 'block_test_rec',
        actor_user_id: mockArjun.id,
        target_user_id: blockedUserId,
        action_type: 'block',
        action_location: 'profile',
        status: 'open',
        created_at: new Date().toISOString(),
      });

      await expect(
        usersController.getPublicUserProfile(mockArjun, blockedUserId),
      ).rejects.toThrow(ForbiddenException);
    });
  });

  // =========================================================================
  // 4. Multi-Step Onboarding Wizard Module
  // =========================================================================
  describe('4. Multi-Step Onboarding Wizard Module', () => {
    it('POST /v1/onboarding/demographics: should save name, nickname, DOB (>18 yrs), gender, orientation, and interests', async () => {
      const res = await onboardingController.saveDemographics(mockArjun, {
        nickname: 'ArjunM',
        first_name: 'Arjun Mehta',
        date_of_birth: '1998-05-14',
        gender: 'male',
        sexual_orientations: ['straight'],
        interests: ['coffee', 'techno', 'running'],
      });

      expect(res.success).toBe(true);
      expect(res.message).toBe('Demographics saved successfully');
      expect(res.profile.nickname).toBe('ArjunM');
      expect(res.profile.first_name).toBe('Arjun Mehta');
      expect(res.profile.gender).toBe('male');
      expect(res.profile_progress).toBeGreaterThanOrEqual(30);
    });

    it('POST /v1/onboarding/demographics: should reject DOB under 18 years with BadRequestException', async () => {
      const underageDate = new Date();
      underageDate.setFullYear(underageDate.getFullYear() - 15);
      const dobStr = underageDate.toISOString().split('T')[0];

      await expect(
        onboardingController.saveDemographics(mockArjun, {
          nickname: 'TooYoung',
          date_of_birth: dobStr,
          gender: 'male',
          sexual_orientations: ['straight'],
          interests: ['video_games'],
        }),
      ).rejects.toThrow(BadRequestException);
    });

    it('POST /v1/profile/photos: should handle multipart uploads (2-6 images), save to storage, and queue worker scan', async () => {
      const dummyPhotos: UploadedFileItem[] = [
        {
          originalname: 'profile_front.jpg',
          mimetype: 'image/jpeg',
          size: 2048,
          buffer: Buffer.from('fake-front-photo-data'),
        },
        {
          originalname: 'profile_lifestyle.jpg',
          mimetype: 'image/jpeg',
          size: 3072,
          buffer: Buffer.from('fake-lifestyle-photo-data'),
        },
        {
          originalname: 'profile_travel.jpg',
          mimetype: 'image/jpeg',
          size: 2560,
          buffer: Buffer.from('fake-travel-photo-data'),
        },
      ];

      const res = await profileController.uploadPhotos(mockArjun, dummyPhotos);

      expect(res.success).toBe(true);
      expect(res.count).toBe(3);
      expect(res.photos.length).toBe(3);
      expect(res.photos[0].is_primary).toBe(true);
      expect(res.photos[0].photo_uri).toBeDefined();
    });

    it('POST /v1/profile/photos: should reject upload with fewer than 2 images', async () => {
      const singlePhoto: UploadedFileItem[] = [
        {
          originalname: 'single.jpg',
          mimetype: 'image/jpeg',
          size: 1024,
          buffer: Buffer.from('single'),
        },
      ];

      await expect(
        profileController.uploadPhotos(mockArjun, singlePhoto),
      ).rejects.toThrow(BadRequestException);
    });

    it('POST /v1/profile/photos: should reject upload with more than 6 images', async () => {
      const sevenPhotos: UploadedFileItem[] = Array.from({ length: 7 }, (_, i) => ({
        originalname: `photo_${i + 1}.jpg`,
        mimetype: 'image/jpeg',
        size: 1024,
        buffer: Buffer.from(`data_${i + 1}`),
      }));

      await expect(
        profileController.uploadPhotos(mockArjun, sevenPhotos),
      ).rejects.toThrow(BadRequestException);
    });

    it('POST /v1/profile/verify-biometrics: should handle voice/liveness verification flags and Bitmoji generation data', async () => {
      const res = await profileController.verifyBiometrics(mockArjun, {
        is_voice_verified: true,
        liveness_verified: true,
        verification_status: 'approved',
        avatar_object_key: 'avatar_bitmoji_arjun_cyberpunk_neon',
        bitmoji_data: {
          style: 'cyberpunk',
          outfit: 'neon_jacket',
          hair: 'dark_side_fade',
        },
      });

      expect(res.success).toBe(true);
      expect(res.verification.is_voice_verified).toBe(true);
      expect(res.verification.liveness_verified).toBe(true);
      expect(res.verification.avatar_object_key).toBe('avatar_bitmoji_arjun_cyberpunk_neon');
      expect(res.verification.is_verified).toBe(true); // Blue tick awarded when >= 70% + liveness
    });
  });
});

