import { Router, Request, Response } from 'express';
import { db } from '../../../database/db.js';

export const callsRouter = Router();

// Call rates according to Table 7 (Master Technical Architecture)
const CALL_RATES = {
  audio: { spend: 20, earn: 5 },  // 20 coins/min spend, 5 coins/min creator earn
  video: { spend: 50, earn: 10 }, // 50 coins/min spend, 10 coins/min creator earn
  random: { spend: 20, earn: 5 },
};

/**
 * POST /v1/calls/token
 * Generates LiveKit WebRTC participant room token and initializes call session
 */
callsRouter.post('/token', (req: Request, res: Response) => {
  const { caller_id, callee_id, kind, anonymous_avatar } = req.body;
  const currentCaller = caller_id || '11111111-1111-1111-1111-111111111111';
  const targetCallee = callee_id || '22222222-2222-2222-2222-222222222222';
  const callKind: 'audio' | 'video' | 'random' = kind || 'audio';

  // Check initial wallet balance
  const wallet = db.wallets.get(currentCaller);
  const requiredFirstMinute = CALL_RATES[callKind].spend;

  if (!wallet || wallet.balance < requiredFirstMinute) {
    return res.status(402).json({
      error: `INSUFFICIENT_COINS: At least ${requiredFirstMinute} coins required for 1 minute of ${callKind} call.`,
      current_balance: wallet?.balance || 0,
    });
  }

  const callId = `call_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`;
  const roomSid = `livekit_rm_${callId}`;

  // Create call record
  db.calls.set(callId, {
    id: callId,
    caller_id: currentCaller,
    callee_id: targetCallee,
    kind: callKind,
    livekit_room_sid: roomSid,
    started_at: new Date().toISOString(),
    duration_s: 0,
    cost_coins: 0,
    status: 'active',
  });

  // Simulated LiveKit JWT token payload
  const mockLiveKitToken = `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.${Buffer.from(
    JSON.stringify({
      room: roomSid,
      sub: currentCaller,
      name: anonymous_avatar ? 'Anonymous Caller' : 'Caller',
      video: callKind === 'video',
      audio: true,
      exp: Math.floor(Date.now() / 1000) + 3600,
    })
  ).toString('base64url')}.mockSignatureYoUnMe`;

  return res.json({
    success: true,
    call_id: callId,
    livekit_room_sid: roomSid,
    livekit_token: mockLiveKitToken,
    rates: CALL_RATES[callKind],
    caller_balance: wallet.balance,
  });
});

/**
 * POST /v1/calls/:id/heartbeat
 * Server-authoritative 60-second billing heartbeat tick
 */
callsRouter.post('/:id/heartbeat', (req: Request, res: Response) => {
  const { id } = req.params;
  const call = db.calls.get(id);

  if (!call || call.status !== 'active') {
    return res.status(404).json({ error: 'Call session not active or not found' });
  }

  const rates = CALL_RATES[call.kind];
  const idempotencyKeyCaller = `tx_call_tick_${call.id}_${call.duration_s + 60}_caller`;
  const idempotencyKeyCallee = `tx_call_tick_${call.id}_${call.duration_s + 60}_callee`;

  try {
    // 1. Deduct coins from caller
    const callerResult = db.executeCoinTransaction(
      call.caller_id,
      'spend',
      -rates.spend,
      `call_${call.id}_tick`,
      idempotencyKeyCaller
    );

    // 2. Credit creator earnings to callee
    db.executeCoinTransaction(
      call.callee_id,
      'earn',
      rates.earn,
      `call_${call.id}_earning`,
      idempotencyKeyCallee
    );

    call.duration_s += 60;
    call.cost_coins += rates.spend;

    const callerWallet = db.wallets.get(call.caller_id);
    const canContinue = (callerWallet?.balance || 0) >= rates.spend;

    return res.json({
      success: true,
      call_id: call.id,
      duration_s: call.duration_s,
      cost_coins: call.cost_coins,
      caller_balance: callerResult.balance,
      rate_per_min: rates.spend,
      can_continue: canContinue,
      message: canContinue ? 'Tick billed successfully' : 'Low balance warning: Call will drop on next minute.',
    });
  } catch (err: any) {
    // Balance exhausted, terminate call
    call.status = 'dropped';
    call.ended_at = new Date().toISOString();
    return res.status(402).json({
      error: 'CALL_TERMINATED_INSUFFICIENT_FUNDS',
      call_status: 'dropped',
      duration_s: call.duration_s,
      final_cost: call.cost_coins,
    });
  }
});

/**
 * POST /v1/calls/:id/end
 * Terminates call session, records duration and rating
 */
callsRouter.post('/:id/end', (req: Request, res: Response) => {
  const { id } = req.params;
  const { rating, reason } = req.body;
  const call = db.calls.get(id);

  if (!call) {
    return res.status(404).json({ error: 'Call session not found' });
  }

  call.status = 'completed';
  call.ended_at = new Date().toISOString();
  if (rating) call.rating = rating;

  const callerWallet = db.wallets.get(call.caller_id);
  const calleeWallet = db.wallets.get(call.callee_id);

  return res.json({
    success: true,
    call_id: call.id,
    duration_s: call.duration_s,
    total_coins_spent: call.cost_coins,
    caller_balance: callerWallet?.balance || 0,
    callee_balance: calleeWallet?.balance || 0,
    status: call.status,
  });
});

/**
 * POST /v1/calls/random/match
 * Blind matchmaking queue with anonymous avatar masking
 */
callsRouter.post('/random/match', (req: Request, res: Response) => {
  const { user_id, kind } = req.body;
  const currentUserId = user_id || '11111111-1111-1111-1111-111111111111';

  // Pair with candidate (e.g. Ananya)
  const candidateId = '22222222-2222-2222-2222-222222222222';
  const candidateProfile = db.profiles.get(candidateId);

  return res.json({
    success: true,
    matched: true,
    callee_id: candidateId,
    masked_avatar: candidateProfile?.call_avatar_ref || 'avatar_pastel_lotus',
    matched_interests: ['Indie Vinyl', 'Coffee Cafes', 'Late-night talks'],
    kind: kind || 'audio',
  });
});
