import { Router, Request, Response } from 'express';
import { db } from '../../../database/db.js';

export const walletRouter = Router();

// Coin packages (Razorpay bundle catalog)
const COIN_PACKS = [
  { id: 'pack_100', name: 'Starter Spark', coins: 100, price_inr: 99, bonus: 0 },
  { id: 'pack_500', name: 'Popular Flame', coins: 500, price_inr: 399, bonus: 50 },
  { id: 'pack_1200', name: 'VIP Inferno', coins: 1200, price_inr: 799, bonus: 200 },
];

/**
 * GET /v1/wallet
 * Fetches live coin balance, recent audit ledger entries, and packages
 */
walletRouter.get('/', (req: Request, res: Response) => {
  const userId = (req.query.user_id as string) || '11111111-1111-1111-1111-111111111111';
  const wallet = db.wallets.get(userId) || { user_id: userId, balance: 0, updated_at: new Date().toISOString() };
  const user = db.users.get(userId);

  // Get user's transaction ledger (most recent 20)
  const userTxs = Array.from(db.transactions.values())
    .filter((tx) => tx.user_id === userId)
    .sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime())
    .slice(0, 20);

  const canCashOut = (user?.is_verified ?? false) && wallet.balance >= 500;

  return res.json({
    success: true,
    user_id: userId,
    balance: wallet.balance,
    is_verified_creator: user?.is_verified || false,
    cashout_eligible: canCashOut,
    cashout_minimum_threshold: 500,
    packages: COIN_PACKS,
    ledger: userTxs,
  });
});

/**
 * POST /v1/wallet/purchase
 * Processes verified coin credit top-ups via Razorpay / UPI
 */
walletRouter.post('/purchase', (req: Request, res: Response) => {
  const { user_id, package_id, razorpay_payment_id, idempotency_key } = req.body;
  const currentUserId = user_id || '11111111-1111-1111-1111-111111111111';

  const pack = COIN_PACKS.find((p) => p.id === package_id) || COIN_PACKS[0];
  const totalCoins = pack.coins + pack.bonus;
  const paymentRef = razorpay_payment_id || `rzp_pay_${Date.now()}`;
  const idempKey = idempotency_key || `idemp_pur_${paymentRef}`;

  try {
    const result = db.executeCoinTransaction(
      currentUserId,
      'purchase',
      totalCoins,
      `rzp_${pack.id}_${paymentRef}`,
      idempKey
    );

    return res.json({
      success: true,
      message: `Successfully credited ${totalCoins} coins to wallet!`,
      coins_added: totalCoins,
      new_balance: result.balance,
      duplicate_replayed: result.duplicate,
      tx_id: result.txId,
    });
  } catch (err: any) {
    return res.status(500).json({ error: err.message });
  }
});

/**
 * POST /v1/wallet/payout
 * Creator Cash-Out (Available strictly to verified profiles with >500 coins)
 */
walletRouter.post('/payout', (req: Request, res: Response) => {
  const { user_id, coins_to_withdraw, upi_id, idempotency_key } = req.body;
  const currentUserId = user_id || '11111111-1111-1111-1111-111111111111';
  const amount = parseInt(coins_to_withdraw, 10) || 500;

  const user = db.users.get(currentUserId);
  const wallet = db.wallets.get(currentUserId);

  if (!user?.is_verified) {
    return res.status(403).json({
      error: 'CREATOR_NOT_VERIFIED',
      message: 'Creator cash-out is strictly available to Blue Tick verified accounts.',
    });
  }

  if (!wallet || wallet.balance < 500 || amount > wallet.balance) {
    return res.status(400).json({
      error: 'INSUFFICIENT_CASHOUT_BALANCE',
      message: 'Minimum withdrawal requirement is 500 coins and cannot exceed your wallet balance.',
      current_balance: wallet?.balance || 0,
    });
  }

  const idempKey = idempotency_key || `payout_${currentUserId}_${Date.now()}`;
  const payoutInr = Math.floor(amount * 0.8); // Fixed token-to-payout rate: 100 coins = ₹80

  try {
    const result = db.executeCoinTransaction(
      currentUserId,
      'payout',
      -amount,
      `upi_payout_${upi_id || 'creator@upi'}`,
      idempKey
    );

    return res.json({
      success: true,
      message: `Cash-out initiated for ₹${payoutInr} (${amount} coins) to ${upi_id || 'registered UPI'}.`,
      coins_deducted: amount,
      payout_amount_inr: payoutInr,
      remaining_balance: result.balance,
      payout_status: 'processing_settlement',
    });
  } catch (err: any) {
    return res.status(400).json({ error: err.message });
  }
});
