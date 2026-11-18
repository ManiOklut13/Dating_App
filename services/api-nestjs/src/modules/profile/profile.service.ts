/**
 * YoUnMe Dating App — Profile Management Service
 * Implements profile updates, multipart photo uploads to Supabase Storage with
 * worker-bullmq SafeSearch & face-embedding dispatch, biometric verification,
 * and visibility-masked public profile retrieval.
 */

import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
  Logger,
  Optional,
} from '@nestjs/common';
import * as crypto from 'crypto';
import * as fs from 'fs';
import * as path from 'path';
import { SupabaseService } from '../../supabase/supabase.service.js';
import { DatabaseService } from '../database/database.service.js';
import { WorkerService } from '../worker/worker.service.js';
import { UpdateProfileDto } from './dto/update-profile.dto.js';
import { VerifyBiometricsDto } from './dto/verify-biometrics.dto.js';
import { db } from '../../database/db.js';

export interface UploadedFileItem {
  fieldname?: string;
  originalname: string;
  encoding?: string;
  mimetype: string;
  size: number;
  buffer: Buffer;
}

@Injectable()
export class ProfileService {
  private readonly logger = new Logger(ProfileService.name);

  constructor(
    private readonly supabaseService: SupabaseService,
    private readonly workerService: WorkerService,
    @Optional() private readonly databaseService?: DatabaseService,
  ) {}

  /**
   * Helper to recalculate profile completion percentage across 8 criteria.
   */
  private computeProgress(profile: Record<string, any>, photoCount: number): number {
    let score = 0;
    if (profile.nickname && profile.nickname.trim().length > 0) score += 10;
    if (profile.date_of_birth) score += 10;
    if (profile.gender) score += 10;
    if (profile.bio && profile.bio.trim().length > 10) score += 20;
    if (photoCount > 0) score += 25;
    if (profile.liveness_verified) score += 15;
    if (profile.avatar_object_key) score += 5;
    if (profile.languages && profile.languages.length > 0) score += 5;
    return Math.min(100, score);
  }

  /**
   * PUT /v1/profile/me
   * Updates personal bio, job (profession), education, preferences, and privacy settings.
   */
  async updateProfile(userId: string, dto: UpdateProfileDto) {
    const jobOrProfession = dto.profession || dto.job;

    // 1. PostgreSQL persistence
    if (this.databaseService?.isConnected) {
      try {
        const existingRes = await this.databaseService.query(
          'SELECT * FROM user_profiles WHERE user_id = $1 LIMIT 1',
          [userId],
        );
        const existing = existingRes.rows[0] || {};

        const photoCountRes = await this.databaseService.query(
          'SELECT count(*) as count FROM user_photos WHERE user_id = $1',
          [userId],
        );
        const photoCount = parseInt(photoCountRes.rows[0]?.count || '0', 10);

        const merged = {
          ...existing,
          bio: dto.bio !== undefined ? dto.bio : existing.bio,
          profession: jobOrProfession !== undefined ? jobOrProfession : existing.profession,
          education: dto.education !== undefined ? dto.education : existing.education,
          city: dto.city !== undefined ? dto.city : existing.city,
          country_code: dto.country_code !== undefined ? dto.country_code : existing.country_code,
          interests: dto.interests !== undefined ? dto.interests : (existing.interests || []),
          languages: dto.languages !== undefined ? dto.languages : (existing.languages || []),
          looking_for: dto.looking_for !== undefined ? dto.looking_for : (existing.looking_for || []),
          sexual_orientations: dto.sexual_orientations !== undefined ? dto.sexual_orientations : (existing.sexual_orientations || []),
          min_age: dto.min_age !== undefined ? dto.min_age : existing.min_age,
          max_age: dto.max_age !== undefined ? dto.max_age : existing.max_age,
          max_distance_km: dto.max_distance_km !== undefined ? dto.max_distance_km : existing.max_distance_km,
          profile_visibility: dto.profile_visibility !== undefined ? dto.profile_visibility : existing.profile_visibility,
          who_can_message: dto.who_can_message !== undefined ? dto.who_can_message : existing.who_can_message,
          who_can_message_request: dto.who_can_message_request !== undefined ? dto.who_can_message_request : existing.who_can_message_request,
          show_online_status: dto.show_online_status !== undefined ? dto.show_online_status : existing.show_online_status,
          read_receipts_status: dto.read_receipts_status !== undefined ? dto.read_receipts_status : existing.read_receipts_status,
          app_language: dto.app_language !== undefined ? dto.app_language : existing.app_language,
          app_theme: dto.app_theme !== undefined ? dto.app_theme : existing.app_theme,
          push_notifications_enabled: dto.push_notifications_enabled !== undefined ? dto.push_notifications_enabled : existing.push_notifications_enabled,
          email_notifications_enabled: dto.email_notifications_enabled !== undefined ? dto.email_notifications_enabled : existing.email_notifications_enabled,
        };

        const newProgress = this.computeProgress(merged, photoCount);

        const updateQuery = `
          UPDATE user_profiles
          SET bio = $2,
              profession = $3,
              education = $4,
              city = $5,
              country_code = $6,
              interests = $7,
              languages = $8,
              looking_for = $9,
              sexual_orientations = $10,
              min_age = $11,
              max_age = $12,
              max_distance_km = $13,
              profile_visibility = $14,
              who_can_message = $15,
              who_can_message_request = $16,
              show_online_status = $17,
              read_receipts_status = $18,
              app_language = $19,
              app_theme = $20,
              push_notifications_enabled = $21,
              email_notifications_enabled = $22,
              profile_progress = $23,
              updated_at = now()
          WHERE user_id = $1
          RETURNING *;
        `;

        const updateRes = await this.databaseService.query(updateQuery, [
          userId,
          merged.bio || null,
          merged.profession || null,
          merged.education || null,
          merged.city || null,
          merged.country_code || null,
          merged.interests,
          merged.languages,
          merged.looking_for,
          merged.sexual_orientations,
          merged.min_age ?? 18,
          merged.max_age ?? 50,
          merged.max_distance_km ?? 50,
          merged.profile_visibility || 'everyone',
          merged.who_can_message || 'everyone',
          merged.who_can_message_request || 'everyone',
          merged.show_online_status ?? true,
          merged.read_receipts_status ?? true,
          merged.app_language || 'en',
          merged.app_theme || 'dark',
          merged.push_notifications_enabled ?? true,
          merged.email_notifications_enabled ?? true,
          newProgress,
        ]);

        if (updateRes.rows.length > 0) {
          const updated = updateRes.rows[0];
          // Mirror in fallback
          this.syncInMemoryProfile(userId, dto, newProgress);
          return {
            success: true,
            message: 'Profile updated successfully',
            profile: updated,
            profile_progress: newProgress,
          };
        }
      } catch (err: any) {
        this.logger.warn(`PostgreSQL updateProfile notice: ${err.message}`);
      }
    }

    // 2. In-memory fallback
    const memProfile = this.syncInMemoryProfile(userId, dto);
    return {
      success: true,
      message: 'Profile updated successfully',
      profile: memProfile,
      profile_progress: memProfile.profile_progress,
    };
  }

  private syncInMemoryProfile(userId: string, dto: UpdateProfileDto, progress?: number) {
    let p = db.profiles.get(userId);
    if (!p) {
      p = {
        user_id: userId,
        nickname: 'User',
        sexual_orientations: [],
        looking_for: [],
        languages: ['English'],
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
        profile_progress: 0,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      };
      db.profiles.set(userId, p);
    }

    if (dto.bio !== undefined) p.bio = dto.bio;
    if (dto.profession !== undefined || dto.job !== undefined) p.profession = dto.profession || dto.job;
    if (dto.education !== undefined) p.education = dto.education;
    if (dto.city !== undefined) p.city = dto.city;
    if (dto.country_code !== undefined) p.country_code = dto.country_code;
    if (dto.interests !== undefined) p.interests = dto.interests;
    if (dto.languages !== undefined) p.languages = dto.languages;
    if (dto.looking_for !== undefined) p.looking_for = dto.looking_for;
    if (dto.sexual_orientations !== undefined) p.sexual_orientations = dto.sexual_orientations;
    if (dto.min_age !== undefined) p.min_age = dto.min_age;
    if (dto.max_age !== undefined) p.max_age = dto.max_age;
    if (dto.max_distance_km !== undefined) p.max_distance_km = dto.max_distance_km;
    if (dto.profile_visibility !== undefined) p.profile_visibility = dto.profile_visibility;
    if (dto.who_can_message !== undefined) p.who_can_message = dto.who_can_message;
    if (dto.who_can_message_request !== undefined) p.who_can_message_request = dto.who_can_message_request;
    if (dto.show_online_status !== undefined) p.show_online_status = dto.show_online_status;
    if (dto.read_receipts_status !== undefined) p.read_receipts_status = dto.read_receipts_status;
    if (dto.app_language !== undefined) p.app_language = dto.app_language;
    if (dto.app_theme !== undefined) p.app_theme = dto.app_theme;
    if (dto.push_notifications_enabled !== undefined) p.push_notifications_enabled = dto.push_notifications_enabled;
    if (dto.email_notifications_enabled !== undefined) p.email_notifications_enabled = dto.email_notifications_enabled;

    const photoCount = (db.photos.get(userId) || []).length;
    p.profile_progress = progress !== undefined ? progress : this.computeProgress(p, photoCount);
    p.updated_at = new Date().toISOString();
    return p;
  }

  /**
   * POST /v1/profile/photos
   * Handles multipart image uploads (2-6 images), saves to storage, and dispatches job
   * to worker-bullmq for SafeSearch and face-embedding analysis.
   */
  async uploadPhotos(userId: string, files: UploadedFileItem[]) {
    if (!files || files.length < 2 || files.length > 6) {
      throw new BadRequestException('Photos upload requires between 2 and 6 images');
    }

    const savedPhotos: any[] = [];
    const now = new Date().toISOString();

    for (let i = 0; i < files.length; i++) {
      const file = files[i];
      const photoId = crypto.randomUUID();
      const ext = path.extname(file.originalname || '') || '.jpg';
      const storageKey = `${userId}/${photoId}${ext}`;
      let publicUrl = '';

      // 1. Storage: Supabase Storage or Local File fallback
      if (this.supabaseService.hasClient) {
        try {
          const uploadResult = await this.supabaseService.uploadPhoto(
            'user-photos',
            storageKey,
            file.buffer,
            file.mimetype || 'image/jpeg',
          );
          if (uploadResult.publicUrl) {
            publicUrl = uploadResult.publicUrl;
          }
        } catch (err: any) {
          this.logger.warn(`Supabase Storage upload error: ${err.message}`);
        }
      }

      if (!publicUrl) {
        // Fallback: Local dev URL or data URI
        const uploadsDir = path.join(process.cwd(), 'uploads', 'photos');
        try {
          if (!fs.existsSync(uploadsDir)) {
            fs.mkdirSync(uploadsDir, { recursive: true });
          }
          const localFilePath = path.join(uploadsDir, `${photoId}${ext}`);
          fs.writeFileSync(localFilePath, file.buffer);
          publicUrl = `/assets/uploads/${photoId}${ext}`;
        } catch {
          publicUrl = `https://storage.younme.social/user-photos/${storageKey}`;
        }
      }

      const photoRecord = {
        id: photoId,
        user_id: userId,
        photo_uri: publicUrl,
        display_order: i + 1,
        is_primary: i === 0,
        is_face_verified: false,
        moderation_status: 'pending' as const,
        comments_json: {},
        created_at: now,
        updated_at: now,
      };

      savedPhotos.push(photoRecord);

      // 2. Dispatch vision scan job to worker-bullmq
      try {
        await this.workerService.processVisionScan({
          asset_id: photoId,
          user_id: userId,
          image_url: publicUrl,
          type: 'profile_photo',
        });
        this.logger.log(`Dispatched vision scan job for photo ${photoId} (User: ${userId})`);
      } catch (err: any) {
        this.logger.warn(`Worker dispatch notice for photo ${photoId}: ${err.message}`);
      }
    }

    // 3. Persist in PostgreSQL
    if (this.databaseService?.isConnected) {
      try {
        // Delete old photos and replace with new batch
        await this.databaseService.query('DELETE FROM user_photos WHERE user_id = $1', [userId]);

        for (const p of savedPhotos) {
          await this.databaseService.query(
            `INSERT INTO user_photos (id, user_id, photo_uri, display_order, is_primary, is_face_verified, moderation_status)
             VALUES ($1, $2, $3, $4, $5, $6, $7)`,
            [p.id, p.user_id, p.photo_uri, p.display_order, p.is_primary, p.is_face_verified, p.moderation_status],
          );
        }

        // Recalculate progress in DB
        const profRes = await this.databaseService.query(
          'SELECT * FROM user_profiles WHERE user_id = $1 LIMIT 1',
          [userId],
        );
        if (profRes.rows.length > 0) {
          const newProg = this.computeProgress(profRes.rows[0], savedPhotos.length);
          await this.databaseService.query(
            'UPDATE user_profiles SET profile_progress = $1, updated_at = now() WHERE user_id = $2',
            [newProg, userId],
          );
        }
      } catch (err: any) {
        this.logger.warn(`PostgreSQL photo persistence notice: ${err.message}`);
      }
    }

    // 4. In-Memory fallback store
    db.photos.set(userId, savedPhotos);
    const memProf = db.profiles.get(userId);
    if (memProf) {
      memProf.profile_progress = this.computeProgress(memProf, savedPhotos.length);
      memProf.updated_at = now;
    }

    return {
      success: true,
      message: 'Photos uploaded and queued for SafeSearch and facial analysis',
      count: savedPhotos.length,
      photos: savedPhotos,
    };
  }

  /**
   * POST /v1/profile/verify-biometrics
   * Handles voice/liveness verification flags and Bitmoji generation data.
   */
  async verifyBiometrics(userId: string, dto: VerifyBiometricsDto) {
    const isVoice = dto.is_voice_verified ?? false;
    const isLiveness = dto.liveness_verified ?? false;
    const status = dto.verification_status || (isLiveness ? 'approved' : 'pending');

    // 1. PostgreSQL persistence
    if (this.databaseService?.isConnected) {
      try {
        const profRes = await this.databaseService.query(
          'SELECT * FROM user_profiles WHERE user_id = $1 LIMIT 1',
          [userId],
        );
        const currentProfile = profRes.rows[0] || {};
        const photoCountRes = await this.databaseService.query(
          'SELECT count(*) as count FROM user_photos WHERE user_id = $1',
          [userId],
        );
        const photoCount = parseInt(photoCountRes.rows[0]?.count || '0', 10);

        const merged = {
          ...currentProfile,
          is_voice_verified: isVoice,
          liveness_verified: isLiveness,
          verification_status: status,
          avatar_object_key: dto.avatar_object_key || currentProfile.avatar_object_key,
        };

        const progress = this.computeProgress(merged, photoCount);
        const blueTickAwarded = progress >= 70 && isLiveness;

        const updateRes = await this.databaseService.query(
          `UPDATE user_profiles
           SET is_voice_verified = $2,
               liveness_verified = $3,
               verification_status = $4,
               avatar_object_key = COALESCE($5, avatar_object_key),
               is_verified = $6,
               profile_progress = $7,
               updated_at = now()
           WHERE user_id = $1
           RETURNING *;`,
          [
            userId,
            isVoice,
            isLiveness,
            status,
            dto.avatar_object_key || null,
            blueTickAwarded,
            progress,
          ],
        );

        if (updateRes.rows.length > 0) {
          const row = updateRes.rows[0];
          this.syncInMemoryBiometrics(userId, dto, blueTickAwarded, progress);
          return {
            success: true,
            message: 'Biometrics and avatar verified successfully',
            verification: {
              is_verified: blueTickAwarded,
              is_voice_verified: isVoice,
              liveness_verified: isLiveness,
              verification_status: status,
              avatar_object_key: row.avatar_object_key,
              blue_tick_awarded: blueTickAwarded,
              profile_progress: progress,
            },
          };
        }
      } catch (err: any) {
        this.logger.warn(`PostgreSQL verifyBiometrics notice: ${err.message}`);
      }
    }

    // 2. In-Memory fallback store
    const memProf = this.syncInMemoryBiometrics(userId, dto);
    return {
      success: true,
      message: 'Biometrics and avatar verified successfully',
      verification: {
        is_verified: memProf.is_verified,
        is_voice_verified: memProf.is_voice_verified,
        liveness_verified: memProf.liveness_verified,
        verification_status: memProf.verification_status,
        avatar_object_key: memProf.avatar_object_key,
        blue_tick_awarded: memProf.is_verified,
        profile_progress: memProf.profile_progress,
      },
    };
  }

  private syncInMemoryBiometrics(
    userId: string,
    dto: VerifyBiometricsDto,
    blueTick?: boolean,
    progress?: number,
  ) {
    let p = db.profiles.get(userId);
    if (!p) {
      this.syncInMemoryProfile(userId, {});
      p = db.profiles.get(userId)!;
    }

    if (dto.is_voice_verified !== undefined) p.is_voice_verified = dto.is_voice_verified;
    if (dto.liveness_verified !== undefined) p.liveness_verified = dto.liveness_verified;
    if (dto.verification_status !== undefined) p.verification_status = dto.verification_status as any;
    if (dto.avatar_object_key !== undefined) p.avatar_object_key = dto.avatar_object_key;

    const photoCount = (db.photos.get(userId) || []).length;
    p.profile_progress = progress !== undefined ? progress : this.computeProgress(p, photoCount);
    p.is_verified = blueTick !== undefined ? blueTick : (p.profile_progress >= 70 && p.liveness_verified);
    p.updated_at = new Date().toISOString();
    return p;
  }

  /**
   * GET /v1/users/:targetUserId
   * Fetches another user's public profile with strict visibility masking (respecting matches/blocks).
   */
  async getPublicUserProfile(requesterId: string, targetUserId: string) {
    if (!targetUserId) {
      throw new BadRequestException('targetUserId is required');
    }

    // 1. Block Check
    if (this.databaseService?.isConnected) {
      try {
        const blockRes = await this.databaseService.query(
          `SELECT id FROM user_blocks_reports
           WHERE ((actor_user_id = $1 AND target_user_id = $2)
              OR (actor_user_id = $2 AND target_user_id = $1))
             AND action_type = 'block'
             AND status = 'open'
           LIMIT 1`,
          [requesterId, targetUserId],
        );

        if (blockRes.rows.length > 0) {
          throw new ForbiddenException('User is blocked or unavailable');
        }
      } catch (err: any) {
        if (err instanceof ForbiddenException) throw err;
        this.logger.debug(`Block query notice: ${err.message}`);
      }
    }

    if (db.isUserBlocked(requesterId, targetUserId)) {
      throw new ForbiddenException('User is blocked or unavailable');
    }

    // 2. Fetch User and Profile
    let targetUser: any = null;
    let targetProfile: any = null;
    let targetPhotos: any[] = [];
    let isMatched = false;

    if (this.databaseService?.isConnected) {
      try {
        const uRes = await this.databaseService.query(
          'SELECT id, account_status FROM app_users WHERE id = $1 LIMIT 1',
          [targetUserId],
        );
        targetUser = uRes.rows[0];

        const pRes = await this.databaseService.query(
          'SELECT * FROM user_profiles WHERE user_id = $1 LIMIT 1',
          [targetUserId],
        );
        targetProfile = pRes.rows[0];

        const phRes = await this.databaseService.query(
          `SELECT id, photo_uri, display_order, is_primary, is_face_verified, caption
           FROM user_photos
           WHERE user_id = $1 AND moderation_status = 'approved'
           ORDER BY display_order ASC`,
          [targetUserId],
        );
        targetPhotos = phRes.rows;

        const mRes = await this.databaseService.query(
          `SELECT id FROM matches
           WHERE ((user_a_id = $1 AND user_b_id = $2)
              OR (user_a_id = $2 AND user_b_id = $1))
             AND status = 'active'
           LIMIT 1`,
          [requesterId, targetUserId],
        );
        isMatched = mRes.rows.length > 0;
      } catch (err: any) {
        this.logger.debug(`PostgreSQL getPublicUserProfile notice: ${err.message}`);
      }
    }

    // In-Memory Fallback if not found in DB
    if (!targetUser) {
      targetUser = db.users.get(targetUserId);
    }
    if (!targetProfile) {
      targetProfile = db.profiles.get(targetUserId);
    }
    if (targetPhotos.length === 0) {
      targetPhotos = (db.photos.get(targetUserId) || [])
        .slice()
        .sort((a, b) => a.display_order - b.display_order)
        .map((p) => ({
          id: p.id,
          photo_uri: p.photo_uri,
          display_order: p.display_order,
          is_primary: p.is_primary,
          is_face_verified: p.is_face_verified,
        }));
    }
    if (!isMatched) {
      isMatched = !!db.getActiveMatch(requesterId, targetUserId);
    }

    if (!targetUser || targetUser.account_status !== 'active') {
      throw new NotFoundException('User profile not found or inactive');
    }
    if (!targetProfile) {
      throw new NotFoundException('User profile not found');
    }

    // 3. Visibility Rules & Masking
    const visibility = targetProfile.profile_visibility || 'everyone';

    if (visibility === 'hidden') {
      throw new NotFoundException('This user profile is private');
    }

    const isLimitedAndUnmatched = visibility === 'limited' && !isMatched;

    // Calculate age
    let age: number | undefined;
    if (targetProfile.date_of_birth) {
      const dob = new Date(targetProfile.date_of_birth);
      if (!isNaN(dob.getTime())) {
        const today = new Date();
        age = today.getFullYear() - dob.getFullYear();
        const m = today.getMonth() - dob.getMonth();
        if (m < 0 || (m === 0 && today.getDate() < dob.getDate())) {
          age--;
        }
      }
    }

    // Filter photos if limited & unmatched: only primary photo visible
    const visiblePhotos = isLimitedAndUnmatched
      ? targetPhotos.filter((p) => p.is_primary).slice(0, 1)
      : targetPhotos;

    return {
      success: true,
      user_id: targetUserId,
      nickname: targetProfile.nickname,
      first_name: targetProfile.first_name,
      age,
      gender: targetProfile.gender,
      bio: targetProfile.bio,
      profession: targetProfile.profession,
      education: targetProfile.education,
      city: isLimitedAndUnmatched ? undefined : targetProfile.city,
      country_code: targetProfile.country_code,
      interests: targetProfile.interests || [],
      languages: targetProfile.languages || [],
      looking_for: isLimitedAndUnmatched ? [] : (targetProfile.looking_for || []),
      sexual_orientations: isLimitedAndUnmatched ? [] : (targetProfile.sexual_orientations || []),
      avatar_object_key: targetProfile.avatar_object_key,
      is_verified: !!targetProfile.is_verified,
      verification_status: targetProfile.verification_status || 'not_started',
      is_voice_verified: !!targetProfile.is_voice_verified,
      liveness_verified: !!targetProfile.liveness_verified,
      profile_progress: targetProfile.profile_progress ?? 0,
      photos: visiblePhotos,
      is_matched: isMatched,
      visibility,
    };
  }
}

