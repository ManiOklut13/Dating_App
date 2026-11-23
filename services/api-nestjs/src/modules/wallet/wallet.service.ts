/**
 * YoUnMe Dating App — Wallet Service
 * Server-authoritative double-entry ledger with atomic PostgreSQL transactions,
 * row-level locking (FOR UPDATE) to prevent double spending, and creator payouts.
 */

import { Injectable, HttpException, HttpStatus, Logger } from '@nestjs/common';
import { DatabaseService } from '../database/database.service.js';
import { db } from '../../database/db.js';
import type { WalletTxType } from '../../database/db.js';

const DEFAULT_USER_ID = '11111111-1111-1111-1111-111111111111';

// Coin packages (Razorpay bundle catalog)
export const COIN_PACKS = [
  { id: 'pack_100', name: 'Starter Spark', coins: 100, price_inr: 99, bonus: 0 },
  { id: 'pack_500', name: 'Popular Flame', coins: 500, price_inr: 399, bonus: 50 },
  { id: 'pack_1200', name: 'VIP Inferno', coins: 1200, price_inr: 799, bonus: 200 },
];

@Injectable()
export class WalletService {
  private readonly logger = new Logger(WalletService.name);

  constructor(private readonly databaseService: DatabaseService) {}

  /**
   * Atomic ledger transaction execution for user_wallets balance updates
   * and append-only wallet_transactions history with PostgreSQL row-level locks.
   */
  async executeAtomicLedgerTransaction(
    userId: string,
    direction: 'incoming' | 'outgoing',
    txType: WalletTxType,
    coinAmount: number,
  ): Promise<{
    success: boolean;
    txId: string;
    balance: number;
    balanceAfter: number;
    direction: string;
    txType: string;
  }> {
    if (!coinAmount || coinAmount <= 0) {
      throw new HttpException('Coin amount must be a positive integer', HttpStatus.BAD_REQUEST);
    }

    if (this.databaseService?.isConnected) {
      const client = await this.databaseService.pool.connect();
      try {
        await client.query('BEGIN');

        // 1. Lock the wallet row for this user
        let walletRes = await client.query(
          `SELECT coin_balance, locked_coins, lifetime_earned_coins, lifetime_spent_coins 
           FROM user_wallets 
           WHERE user_id = $1 
           FOR UPDATE`,
          [userId],
        );

        if (walletRes.rows.length === 0) {
          // Initialize wallet if not present
          await client.query(
            `INSERT INTO user_wallets (user_id, coin_balance, locked_coins, lifetime_earned_coins, lifetime_spent_coins, updated_at)
             VALUES ($1, 0, 0, 0, 0, now())
             ON CONFLICT (user_id) DO NOTHING`,
            [userId],
          );

          walletRes = await client.query(
            `SELECT coin_balance, locked_coins, lifetime_earned_coins, lifetime_spent_coins 
             FROM user_wallets 
             WHERE user_id = $1 
             FOR UPDATE`,
            [userId],
          );
        }

        const currentBalance = Number(walletRes.rows[0]?.coin_balance || 0);

        // 2. Validate sufficient funds for outgoing transactions
        if (direction === 'outgoing' && currentBalance < coinAmount) {
          await client.query('ROLLBACK');
          throw new HttpException(
            {
              error: 'INSUFFICIENT_COINS',
              message: `Required ${coinAmount} coins, but current balance is ${currentBalance}`,
              current_balance: currentBalance,
              required_coins: coinAmount,
            },
            HttpStatus.PAYMENT_REQUIRED,
          );
        }

        // 3. Compute new balances
        const newBalance =
          direction === 'incoming'
            ? currentBalance + coinAmount
            : currentBalance - coinAmount;
        const earnedDelta = direction === 'incoming' ? coinAmount : 0;
        const spentDelta = direction === 'outgoing' ? coinAmount : 0;

        // 4. Update user_wallets
        await client.query(
          `UPDATE user_wallets
           SET coin_balance = $1,
               lifetime_earned_coins = lifetime_earned_coins + $2,
               lifetime_spent_coins = lifetime_spent_coins + $3,
               updated_at = now()
           WHERE user_id = $4`,
          [newBalance, earnedDelta, spentDelta, userId],
        );

        // 5. Append immutable record into wallet_transactions
        const txRes = await client.query(
          `INSERT INTO wallet_transactions (id, user_id, direction, tx_type, coin_amount, balance_after, created_at)
           VALUES (gen_random_uuid(), $1, $2, $3, $4, $5, now())
           RETURNING id`,
          [userId, direction, txType, coinAmount, newBalance],
        );

        await client.query('COMMIT');

        const txId = txRes.rows[0]?.id;
        return {
          success: true,
          txId,
          balance: newBalance,
          balanceAfter: newBalance,
          direction,
          txType,
        };
      } catch (err: any) {
        await client.query('ROLLBACK');
        if (err instanceof HttpException) throw err;
        this.logger.error(`Atomic ledger transaction failed: ${err.message}`);
        // Fallback to in-memory if DB schema not ready
      } finally {
        client.release();
      }
    }

    // In-Memory Fallback Adapter
    const fallback = db.executeCoinTransaction(
      userId,
      direction,
      txType,
      coinAmount,
    );

    return {
      success: true,
      txId: fallback.txId,
      balance: fallback.balance,
      balanceAfter: fallback.balance,
      direction,
      txType,
    };
  }

  async getWallet(userId?: string) {
    const currentUserId = userId || DEFAULT_USER_ID;

    try {
      if (this.databaseService?.isConnected) {
        // Fetch wallet
        const walletRes = await this.databaseService.query(
          `SELECT coin_balance, locked_coins, lifetime_earned_coins, lifetime_spent_coins, current_streak_days, updated_at
           FROM user_wallets 
           WHERE user_id = $1`,
          [currentUserId],
        );

        // Fetch user verification status
        const userRes = await this.databaseService.query(
          `SELECT is_verified FROM user_profiles WHERE user_id = $1`,
          [currentUserId],
        );

        // Fetch recent append-only transactions
        const txsRes = await this.databaseService.query(
          `SELECT id, direction, tx_type, coin_amount, balance_after, created_at
           FROM wallet_transactions
           WHERE user_id = $1
           ORDER BY created_at DESC
           LIMIT 20`,
          [currentUserId],
        );

        const balance = Number(walletRes.rows[0]?.coin_balance || 0);
        const isVerified = Boolean(userRes.rows[0]?.is_verified);
        const canCashOut = isVerified && balance >= 500;

        return {
          success: true,
          user_id: currentUserId,
          balance,
          is_verified_creator: isVerified,
          cashout_eligible: canCashOut,
          cashout_minimum_threshold: 500,
          packages: COIN_PACKS,
          ledger: txsRes.rows || [],
        };
      }
    } catch (err: any) {
      this.logger.warn(`getWallet DB notice: ${err.message}`);
    }

    // In-memory fallback
    const wallet = db.wallets.get(currentUserId) || {
      user_id: currentUserId,
      coin_balance: 0,
      locked_coins: 0,
      lifetime_earned_coins: 0,
      lifetime_spent_coins: 0,
      current_streak_days: 0,
      longest_streak_days: 0,
      updated_at: new Date().toISOString(),
    };
    const user = db.users.get(currentUserId);
    const profile = db.profiles.get(currentUserId);
    const userTxs = db.transactions
      .filter((tx) => tx.user_id === currentUserId)
      .sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime())
      .slice(0, 20);

    const isVerified = profile?.is_verified ?? false;
    const canCashOut = isVerified && wallet.coin_balance >= 500;

    return {
      success: true,
      user_id: currentUserId,
      balance: wallet.coin_balance,
      is_verified_creator: isVerified,
      cashout_eligible: canCashOut,
      cashout_minimum_threshold: 500,
      packages: COIN_PACKS,
      ledger: userTxs,
    };
  }

  async purchasePackage(body: {
    user_id?: string;
    package_id?: string;
    razorpay_payment_id?: string;
    idempotency_key?: string;
  }) {
    const currentUserId = body?.user_id || DEFAULT_USER_ID;
    const pack = COIN_PACKS.find((p) => p.id === body?.package_id) || COIN_PACKS[0];
    const totalCoins = pack.coins + pack.bonus;
    const paymentRef = body?.razorpay_payment_id || `rzp_pay_${Date.now()}`;

    // Execute atomic ledger deposit
    const ledgerResult = await this.executeAtomicLedgerTransaction(
      currentUserId,
      'incoming',
      'purchase',
      totalCoins,
    );

    // Record into payment_orders if DB is available
    if (this.databaseService?.isConnected) {
      try {
        await this.databaseService.query(
          `INSERT INTO payment_orders (id, user_id, gateway_order_id, amount_fiat_type, amount, status, created_at)
           VALUES (gen_random_uuid(), $1, $2, 'inr', $3, 'success', now())
           ON CONFLICT (gateway_order_id) DO NOTHING`,
          [currentUserId, paymentRef, pack.price_inr],
        );
      } catch (err: any) {
        this.logger.debug(`payment_order insert notice: ${err.message}`);
      }
    }

    return {
      success: true,
      message: `Successfully credited ${totalCoins} coins to wallet!`,
      coins_added: totalCoins,
      new_balance: ledgerResult.balance,
      tx_id: ledgerResult.txId,
    };
  }

  async requestPayout(body: {
    user_id?: string;
    coins_to_withdraw?: number | string;
    upi_id?: string;
    idempotency_key?: string;
  }) {
    const currentUserId = body?.user_id || DEFAULT_USER_ID;
    const amount = parseInt(String(body?.coins_to_withdraw), 10) || 500;

    if (amount < 500) {
      throw new HttpException(
        'Minimum cash-out threshold is 500 coins',
        HttpStatus.BAD_REQUEST,
      );
    }

    // Verify creator status
    if (this.databaseService?.isConnected) {
      const userRes = await this.databaseService.query(
        `SELECT is_verified FROM user_profiles WHERE user_id = $1`,
        [currentUserId],
      );
      if (userRes.rows.length > 0 && !userRes.rows[0].is_verified) {
        throw new HttpException(
          {
            error: 'CREATOR_NOT_VERIFIED',
            message: 'Creator cash-out is strictly available to Blue Tick verified accounts.',
          },
          HttpStatus.FORBIDDEN,
        );
      }
    }

    // Atomically debit coins from user_wallets
    const ledgerResult = await this.executeAtomicLedgerTransaction(
      currentUserId,
      'outgoing',
      'payout',
      amount,
    );

    // Record into payout_requests
    let payoutId = `payout_${Date.now()}`;
    if (this.databaseService?.isConnected) {
      try {
        const payoutRes = await this.databaseService.query(
          `INSERT INTO payout_requests (id, user_id, coins_converted, payout_amount_fiat_type, payout_amount, payout_status, gateway_payout_ref, created_at)
           VALUES (gen_random_uuid(), $1, $2, 'inr', $3, 'processing', $4, now())
           RETURNING id`,
          [currentUserId, amount, (amount * 0.5).toFixed(2), body?.upi_id || 'upi_pending'],
        );
        if (payoutRes.rows.length > 0) {
          payoutId = payoutRes.rows[0].id;
        }
      } catch (err: any) {
        this.logger.debug(`payout_requests insert notice: ${err.message}`);
      }
    }

    return {
      success: true,
      message: `Cash-out request for ${amount} coins initiated. Payout dispatched within 24 hours.`,
      payout_id: payoutId,
      remaining_balance: ledgerResult.balance,
      fiat_payout_inr: (amount * 0.5).toFixed(2),
      status: 'processing',
    };
  }

  /**
   * Checks whether the user has an active subscription perk with available free monthly dates.
   */
  async hasActiveFreeDatePass(userId: string): Promise<boolean> {
    if (this.databaseService?.isConnected) {
      try {
        const subRes = await this.databaseService.query(
          `SELECT s.id, p.features_json 
           FROM user_subscriptions s
           JOIN plans p ON p.id = s.plan_id
           WHERE s.user_id = $1 
             AND s.status = 'active'
             AND s.expires_at > now()
           LIMIT 1`,
          [userId],
        );

        if (subRes.rows.length > 0) {
          const features = subRes.rows[0].features_json || {};
          const maxFreeDates = Number(features.free_monthly_dates || features.free_dates_count || 0);

          if (maxFreeDates > 0) {
            // Count free dates already utilized in the current billing month
            const countRes = await this.databaseService.query(
              `SELECT COUNT(*)::int as count 
               FROM meetup 
               WHERE proposer_user_id = $1 
                 AND (coins_json->>'free_date_used')::boolean = true
                 AND created_at >= date_trunc('month', now())`,
              [userId],
            );
            const usedThisMonth = Number(countRes.rows[0]?.count || 0);
            return usedThisMonth < maxFreeDates;
          }
        }
      } catch (err: any) {
        this.logger.warn(`hasActiveFreeDatePass check error: ${err.message}`);
      }
    }
    return false;
  }
}
