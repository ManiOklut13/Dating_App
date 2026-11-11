/**
 * YoUnMe Dating App — Onboarding & Verification Service
 * Handles business logic, 8-step completion scoring, and Blue Tick auto-awarding rules.
 */

import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import {
  IOnboardingRepository,
  IProfileState,
  IProgressBreakdown,
  IWizardResponse,
  IOnboardingStatusResponse,
  Gender,
} from './interfaces/onboarding.interface.js';
import { OnboardingWizardDto } from './dto/onboarding-wizard.dto.js';
import { ONBOARDING_REPOSITORY_TOKEN } from './onboarding.repository.js';

export const DEFAULT_DEMO_USER_ID = '11111111-1111-1111-1111-111111111111';

export const STEP_WEIGHTS = {
  NICKNAME: 10,
  DOB: 10,
  GENDER: 10,
  BIO: 20,
  PHOTOS: 25,
  LIVENESS: 15,
  AVATAR: 5,
  LANGUAGES: 5,
} as const;

/**
 * Minimum profile completion required before a Blue Tick can be auto-awarded.
 */
export const BLUE_TICK_MIN_PROGRESS = 70;

@Injectable()
export class OnboardingService {
  constructor(
    @Inject(ONBOARDING_REPOSITORY_TOKEN)
    private readonly repository: IOnboardingRepository
  ) {}

  /**
   * Calculates dynamic profile progress breakdown across 8 criteria (0 to 100%)
   */
  public calculateProgress(
    profile: Partial<IProfileState>,
    photoCount: number = 0,
  ): {
    total: number;
    breakdown: IProgressBreakdown;
  } {
    let nicknameScore = 0;
    let dobScore = 0;
    let genderScore = 0;
    let bioScore = 0;
    let photosScore = 0;
    let livenessScore = 0;
    let avatarScore = 0;
    let languagesScore = 0;

    if (profile.nickname && profile.nickname.trim().length > 0) {
      nicknameScore = STEP_WEIGHTS.NICKNAME;
    }

    if (profile.date_of_birth) {
      dobScore = STEP_WEIGHTS.DOB;
    }

    if (profile.gender) {
      genderScore = STEP_WEIGHTS.GENDER;
    }

    if (profile.bio && profile.bio.trim().length > 10) {
      bioScore = STEP_WEIGHTS.BIO;
    }

    if (photoCount > 0) {
      photosScore = STEP_WEIGHTS.PHOTOS;
    }

    if (profile.liveness_verified) {
      livenessScore = STEP_WEIGHTS.LIVENESS;
    }

    if (profile.avatar_object_key) {
      avatarScore = STEP_WEIGHTS.AVATAR;
    }

    if (profile.languages && profile.languages.length > 0) {
      languagesScore = STEP_WEIGHTS.LANGUAGES;
    }

    const total = Math.min(
      100,
      nicknameScore +
        dobScore +
        genderScore +
        bioScore +
        photosScore +
        livenessScore +
        avatarScore +
        languagesScore
    );

    const breakdown: IProgressBreakdown = {
      nickname: nicknameScore,
      date_of_birth: dobScore,
      gender: genderScore,
      bio: bioScore,
      photos: photosScore,
      liveness: livenessScore,
      avatar: avatarScore,
      languages: languagesScore,
      total,
    };

    return { total, breakdown };
  }

  /**
   * Saves or partially updates onboarding wizard steps.
   * Auto-awards Blue Tick Verified Badge when completion is >= 70% and facial liveness is passed.
   */
  public async saveWizardStep(dto: OnboardingWizardDto): Promise<IWizardResponse> {
    const targetUserId = dto.user_id || DEFAULT_DEMO_USER_ID;

    const user = await this.repository.findUserById(targetUserId);
    const existingProfile = await this.repository.findProfileByUserId(targetUserId);

    // Map the API payload onto the canonical user_profiles domain fields
    const profileUpdate: Partial<IProfileState> = {
      user_id: targetUserId,
      ...(dto.nickname !== undefined && { nickname: dto.nickname }),
      ...(dto.bio !== undefined && { bio: dto.bio }),
      ...(dto.city !== undefined && { city: dto.city }),
      ...(dto.languages !== undefined && { languages: dto.languages }),
      ...(dto.liveness_verified !== undefined && {
        liveness_verified: dto.liveness_verified,
      }),
      ...(dto.avatar_object_key !== undefined && {
        avatar_object_key: dto.avatar_object_key,
      }),
      ...(dto.dob !== undefined && { date_of_birth: dto.dob }),
      ...(dto.gender !== undefined && { gender: dto.gender as Gender }),
      ...((dto.lat !== undefined || dto.lng !== undefined) && {
        location: {
          lat: dto.lat ?? existingProfile?.location?.lat ?? 19.0596,
          lng: dto.lng ?? existingProfile?.location?.lng ?? 72.8295,
        },
      }),
    };

    // Photos live in the dedicated user_photos table
    if (dto.photo_urls !== undefined) {
      await this.repository.replacePhotos(targetUserId, dto.photo_urls);
    }

    const photoCount = await this.repository.countPhotos(targetUserId);

    const mergedForScoring: Partial<IProfileState> = {
      ...(existingProfile || {}),
      ...profileUpdate,
    };

    const { total: progress, breakdown } = this.calculateProgress(
      mergedForScoring,
      photoCount,
    );

    profileUpdate.profile_progress = progress;

    // Safety & Verification Policy:
    // Auto-award Blue Tick if progress >= 70% AND Blink SDK liveness scan passed
    const isLivenessPassed =
      profileUpdate.liveness_verified ?? existingProfile?.liveness_verified ?? false;
    const blueTickAwarded = progress >= BLUE_TICK_MIN_PROGRESS && isLivenessPassed;

    if (blueTickAwarded) {
      profileUpdate.is_verified = true;
      profileUpdate.verification_status = 'approved';
    }

    // Persist profile
    const savedProfile = await this.repository.upsertProfile(targetUserId, profileUpdate);

    return {
      success: true,
      step_saved: dto.step,
      profile_progress: progress,
      blue_tick_awarded: blueTickAwarded,
      profile: savedProfile,
      user: user || undefined,
      breakdown,
    };
  }

  /**
   * Retrieves profile progress and actionable missing items for a given user
   */
  public async getStatus(userId: string): Promise<IOnboardingStatusResponse> {
    const profile = await this.repository.findProfileByUserId(userId);

    if (!profile) {
      throw new NotFoundException(`Profile for user ID "${userId}" not found`);
    }

    const photoCount = await this.repository.countPhotos(userId);
    const { total: progress, breakdown } = this.calculateProgress(profile, photoCount);

    const missingItems: string[] = [];
    if (!profile.nickname) missingItems.push('Profile nickname');
    if (!profile.date_of_birth) missingItems.push('Date of birth');
    if (!profile.gender) missingItems.push('Gender');
    if (!profile.bio || profile.bio.trim().length <= 10) {
      missingItems.push('Bio introduction (> 10 characters)');
    }
    if (photoCount < 3) {
      missingItems.push('Upload at least 3 photos (required for discovery deck)');
    }
    if (!profile.liveness_verified) {
      missingItems.push('Blink SDK oval face liveness check');
    }
    if (!profile.avatar_object_key) {
      missingItems.push('Avatar preference');
    }
    if (!profile.languages || profile.languages.length === 0) {
      missingItems.push('Languages spoken');
    }

    return {
      user_id: userId,
      progress,
      is_verified: profile.is_verified ?? false,
      missing_items: missingItems,
      breakdown,
    };
  }
}
