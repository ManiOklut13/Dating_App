import { Router, Request, Response } from 'express';
import { db } from '../../../database/db.js';

export const homeRouter = Router();

// In-memory streak state
const userStreaks = new Map<string, { current_streak: number; last_spin: string }>();

/**
 * GET /v1/home/feed
 * Home & Engagement summary: wallet header, streaks, spin-wheel status, icebreakers, Top Picks
 */
homeRouter.get('/feed', (req: Request, res: Response) => {
  const userId = (req.query.user_id as string) || '11111111-1111-1111-1111-111111111111';
  const wallet = db.wallets.get(userId) || { user_id: userId, balance: 250, updated_at: new Date().toISOString() };
  const profile = db.profiles.get(userId);

  let streakData = userStreaks.get(userId);
  if (!streakData) {
    streakData = { current_streak: 4, last_spin: '' };
    userStreaks.set(userId, streakData);
  }

  const today = new Date().toISOString().split('T')[0];
  const canSpin = streakData.last_spin !== today;

  const icebreakers = [
    { id: 'ib_1', prompt: 'Subko Coffee or Blue Tokai?', response_type: 'poll', category: 'lifestyle' },
    { id: 'ib_2', prompt: 'Best sunset spot in Mumbai?', response_type: 'text', category: 'travel' },
    { id: 'ib_3', prompt: 'What song is stuck in your head today?', response_type: 'audio', category: 'music' },
  ];

  // Top Picks feed (curated high-vibe matches)
  const candidates = db.getNearbyCandidates(userId, 50, 4);

  return res.json({
    success: true,
    wallet_header: {
      balance: wallet.balance,
      currency: 'YoUnMe Coins',
    },
    streak: {
      current_days: streakData.current_streak,
      fire_level: streakData.current_streak >= 7 ? 'super_flame' : 'active_flame',
      spin_available: canSpin,
      multiplier: 1 + streakData.current_streak * 0.1, // e.g. 1.4x at Day 4
    },
    profile_completion_nudge: {
      percentage: profile?.profile_progress || 0,
      show_nudge: (profile?.profile_progress || 0) < 100,
      missing_highlight: (profile?.profile_progress || 0) < 70 ? 'Complete 70% to unlock Blue Tick!' : 'Add voice intro!',
    },
    icebreakers,
    top_picks: candidates,
  });
});

/**
 * POST /v1/home/spin-wheel
 * Spin-wheel daily reward multiplier
 */
homeRouter.post('/spin-wheel', (req: Request, res: Response) => {
  const { user_id } = req.body;
  const currentUserId = user_id || '11111111-1111-1111-1111-111111111111';

  let streak = userStreaks.get(currentUserId);
  if (!streak) {
    streak = { current_streak: 4, last_spin: '' };
    userStreaks.set(currentUserId, streak);
  }

  const today = new Date().toISOString().split('T')[0];
  if (streak.last_spin === today) {
    return res.status(400).json({
      error: 'SPIN_ALREADY_CLAIMED',
      message: 'Daily spin wheel already claimed today. Come back tomorrow!',
    });
  }

  // Random base reward: 10, 20, 25, 50 coins
  const rewards = [10, 15, 20, 25, 50];
  const baseCoins = rewards[Math.floor(Math.random() * rewards.length)];
  const multiplier = 1 + streak.current_streak * 0.1;
  const awardedCoins = Math.round(baseCoins * multiplier);

  streak.last_spin = today;
  streak.current_streak += 1;

  try {
    const result = db.executeCoinTransaction(
      currentUserId,
      'grant',
      awardedCoins,
      `daily_spin_day_${streak.current_streak}`,
      `tx_spin_${currentUserId}_${today}`
    );

    return res.json({
      success: true,
      base_coins: baseCoins,
      multiplier: Math.round(multiplier * 10) / 10,
      awarded_coins: awardedCoins,
      new_balance: result.balance,
      streak_days: streak.current_streak,
      message: `🎉 Won ${awardedCoins} coins with a ${Math.round(multiplier * 10) / 10}x streak multiplier!`,
    });
  } catch (err: any) {
    return res.status(500).json({ error: err.message });
  }
});
