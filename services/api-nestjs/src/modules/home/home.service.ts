/**
 * YoUnMe Dating App — Home Service
 * Engagement feed, daily streaks, and spin-wheel rewards.
 */

import { Injectable, HttpException, HttpStatus } from '@nestjs/common';
import { db } from '../../database/db.js';

const DEFAULT_USER_ID = '11111111-1111-1111-1111-111111111111';

@Injectable()
export class HomeService {
  private readonly userStreaks = new Map<
    string,
    { current_streak: number; last_spin: string }
  >();

  private getStreak(userId: string) {
    let streakData = this.userStreaks.get(userId);
    if (!streakData) {
      streakData = { current_streak: 4, last_spin: '' };
      this.userStreaks.set(userId, streakData);
    }
    return streakData;
  }

  getFeed(userId?: string) {
    const currentUserId = userId || DEFAULT_USER_ID;
    const wallet = db.wallets.get(currentUserId) || {
      user_id: currentUserId,
      coin_balance: 250,
      locked_coins: 0,
      lifetime_earned_coins: 250,
      lifetime_spent_coins: 0,
      current_streak_days: 0,
      longest_streak_days: 0,
      updated_at: new Date().toISOString(),
    };
    const profile = db.profiles.get(currentUserId);
    const streakData = this.getStreak(currentUserId);

    const today = new Date().toISOString().split('T')[0];
    const canSpin = streakData.last_spin !== today;

    const icebreakers = [
      { id: 'ib_1', prompt: 'Subko Coffee or Blue Tokai?', response_type: 'poll', category: 'lifestyle' },
      { id: 'ib_2', prompt: 'Best sunset spot in Mumbai?', response_type: 'text', category: 'travel' },
      { id: 'ib_3', prompt: 'What song is stuck in your head today?', response_type: 'audio', category: 'music' },
    ];

    const candidates = db.getNearbyCandidates(currentUserId, 50, 4);

    return {
      success: true,
      wallet_header: {
        balance: wallet.coin_balance,
        currency: 'YoUnMe Coins',
      },
      streak: {
        current_days: streakData.current_streak,
        fire_level: streakData.current_streak >= 7 ? 'super_flame' : 'active_flame',
        spin_available: canSpin,
        multiplier: 1 + streakData.current_streak * 0.1,
      },
      profile_completion_nudge: {
        percentage: profile?.profile_progress || 0,
        show_nudge: (profile?.profile_progress || 0) < 100,
        missing_highlight:
          (profile?.profile_progress || 0) < 70
            ? 'Complete 70% to unlock Blue Tick!'
            : 'Add more profile photos!',
      },
      icebreakers,
      top_picks: candidates,
    };
  }

  spinWheel(userId?: string) {
    const currentUserId = userId || DEFAULT_USER_ID;
    const streak = this.getStreak(currentUserId);

    const today = new Date().toISOString().split('T')[0];
    if (streak.last_spin === today) {
      throw new HttpException(
        {
          error: 'SPIN_ALREADY_CLAIMED',
          message: 'Daily spin wheel already claimed today. Come back tomorrow!',
        },
        HttpStatus.BAD_REQUEST,
      );
    }

    const rewards = [10, 15, 20, 25, 50];
    const baseCoins = rewards[Math.floor(Math.random() * rewards.length)];
    const multiplier = 1 + streak.current_streak * 0.1;
    const awardedCoins = Math.round(baseCoins * multiplier);

    streak.last_spin = today;
    streak.current_streak += 1;

    try {
      const result = db.executeCoinTransaction(
        currentUserId,
        'incoming',
        'spin_wheel_coins_earned',
        awardedCoins,
      );

      return {
        success: true,
        base_coins: baseCoins,
        multiplier: Math.round(multiplier * 10) / 10,
        awarded_coins: awardedCoins,
        new_balance: result.balance,
        streak_days: streak.current_streak,
        message: `🎉 Won ${awardedCoins} coins with a ${Math.round(multiplier * 10) / 10}x streak multiplier!`,
      };
    } catch (err: any) {
      throw new HttpException(err.message, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
}
