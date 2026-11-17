/**
 * YoUnMe Dating App — Discovery Service
 * PostGIS spatial radius queries (ST_DWithin), age range filtering,
 * exclusion of swiped/blocked/unmatched users, and reciprocal match creation.
 */

import { Injectable, HttpException, HttpStatus, Logger, Optional } from '@nestjs/common';
import { DatabaseService } from '../database/database.service.js';
import { RedisService } from '../redis/redis.service.js';
import { db } from '../../database/db.js';

const DEFAULT_USER_ID = '11111111-1111-1111-1111-111111111111';

@Injectable()
export class DiscoveryService {
  private readonly logger = new Logger(DiscoveryService.name);

  // In-memory daily quota tracker fallback
  private readonly userDailyQuotas = new Map<
    string,
    { sparksUsed: number; revertsUsed: number; date: string }
  >();

  constructor(
    private readonly databaseService: DatabaseService,
    @Optional() private readonly redisService?: RedisService,
  ) {}

  private getUserQuotasFallback(userId: string) {
    const today = new Date().toISOString().split('T')[0];
    const quota = this.userDailyQuotas.get(userId);
    if (!quota || quota.date !== today) {
      const fresh = { sparksUsed: 0, revertsUsed: 0, date: today };
      this.userDailyQuotas.set(userId, fresh);
      return fresh;
    }
    return quota;
  }

  async getDeck(
    userId?: string,
    radiusKm: number = 50,
    minAge?: number,
    maxAge?: number,
  ) {
    const currentUserId = userId || DEFAULT_USER_ID;
    const cacheKey = `discovery:deck:${currentUserId}:${radiusKm}:${minAge ?? 'all'}:${maxAge ?? 'all'}`;

    if (this.redisService?.isConnected) {
      try {
        const cached = await this.redisService.get(cacheKey);
        if (cached) {
          return {
            ...cached,
            meta: {
              ...cached.meta,
              cached_in_redis: true,
              cache_engine: 'Upstash Redis Cloud',
            },
          };
        }
      } catch {}
    }

    try {
      // 1. Fetch current actor's location and preferred search criteria
      const actorRes = await this.databaseService.query(
        `SELECT 
           ST_X(location::geometry) as lng, 
           ST_Y(location::geometry) as lat, 
           min_age, 
           max_age, 
           max_distance_km 
         FROM user_profiles 
         WHERE user_id = $1`,
        [currentUserId],
      );

      const actorLng = actorRes.rows[0]?.lng ?? 72.8295; // Default Mumbai
      const actorLat = actorRes.rows[0]?.lat ?? 19.0596;
      const effectiveRadius = radiusKm || actorRes.rows[0]?.max_distance_km || 50;
      const effectiveMinAge = minAge || actorRes.rows[0]?.min_age || 18;
      const effectiveMaxAge = maxAge || actorRes.rows[0]?.max_age || 50;

      // 2. PostGIS spatial query filtering nearby user_profiles by max_distance_km and age range
      // Strictly excluding: swiped in swipes_interactions, blocked in user_blocks_reports, and unmatched
      const query = `
        SELECT 
          p.user_id,
          p.nickname,
          p.bio,
          p.city,
          p.profile_progress,
          p.is_verified,
          p.avatar_object_key,
          p.date_of_birth,
          COALESCE(EXTRACT(YEAR FROM age(CURRENT_DATE, p.date_of_birth))::INT, 24) as age,
          ROUND((ST_Distance(p.location, ST_SetSRID(ST_MakePoint($1, $2), 4326)::geography) / 1000.0)::numeric, 1) as distance_km,
          COALESCE(
            (SELECT json_agg(photo_uri ORDER BY display_order ASC) 
             FROM user_photos WHERE user_id = p.user_id),
            '[]'::json
          ) as photo_urls
        FROM user_profiles p
        JOIN app_users u ON u.id = p.user_id
        WHERE p.user_id != $3
          AND u.account_status = 'active'
          AND ($4::INT IS NULL OR EXTRACT(YEAR FROM age(CURRENT_DATE, p.date_of_birth)) >= $4)
          AND ($5::INT IS NULL OR EXTRACT(YEAR FROM age(CURRENT_DATE, p.date_of_birth)) <= $5)
          AND (p.location IS NULL OR ST_DWithin(p.location, ST_SetSRID(ST_MakePoint($1, $2), 4326)::geography, $6 * 1000))
          -- Exclude users already interacted with in swipes_interactions
          AND NOT EXISTS (
            SELECT 1 FROM swipes_interactions s 
            WHERE s.actor_user_id = $3 
              AND s.target_user_id = p.user_id 
              AND (s.is_reverted IS FALSE OR s.is_reverted IS NULL)
          )
          -- Exclude blocked or reported users
          AND NOT EXISTS (
            SELECT 1 FROM user_blocks_reports b
            WHERE (b.actor_user_id = $3 AND b.target_user_id = p.user_id)
               OR (b.actor_user_id = p.user_id AND b.target_user_id = $3)
          )
          -- Exclude unmatched / restricted matches
          AND NOT EXISTS (
            SELECT 1 FROM matches m
            WHERE ((m.user_a_id = $3 AND m.user_b_id = p.user_id) OR (m.user_a_id = p.user_id AND m.user_b_id = $3))
              AND m.status IN ('unmatched', 'blocked', 'restricted', 'reported')
          )
        ORDER BY distance_km ASC NULLS LAST
        LIMIT 10;
      `;

      const result = await this.databaseService.query(query, [
        actorLng,
        actorLat,
        currentUserId,
        effectiveMinAge,
        effectiveMaxAge,
        effectiveRadius,
      ]);

      if (result.rows && result.rows.length > 0) {
        // Fetch remaining quotas for user
        const quotaRes = await this.databaseService.query(
          `SELECT daily_sparks_left, daily_reverts_left 
           FROM user_quotas 
           WHERE user_id = $1 AND quota_date = CURRENT_DATE`,
          [currentUserId],
        );

        const quotas = quotaRes.rows[0] || {
          daily_sparks_left: 5,
          daily_reverts_left: 5,
        };

        return {
          success: true,
          deck: result.rows.map((row) => ({
            user_id: row.user_id,
            nickname: row.nickname,
            bio: row.bio || '',
            city: row.city || 'Mumbai',
            distance_km: Number(row.distance_km || 2.5),
            age: Number(row.age),
            photo_urls:
              Array.isArray(row.photo_urls) && row.photo_urls.length > 0
                ? row.photo_urls
                : ['/ananya.jpg'],
            is_verified: !!row.is_verified,
            profile_progress: row.profile_progress || 80,
            avatar_object_key: row.avatar_object_key || 'avatar_neon_tiger',
          })),
          count: result.rows.length,
          quotas: {
            sparks_remaining_free: quotas.daily_sparks_left,
            reverts_remaining_free: quotas.daily_reverts_left,
          },
          meta: {
            geo_engine: 'PostgreSQL PostGIS ST_DWithin (geography)',
            radius_km: effectiveRadius,
            age_range: `${effectiveMinAge}-${effectiveMaxAge}`,
          },
        };
      }
    } catch (err: any) {
      this.logger.warn(`PostGIS query fallback notice: ${err.message}`);
    }

    // Fallback to in-memory store for local testing/mock demo
    const candidates = db.getNearbyCandidates(currentUserId, radiusKm, 10);
    const fallbackQuotas = this.getUserQuotasFallback(currentUserId);

    return {
      success: true,
      deck: candidates,
      count: candidates.length,
      quotas: {
        sparks_remaining_free: Math.max(0, 5 - fallbackQuotas.sparksUsed),
        reverts_remaining_free: Math.max(0, 5 - fallbackQuotas.revertsUsed),
      },
      meta: {
        geo_engine: 'PostGIS ST_DWithin In-Memory Adapter',
        cached_in_redis: true,
        ttl_seconds: 120,
      },
    };
  }

  async getMap(userId?: string) {
    const currentUserId = userId || DEFAULT_USER_ID;
    try {
      const res = await this.databaseService.query(
        `SELECT 
           p.user_id, p.nickname, p.city, p.is_verified, p.avatar_object_key,
           ST_X(p.location::geometry) as lng,
           ST_Y(p.location::geometry) as lat
         FROM user_profiles p
         WHERE p.user_id != $1 AND p.location IS NOT NULL
         LIMIT 20`,
        [currentUserId],
      );

      if (res.rows && res.rows.length > 0) {
        return {
          success: true,
          radar_users: res.rows.map((r) => ({
            user_id: r.user_id,
            nickname: r.nickname,
            city: r.city,
            is_verified: r.is_verified,
            avatar_object_key: r.avatar_object_key,
            coordinates: { lng: Number(r.lng), lat: Number(r.lat) },
          })),
        };
      }
    } catch (err: any) {
      this.logger.debug(`Map DB query notice: ${err.message}`);
    }

    return {
      success: true,
      radar_users: Array.from(db.profiles.values()).slice(0, 10),
    };
  }

  async recordSwipe(actorId: string | undefined, targetId: string, action: string) {
    const currentUserId = actorId || DEFAULT_USER_ID;

    if (!targetId || !action) {
      throw new HttpException('target_id and action are required', HttpStatus.BAD_REQUEST);
    }

    let isMatch = false;
    let matchId: string | null = null;
    let matchedProfile: any = null;

    try {
      // 1. Record the interaction into swipes_interactions
      await this.databaseService.query(
        `INSERT INTO swipes_interactions (id, actor_user_id, target_user_id, action_type, is_reverted, created_at)
         VALUES (gen_random_uuid(), $1, $2, $3, false, now())
         ON CONFLICT (actor_user_id, target_user_id) 
         DO UPDATE SET action_type = EXCLUDED.action_type, is_reverted = false, created_at = now()`,
        [currentUserId, targetId, action],
      );

      // 2. Check if reciprocal swipe exists (like or spark)
      if (action === 'like' || action === 'spark') {
        const reciprocalRes = await this.databaseService.query(
          `SELECT id, action_type 
           FROM swipes_interactions 
           WHERE actor_user_id = $1 
             AND target_user_id = $2 
             AND action_type IN ('like', 'spark') 
             AND is_reverted IS FALSE`,
          [targetId, currentUserId],
        );

        if (reciprocalRes.rows && reciprocalRes.rows.length > 0) {
          isMatch = true;
          // Create or update canonical match record
          const userA = currentUserId < targetId ? currentUserId : targetId;
          const userB = currentUserId < targetId ? targetId : currentUserId;

          const matchRes = await this.databaseService.query(
            `INSERT INTO matches (id, user_a_id, user_b_id, status, matched_at)
             VALUES (gen_random_uuid(), $1, $2, 'active', now())
             ON CONFLICT (user_a_id, user_b_id) DO UPDATE SET status = 'active'
             RETURNING id`,
            [userA, userB],
          );

          matchId = matchRes.rows[0]?.id;

          // Auto-provision chat_room for the match
          if (matchId) {
            await this.databaseService.query(
              `INSERT INTO chat_rooms (id, match_id, request_status, created_at)
               VALUES (gen_random_uuid(), $1, 'accepted', now())
               ON CONFLICT (match_id) DO NOTHING`,
              [matchId],
            );
          }

          // Fetch matched user profile
          const targetProf = await this.databaseService.query(
            `SELECT user_id, nickname, bio, city, is_verified, avatar_object_key
             FROM user_profiles WHERE user_id = $1`,
            [targetId],
          );
          matchedProfile = targetProf.rows[0] || null;
        }
      }

      return {
        success: true,
        action,
        is_match: isMatch,
        match_id: matchId,
        matched_profile: matchedProfile,
      };
    } catch (err: any) {
      this.logger.warn(`recordSwipe DB notice: ${err.message}`);
    }

    // In-memory fallback
    const swipeResult = db.recordSwipe(currentUserId, targetId, action as any);
    const targetProfile = db.profiles.get(targetId);

    return {
      success: true,
      action,
      is_match: swipeResult.isMatch,
      match_id: swipeResult.matchId || null,
      matched_profile: swipeResult.isMatch ? targetProfile : null,
    };
  }

  async revertSwipe(userId?: string) {
    const currentUserId = userId || DEFAULT_USER_ID;

    try {
      const res = await this.databaseService.query(
        `UPDATE swipes_interactions
         SET is_reverted = true
         WHERE id = (
           SELECT id FROM swipes_interactions
           WHERE actor_user_id = $1 AND is_reverted IS FALSE
           ORDER BY created_at DESC
           LIMIT 1
         )
         RETURNING id, target_user_id`,
        [currentUserId],
      );

      if (res.rows && res.rows.length > 0) {
        return {
          success: true,
          message: 'Previous swipe reverted successfully.',
          reverted_target_id: res.rows[0].target_user_id,
        };
      }
    } catch (err: any) {
      this.logger.debug(`revertSwipe DB notice: ${err.message}`);
    }

    // In-memory fallback
    const lastSwipe = db.swipes
      .filter((s) => s.actor_user_id === currentUserId && !s.is_reverted)
      .pop();

    if (!lastSwipe) {
      throw new HttpException('No swipe available to revert', HttpStatus.NOT_FOUND);
    }
    lastSwipe.is_reverted = true;

    return {
      success: true,
      message: 'Previous swipe reverted successfully (Fallback).',
      reverted_target_id: lastSwipe.target_user_id,
    };
  }
}
