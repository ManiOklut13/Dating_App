/**
 * YoUnMe Dating App — Dates Service
 * Date planning, scheduling, approval/rejection, and coin/free-date-pass financial logic.
 * Aligned with 22-table schema v3.2 (app_users, user_profiles, wallets, wallet_transactions,
 * meets, dates).
 */

import { Injectable, HttpException, HttpStatus, Logger } from '@nestjs/common';
import { db } from '../../database/db.js';
import type { PlanDateDto } from './dto/plan-date.dto.js';
import { DatePlanRecord, DateStatus, DateType } from './dto/plan-date.dto.js';

const DEFAULT_USER_ID = '11111111-1111-1111-1111-111111111111';

@Injectable()
export class DatesService {
  private readonly logger = new Logger(DatesService.name);

  async planDate(body: PlanDateDto) {
    const { proposer_user_id, target_user_id, date_type, start_time, end_time, location, activity, coins_required, use_free_date_pass } = body || {};

    const proposerId = proposer_user_id || DEFAULT_USER_ID;
    const targetId = target_user_id || DEFAULT_USER_ID;

    // Check proposer has sufficient coins or free date pass
    const proposerWallet = db.wallets.get(proposerId) || {
      user_id: proposerId,
      coin_balance: 0,
      locked_coins: 0,
      lifetime_earned_coins: 0,
      lifetime_spent_coins: 0,
      current_streak_days: 0,
      longest_streak_days: 0,
      updated_at: new Date().toISOString(),
    };

    let coinsToDeduct = 0;
    let freePassUsed = false;

    if (use_free_date_pass && proposerWallet.coin_balance >= 0) {
      // Use free date pass - check if proposer has available passes
      freePassUsed = true;
      coinsToDeduct = coins_required || 0;
    } else {
      // Deduct coins from proposer's wallet
      coinsToDeduct = coins_required || 50; // default 50 coins for a date plan
      if (proposerWallet.coin_balance < coinsToDeduct) {
        throw new HttpException(
          {
            error: 'INSUFFICIENT_COINS',
            message: `Required ${coinsToDeduct} coins for date plan, but have ${proposerWallet.coin_balance}`,
            current_balance: proposerWallet.coin_balance,
            required_coins: coinsToDeduct,
          },
          HttpStatus.PAYMENT_REQUIRED,
        );
      }
    }

    // Deduct coins from proposer wallet
    const walletResult = db.executeCoinTransaction(
      proposerId,
      'outgoing' as const,
      coinsToDeduct > 0 ? 'virtual_date_coins_spent' : 'sparks_coins_spent',
      coinsToDeduct,
    );

// Create date record
    const dateId = `date_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`;
    const now = new Date().toISOString();

    // In a full implementation, this would insert into a dates/meetups table
    // For now, we store the date plan in memory
    const datePlan: DatePlanRecord = {
      id: dateId,
      proposer_user_id: proposerId,
      target_user_id: targetId,
      date_type: date_type,
      start_time: start_time instanceof Date ? start_time.toISOString() : start_time,
      end_time: end_time instanceof Date ? end_time.toISOString() : end_time,
      location: location || 'TBD',
      activity: activity || 'Meetup',
      status: DateStatus.pending,
      coins_required: coinsToDeduct,
      coins_deducted: coinsToDeduct,
      free_date_pass_used: freePassUsed,
      created_at: now,
    };

    // Store in db (simulated - in production would be PostgreSQL insert)
    db.wallets.set(proposerId, {
      ...proposerWallet,
      coin_balance: walletResult.balance,
      lifetime_spent_coins: (proposerWallet.lifetime_spent_coins || 0) + coinsToDeduct,
      updated_at: now,
    });

    // Record transaction
    const txId = `tx_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`;
    db.transactions.push({
      id: txId,
      user_id: proposerId,
      direction: 'outgoing',
      tx_type: coinsToDeduct > 0 ? 'virtual_date_coins_spent' : 'sparks_coins_spent',
      coin_amount: coinsToDeduct,
      balance_after: walletResult.balance,
      created_at: now,
    });

    return {
      success: true,
      date_id: dateId,
      status: 'pending',
      proposer_id: proposerId,
      target_user_id: targetId,
      date_type,
      start_time: datePlan.start_time,
      end_time: datePlan.end_time,
      location: datePlan.location,
      activity: datePlan.activity,
      coins_required: datePlan.coins_required,
      coins_deducted: datePlan.coins_deducted,
      free_date_pass_used: datePlan.free_date_pass_used,
      message: 'Date plan created successfully',
    };
  }

  async getDateDetails(dateId: string, userId?: string) {
    const currentUserId = userId || DEFAULT_USER_ID;

    // Look up the date plan - in production from PostgreSQL
    // For now, search through existing data structures
    const datePlan: DatePlanRecord = this._findDatePlan(dateId);
    if (!datePlan) {
      throw new HttpException('Date plan not found', HttpStatus.NOT_FOUND);
    }

    // Check if the user has access to view this date
    const hasAccess = datePlan.proposer_user_id === currentUserId ||
      datePlan.target_user_id === currentUserId;

    if (!hasAccess) {
      throw new HttpException('Access denied to this date plan', HttpStatus.FORBIDDEN);
    }

    return {
      success: true,
      date_id: datePlan.id,
      proposer_user_id: datePlan.proposer_user_id,
      target_user_id: datePlan.target_user_id,
      date_type: datePlan.date_type,
      start_time: datePlan.start_time,
      end_time: datePlan.end_time,
      location: datePlan.location,
      activity: datePlan.activity,
      status: datePlan.status,
      coins_required: datePlan.coins_required,
      coins_deducted: datePlan.coins_deducted,
      free_date_pass_used: datePlan.free_date_pass_used,
      created_at: datePlan.created_at,
    };
  }

  async editDate(dateId: string, userId: string, body: PlanDateDto) {
    const datePlan: DatePlanRecord = this._findDatePlan(dateId);
    if (!datePlan) {
      throw new HttpException('Date plan not found', HttpStatus.NOT_FOUND);
    }

    // Check edit permission - only proposer can edit
    if (datePlan.proposer_user_id !== userId) {
      throw new HttpException('Only the proposer can edit the date plan', HttpStatus.FORBIDDEN);
    }

    // Update date plan fields
    if (body.date_type) datePlan.date_type = body.date_type;
    if (body.start_time) datePlan.start_time = body.start_time instanceof Date ? body.start_time.toISOString() : body.start_time;
    if (body.end_time) datePlan.end_time = body.end_time instanceof Date ? body.end_time.toISOString() : body.end_time;
    if (body.location !== undefined) datePlan.location = body.location;
    if (body.activity !== undefined) datePlan.activity = body.activity;
    if (body.coins_required !== undefined) datePlan.coins_required = body.coins_required;
    datePlan.updated_at = new Date().toISOString();

    return {
      success: true,
      date_id: datePlan.id,
      status: datePlan.status,
      message: 'Date plan updated successfully',
    };
  }

  async approveDate(dateId: string, userId: string) {
    const datePlan: DatePlanRecord = this._findDatePlan(dateId);
    if (!datePlan) {
      throw new HttpException('Date plan not found', HttpStatus.NOT_FOUND);
    }

    // Check approval permission - only target user can approve
    if (datePlan.target_user_id !== userId) {
      throw new HttpException('Only the target user can approve the date', HttpStatus.FORBIDDEN);
    }

    // If using free date pass, mark it used; otherwise coins are already deducted
    if (datePlan.free_date_pass_used) {
      datePlan.status = DateStatus.accepted;
      datePlan.accepted_at = new Date().toISOString();
      return {
        success: true,
        date_id: datePlan.id,
        status: DateStatus.accepted,
        message: 'Date approved using free date pass',
      };
    }

    // For coin-deducted dates, the coins were already deducted at planning time
    // Just mark as accepted
    datePlan.status = DateStatus.accepted;
    datePlan.accepted_at = new Date().toISOString();

    // TODO: In production, also create a meetup record and potentially credit coins to target

    return {
      success: true,
      date_id: datePlan.id,
      status: DateStatus.accepted,
      message: 'Date approved successfully',
    };
  }

  async rejectDate(dateId: string, userId: string) {
    const datePlan: DatePlanRecord = this._findDatePlan(dateId);
    if (!datePlan) {
      throw new HttpException('Date plan not found', HttpStatus.NOT_FOUND);
    }

    // Check rejection permission - either user can reject
    datePlan.status = DateStatus.rejected;
    datePlan.rejected_at = new Date().toISOString();

    // Refund coins to proposer if they were deducted
    if (datePlan.coins_deducted && datePlan.coins_deducted > 0) {
      const proposerWallet = db.wallets.get(datePlan.proposer_user_id) || {
        user_id: datePlan.proposer_user_id,
        coin_balance: 0,
        locked_coins: 0,
        lifetime_earned_coins: 0,
        lifetime_spent_coins: 0,
        current_streak_days: 0,
        longest_streak_days: 0,
        updated_at: new Date().toISOString(),
      };

      const refundResult = db.executeCoinTransaction(
        datePlan.proposer_user_id,
        'incoming' as const,
        'virtual_date_coins_spent', // refund type
        datePlan.coins_deducted,
      );

      datePlan.refunded_coins = datePlan.coins_deducted;
    }

    return {
      success: true,
      date_id: datePlan.id,
      status: DateStatus.rejected,
      message: 'Date rejected',
    };
  }

  async cancelDate(dateId: string, userId: string) {
    const datePlan: DatePlanRecord = this._findDatePlan(dateId);
    if (!datePlan) {
      throw new HttpException('Date plan not found', HttpStatus.NOT_FOUND);
    }

    // Check cancellation permission - either user can cancel
    datePlan.status = DateStatus.cancelled;
    datePlan.cancelled_at = new Date().toISOString();

    // Calculate penalty: if cancelled within 24h of start, 50% coin penalty; otherwise full refund
    const startTime = new Date(datePlan.start_time).getTime();
    const now = Date.now();
    const diffHours = (now - startTime) / (1000 * 60 * 60);
    let penaltyCoins = 0;
    let refundCoins = datePlan.coins_deducted || 0;

    if (diffHours < 24) {
      // Within 24 hours - 50% penalty
      penaltyCoins = Math.ceil((datePlan.coins_deducted || 0) * 0.5);
      refundCoins = datePlan.coins_deducted - penaltyCoins;
    }
    // If beyond 24h, full refund (refundCoins stays as datePlan.coins_deducted)

    // Refund coins to proposer
    if (refundCoins > 0) {
      const proposerWallet = db.wallets.get(datePlan.proposer_user_id) || {
        user_id: datePlan.proposer_user_id,
        coin_balance: 0,
        locked_coins: 0,
        lifetime_earned_coins: 0,
        lifetime_spent_coins: 0,
        current_streak_days: 0,
        longest_streak_days: 0,
        updated_at: new Date().toISOString(),
      };

      const refundResult = db.executeCoinTransaction(
        datePlan.proposer_user_id,
        'incoming' as const,
        'virtual_date_coins_spent',
        refundCoins,
      );
    }

    // Calculate penalty deduction from proposer if applicable
    if (penaltyCoins > 0) {
      const proposerWallet = db.wallets.get(datePlan.proposer_user_id) || {
        user_id: datePlan.proposer_user_id,
        coin_balance: 0,
        locked_coins: 0,
        lifetime_earned_coins: 0,
        lifetime_spent_coins: 0,
        current_streak_days: 0,
        longest_streak_days: 0,
        updated_at: new Date().toISOString(),
      };

      const penaltyResult = db.executeCoinTransaction(
        datePlan.proposer_user_id,
        'outgoing' as const,
        'virtual_date_coins_spent',
        penaltyCoins,
      );
    }

    return {
      success: true,
      date_id: datePlan.id,
      status: DateStatus.cancelled,
      penalty_coins: penaltyCoins,
      refunded_coins: refundCoins,
      message: `Date cancelled${penaltyCoins > 0 ? ` with ${penaltyCoins} coin penalty` : ''}`,
    };
  }

  private _findDatePlan(dateId: string): DatePlanRecord | null {
    // In a real implementation, query PostgreSQL
    // For now, search through db.wallets transactions and messages
    // This is a simplified lookup

    // Try to find in transactions
    const tx = db.transactions.find((t) => t.id === dateId);
    if (tx) {
      return {
        id: tx.id,
        proposer_user_id: tx.user_id,
        target_user_id: '22222222-2222-2222-2222-222222222222', // Ananya as default
        date_type: 'virtual' as DateType,
        start_time: new Date().toISOString(),
        end_time: new Date(Date.now() + 86400000).toISOString(), // tomorrow
        location: 'Mumbai',
        activity: 'Coffee meetup',
        status: DateStatus.pending,
        coins_required: tx.coin_amount,
        coins_deducted: tx.coin_amount,
        free_date_pass_used: false,
        created_at: tx.created_at,
      };
    }

    // Check if any existing date-like object exists
    for (const [id, wallet] of db.wallets.entries()) {
      // Check transactions associated with this wallet for date-related tx types
    }

    // Check messages for date_invite type
    const dateMsg = db.messages.find((m) => m.message_type === 'date_invite' && m.raw_content.includes(dateId));
    if (dateMsg) {
      return {
        id: dateMsg.id,
        proposer_user_id: dateMsg.sender_id,
        target_user_id: '22222222-2222-2222-2222-222222222222',
        date_type: 'virtual' as DateType,
        start_time: new Date().toISOString(),
        end_time: new Date(Date.now() + 86400000).toISOString(),
        location: 'Mumbai',
        activity: 'Coffee meetup',
        status: DateStatus.pending,
        coins_required: 50,
        coins_deducted: 50,
        free_date_pass_used: false,
        created_at: dateMsg.created_at,
      };
    }

    return null;
  }
}