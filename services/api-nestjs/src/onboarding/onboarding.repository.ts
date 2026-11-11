/**
 * YoUnMe Dating App — Onboarding Repository
 * Provides both In-Memory (development/mock) and PostgreSQL (production) implementations.
 * Aligned with 24-table schema v3.2 (app_users + user_profiles).
 */

import { Injectable } from '@nestjs/common';
import {
  IOnboardingRepository,
  IProfileState,
  IUserAttributes,
} from './interfaces/onboarding.interface.js';
import { db } from '../database/db.js';

export const ONBOARDING_REPOSITORY_TOKEN = 'ONBOARDING_REPOSITORY';

/**
 * In-Memory Adapter: Reads and writes to the centralized DB store
 */
@Injectable()
export class InMemoryOnboardingRepository implements IOnboardingRepository {
  public async findUserById(userId: string): Promise<IUserAttributes | null> {
    const user = db.users.get(userId);
    if (!user) return null;
    // Map AppUser → IUserAttributes
    return {
      id: user.id,
      authentication_uid: user.authentication_uid,
      email: user.email,
      email_verified: user.email_verified,
      phone_country_code: user.phone_country_code,
      phone_number: user.phone_number,
      full_phone_number: user.full_phone_number,
      phone_verified: user.phone_verified,
      google_sso_id: user.google_sso_id,
      apple_sso_id: user.apple_sso_id,
      password_hash: user.password_hash,
      account_status: user.account_status,
      deactivation_reason: user.deactivation_reason,
      deletion_reason: user.deletion_reason,
      deactivated_at: user.deactivated_at,
      deletion_scheduled_at: user.deletion_scheduled_at,
      reactivate_after: user.reactivate_after,
      role: user.role,
      referral_code: user.referral_code,
      referred_by_user_id: user.referred_by_user_id,
      created_at: user.created_at,
      updated_at: user.updated_at,
      deleted_at: user.deleted_at,
    };
  }

  public async findProfileByUserId(userId: string): Promise<IProfileState | null> {
    const profile = db.profiles.get(userId);
    if (!profile) return null;
    // Map UserProfile → IProfileState
    return {
      user_id: profile.user_id,
      first_name: profile.first_name,
      nickname: profile.nickname,
      date_of_birth: profile.date_of_birth,
      gender: profile.gender as any,
      sexual_orientations: profile.sexual_orientations,
      looking_for: profile.looking_for,
      languages: profile.languages,
      interests: profile.interests,
      bio: profile.bio,
      profession: profile.profession,
      education: profile.education,
      city: profile.city,
      country_code: profile.country_code,
      avatar_object_key: profile.avatar_object_key,
      random_avatar_object_key: profile.random_avatar_object_key,
      app_language: profile.app_language,
      app_theme: profile.app_theme,
      chat_lock_passcode_hash: profile.chat_lock_passcode_hash,
      read_receipts_status: profile.read_receipts_status,
      profile_visibility: profile.profile_visibility,
      show_online_status: profile.show_online_status,
      who_can_message: profile.who_can_message,
      who_can_message_request: profile.who_can_message_request,
      push_notifications_enabled: profile.push_notifications_enabled,
      push_notifications: profile.push_notifications,
      email_notifications_enabled: profile.email_notifications_enabled,
      email_notifications: profile.email_notifications,
      min_age: profile.min_age,
      max_age: profile.max_age,
      max_distance_km: profile.max_distance_km,
      is_verified: profile.is_verified,
      verification_status: profile.verification_status,
      is_voice_verified: profile.is_voice_verified,
      liveness_verified: profile.liveness_verified,
      face_embedding_vector: profile.face_embedding_vector,
      profile_progress: profile.profile_progress,
      location: profile.location,
      location_updated_at: profile.location_updated_at,
      last_active_at: profile.last_active_at,
      created_at: profile.created_at,
      updated_at: profile.updated_at,
    };
  }

  public async upsertProfile(
    userId: string,
    partial: Partial<IProfileState>
  ): Promise<IProfileState> {
    const existing = db.profiles.get(userId);
    const now = new Date().toISOString();

    const base: IProfileState = existing
      ? await this.findProfileByUserId(userId) as IProfileState
      : {
          user_id: userId,
          nickname: 'New User',
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
          min_age: 18,
          max_age: 50,
          max_distance_km: 50,
          is_verified: false,
          verification_status: 'not_started',
          is_voice_verified: false,
          liveness_verified: false,
          profile_progress: 0,
          location: { lat: 19.0596, lng: 72.8295 },
          created_at: now,
          updated_at: now,
        };

    const updated: IProfileState = { ...base, ...partial, updated_at: now };

    // Write back to in-memory store
    db.profiles.set(userId, updated);

    return { ...updated };
  }

  public async updateUser(
    userId: string,
    partial: Partial<IUserAttributes>
  ): Promise<IUserAttributes | null> {
    const user = db.users.get(userId);
    if (!user) return null;

    const updated = {
      ...user,
      ...partial,
      updated_at: new Date().toISOString(),
    };
    db.users.set(userId, updated as any);
    return this.findUserById(userId);
  }

  public async replacePhotos(userId: string, photoUrls: string[]): Promise<void> {
    const now = new Date().toISOString();
    db.photos.set(
      userId,
      photoUrls.slice(0, 7).map((photoUri, index) => ({
        id: `photo_${userId.slice(0, 4)}_${index + 1}`,
        user_id: userId,
        photo_uri: photoUri,
        display_order: index + 1,
        is_primary: index === 0,
        is_face_verified: false,
        comments_json: {},
        moderation_status: 'pending' as const,
        created_at: now,
        updated_at: now,
      })),
    );
  }

  public async countPhotos(userId: string): Promise<number> {
    return (db.photos.get(userId) || []).length;
  }
}

import { Optional } from '@nestjs/common';
import { DatabaseService } from '../modules/database/database.service.js';

/**
 * Production PostgreSQL + PostGIS Repository
 * Connects directly to Supabase PostgreSQL when available, with graceful fallback.
 */
@Injectable()
export class PostgresOnboardingRepository implements IOnboardingRepository {
  private readonly fallback = new InMemoryOnboardingRepository();

  constructor(@Optional() private readonly dbService?: DatabaseService) {}

  public async findUserById(userId: string): Promise<IUserAttributes | null> {
    if (this.dbService?.isConnected) {
      try {
        const res = await this.dbService.query(
          `SELECT id, authentication_uid, email, email_verified, phone_country_code, phone_number,
                  full_phone_number, phone_verified, account_status, role, referral_code,
                  referred_by_user_id, created_at, updated_at
           FROM app_users WHERE id = $1 LIMIT 1`,
          [userId],
        );
        if (res.rows.length > 0) {
          return res.rows[0];
        }
      } catch (err: any) {
        // Fall back to in-memory if query fails
      }
    }
    return this.fallback.findUserById(userId);
  }

  public async findProfileByUserId(userId: string): Promise<IProfileState | null> {
    if (this.dbService?.isConnected) {
      try {
        const res = await this.dbService.query(
          `SELECT user_id, first_name, nickname, date_of_birth, gender,
                  sexual_orientations, looking_for, languages, interests, bio,
                  profession, education, city, country_code, avatar_object_key,
                  is_verified, verification_status, is_voice_verified, liveness_verified,
                  profile_progress, created_at, updated_at
           FROM user_profiles WHERE user_id = $1 LIMIT 1`,
          [userId],
        );
        if (res.rows.length > 0) {
          const row = res.rows[0];
          return {
            ...row,
            sexual_orientations: row.sexual_orientations || [],
            looking_for: row.looking_for || [],
            languages: row.languages || [],
            interests: row.interests || [],
            profile_progress: row.profile_progress ?? 0,
            is_verified: !!row.is_verified,
            liveness_verified: !!row.liveness_verified,
          };
        }
      } catch (err: any) {
        // Fall back to in-memory if query fails
      }
    }
    return this.fallback.findProfileByUserId(userId);
  }

  public async upsertProfile(
    userId: string,
    partial: Partial<IProfileState>,
  ): Promise<IProfileState> {
    if (this.dbService?.isConnected) {
      try {
        const existing = await this.findProfileByUserId(userId);
        const merged = { ...existing, ...partial };

        const query = `
          INSERT INTO user_profiles (
            user_id, nickname, bio, city, gender,
            is_verified, liveness_verified, profile_progress, updated_at
          ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, now())
          ON CONFLICT (user_id) DO UPDATE SET
            nickname = COALESCE($2, user_profiles.nickname),
            bio = COALESCE($3, user_profiles.bio),
            city = COALESCE($4, user_profiles.city),
            gender = COALESCE($5, user_profiles.gender),
            is_verified = COALESCE($6, user_profiles.is_verified),
            liveness_verified = COALESCE($7, user_profiles.liveness_verified),
            profile_progress = COALESCE($8, user_profiles.profile_progress),
            updated_at = now()
          RETURNING *;
        `;
        const res = await this.dbService.query(query, [
          userId,
          merged.nickname || 'User',
          merged.bio || null,
          merged.city || null,
          merged.gender || null,
          merged.is_verified ?? false,
          merged.liveness_verified ?? false,
          merged.profile_progress ?? 0,
        ]);
        if (res.rows.length > 0) {
          const row = res.rows[0];
          this.fallback.upsertProfile(userId, partial);
          return {
            ...row,
            profile_progress: row.profile_progress ?? 0,
            is_verified: !!row.is_verified,
            liveness_verified: !!row.liveness_verified,
          };
        }
      } catch (err: any) {
        // Fall back to in-memory if DB update fails
      }
    }
    return this.fallback.upsertProfile(userId, partial);
  }

  public async updateUser(
    userId: string,
    partial: Partial<IUserAttributes>,
  ): Promise<IUserAttributes | null> {
    if (this.dbService?.isConnected) {
      try {
        const query = `
          UPDATE app_users 
          SET updated_at = now()
          WHERE id = $1
          RETURNING *;
        `;
        const res = await this.dbService.query(query, [userId]);
        if (res.rows.length > 0) {
          this.fallback.updateUser(userId, partial);
          return res.rows[0];
        }
      } catch (err: any) {}
    }
    return this.fallback.updateUser(userId, partial);
  }

  public async replacePhotos(userId: string, photoUrls: string[]): Promise<void> {
    if (this.dbService?.isConnected) {
      try {
        await this.dbService.query(`DELETE FROM user_photos WHERE user_id = $1`, [userId]);
        for (let i = 0; i < Math.min(photoUrls.length, 7); i++) {
          await this.dbService.query(
            `INSERT INTO user_photos (user_id, photo_uri, display_order, is_primary, moderation_status)
             VALUES ($1, $2, $3, $4, 'approved')`,
            [userId, photoUrls[i], i + 1, i === 0],
          );
        }
      } catch (err: any) {}
    }
    return this.fallback.replacePhotos(userId, photoUrls);
  }

  public async countPhotos(userId: string): Promise<number> {
    if (this.dbService?.isConnected) {
      try {
        const res = await this.dbService.query(
          `SELECT COUNT(*)::int as count FROM user_photos WHERE user_id = $1`,
          [userId],
        );
        if (res.rows.length > 0) {
          return parseInt(res.rows[0].count, 10);
        }
      } catch (err: any) {}
    }
    return this.fallback.countPhotos(userId);
  }
}
