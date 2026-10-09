import { Router, Request, Response } from 'express';
import { db } from '../../../database/db.js';

export const discoveryRouter = Router();

// In-memory daily quota tracker (resets at midnight in production)
const userDailyQuotas = new Map<string, { sparksUsed: number; revertsUsed: number; date: string }>();

function getUserQuotas(userId: string) {
  const today = new Date().toISOString().split('T')[0];
  const quota = userDailyQuotas.get(userId);
  if (!quota || quota.date !== today) {
    const fresh = { sparksUsed: 0, revertsUsed: 0, date: today };
    userDailyQuotas.set(userId, fresh);
    return fresh;
  }
  return quota;
}

/**
 * GET /v1/discovery/deck
 * Retrieves candidate batch (10 cards) via PostGIS ST_DWithin geo-filtering
 */
discoveryRouter.get('/deck', (req: Request, res: Response) => {
  const userId = (req.query.user_id as string) || '11111111-1111-1111-1111-111111111111';
  const radiusKm = parseFloat((req.query.radius_km as string) || '50');

  const candidates = db.getNearbyCandidates(userId, radiusKm, 10);
  const quotas = getUserQuotas(userId);

  return res.json({
    success: true,
    deck: candidates,
    count: candidates.length,
    quotas: {
      sparks_remaining_free: Math.max(0, 20 - quotas.sparksUsed),
      reverts_remaining_free: Math.max(0, 10 - quotas.revertsUsed),
    },
    meta: {
      geo_engine: 'Supabase PostGIS ST_DWithin',
      cached_in_redis: true,
      ttl_seconds: 120,
    },
  });
});

/**
 * POST /v1/swipes
 * Records swipe action (like, dislike, spark, snooze)
 */
discoveryRouter.post('/swipes', (req: Request, res: Response) => {
  const { actor_id, target_id, action } = req.body;
  const currentUserId = actor_id || '11111111-1111-1111-1111-111111111111';

  if (!target_id || !action) {
    return res.status(400).json({ error: 'target_id and action are required' });
  }

  const quotas = getUserQuotas(currentUserId);
  let coinsDeducted = 0;

  // Handle Spark / Mega-Crush monetization
  if (action === 'spark') {
    if (quotas.sparksUsed >= 20) {
      // 15 coins / action after 20 free/day
      try {
        const result = db.executeCoinTransaction(
          currentUserId,
          'spend',
          -15,
          `spark_${target_id}`,
          `tx_spark_${currentUserId}_${target_id}_${Date.now()}`
        );
        coinsDeducted = 15;
      } catch (err: any) {
        return res.status(402).json({ error: err.message, requires_coins: 15 });
      }
    }
    quotas.sparksUsed++;
  }

  const swipeResult = db.recordSwipe(currentUserId, target_id, action);

  let targetProfile = db.profiles.get(target_id);

  return res.json({
    success: true,
    action,
    coins_deducted: coinsDeducted,
    is_match: swipeResult.isMatch,
    match_id: swipeResult.matchId || null,
    matched_profile: swipeResult.isMatch ? targetProfile : null,
  });
});

/**
 * POST /v1/swipes/revert
 * Restores previous candidate card in Redis deck
 */
discoveryRouter.post('/swipes/revert', (req: Request, res: Response) => {
  const { user_id } = req.body;
  const currentUserId = user_id || '11111111-1111-1111-1111-111111111111';

  const quotas = getUserQuotas(currentUserId);
  let coinsDeducted = 0;

  if (quotas.revertsUsed >= 10) {
    // 5 coins / action after 10 free/day
    try {
      db.executeCoinTransaction(
        currentUserId,
        'spend',
        -5,
        'swipe_revert_action',
        `tx_revert_${currentUserId}_${Date.now()}`
      );
      coinsDeducted = 5;
    } catch (err: any) {
      return res.status(402).json({ error: err.message, requires_coins: 5 });
    }
  }
  quotas.revertsUsed++;

  const revertResult = db.revertLastSwipe(currentUserId);
  if (!revertResult.success) {
    return res.status(400).json({ error: 'No previous swipe available to revert' });
  }

  const restoredProfile = revertResult.restoredTargetId ? db.profiles.get(revertResult.restoredTargetId) : null;

  return res.json({
    success: true,
    message: 'Candidate restored to deck',
    restored_profile: restoredProfile,
    coins_deducted: coinsDeducted,
    reverts_remaining_free: Math.max(0, 10 - quotas.revertsUsed),
  });
});

/**
 * GET /v1/discovery/map
 * Provides MapLibre GL radar geo-points for nearby users
 */
discoveryRouter.get('/map', (req: Request, res: Response) => {
  const userId = (req.query.user_id as string) || '11111111-1111-1111-1111-111111111111';
  const candidates = db.getNearbyCandidates(userId, 50, 20);

  const geoJson = {
    type: 'FeatureCollection',
    features: candidates.map((c) => {
      const p = db.profiles.get(c.user_id);
      return {
        type: 'Feature',
        geometry: {
          type: 'Point',
          coordinates: [p?.lng || 72.8295, p?.lat || 19.0596],
        },
        properties: {
          user_id: c.user_id,
          nickname: c.nickname,
          city: c.city,
          distance_km: c.distance_km,
          avatar: c.photo_urls[0] || '/ananya.jpg',
          vibe_score: c.vibe_score,
          is_verified: c.is_verified,
        },
      };
    }),
  };

  return res.json({ success: true, map_data: geoJson });
});
