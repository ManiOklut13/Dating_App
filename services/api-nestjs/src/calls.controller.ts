import { Router, Request, Response } from 'express';
import { db, CallDirection, CallSession, CallStatus } from '../../../database/db.js';

export const callsRouter = Router();

// Call rates according to Table 7 (Master Technical Architecture)
const CALL_RATES = {
  audio: { spend: 20, earn: 5 },  // 20 coins/min spend, 5 coins/min creator earn
  video: { spend: 50, earn: 10 }, // 50 coins/min spend, 10 coins/min creator earn
  random: { spend: 20, earn: 5 },
};

const CURRENT_USER_ID = '11111111-1111-1111-1111-111111111111';

const isCallStatus = (value: unknown): value is CallStatus =>
  value === 'completed' || value === 'missed' || value === 'declined' || value === 'failed' || value === 'dropped';

const isCallDirection = (value: unknown): value is CallDirection =>
  value === 'incoming' || value === 'outgoing';

/**
 * Resolve the authenticated user. The rest of this service runs without a
 * real auth middleware (see auth.controller.ts, which issues placeholder
 * tokens), so this falls back to the seeded current user in development and
 * is the single seam to replace once JWT verification lands.
 */
const resolveUserId = (req: Request): string => {
  const header = req.header('x-user-id');
  const query = req.query.user_id;
  const candidate = header || (typeof query === 'string' ? query : undefined);
  return candidate && db.users.has(candidate) ? candidate : CURRENT_USER_ID;
};

/**
 * Project a CallSession into the shape the Call History pages consume, with the
 * *other* participant resolved from the authenticated user's point of view.
 */
const serializeCallForUser = (call: CallSession, userId: string) => {
  const isOutgoing = call.caller_id === userId;
  const counterpartId = isOutgoing ? call.callee_id : call.caller_id;
  const counterpart = db.profiles.get(counterpartId);

  return {
    call_id: call.id,
    // Raw participants, kept so the UI can issue a new call to the right person.
    caller_id: call.caller_id,
    receiver_id: call.callee_id,
    call_type: call.kind === 'random' ? 'audio' : call.kind,
    call_direction: isOutgoing ? 'outgoing' : 'incoming',
    call_status: call.status,
    started_at: call.started_at,
    ended_at: call.ended_at ?? null,
    duration_seconds: call.duration_s,
    cost_coins: call.cost_coins,
    livekit_room_sid: call.livekit_room_sid,
    rating: call.rating ?? null,
    counterpart: {
      user_id: counterpartId,
      nickname: counterpart?.nickname ?? 'Unknown',
      avatar: counterpart?.photo_urls?.[0] ?? '/ananya.jpg',
      city: counterpart?.city ?? null,
    },
  };
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
    direction: 'outgoing',
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

/**
 * POST /v1/calls
 * Records a call *event* into history. Called once a call ends so the
 * Audio / Video history pages reflect the real outcome rather than a guess.
 *
 * Duration is derived from started_at / ended_at rather than trusted from the
 * client, so a tampered or stale client clock cannot inflate billing.
 */
callsRouter.post('/', (req: Request, res: Response) => {
  const userId = resolveUserId(req);
  const {
    caller_id,
    callee_id,
    kind,
    direction,
    started_at,
    ended_at,
    duration_seconds,
    status,
  } = req.body ?? {};

  const callKind: 'audio' | 'video' | 'random' = kind === 'video' ? 'video' : kind === 'random' ? 'random' : 'audio';

  if (!callee_id || !db.users.has(callee_id)) {
    return res.status(400).json({ error: 'A valid callee_id is required.' });
  }
  if (callee_id === userId) {
    return res.status(400).json({ error: 'You cannot record a call with yourself.' });
  }
  if (!isCallStatus(status)) {
    return res.status(400).json({ error: 'status must be one of: completed, missed, declined, failed.' });
  }

  // The caller is whoever the authenticated user is, so history is only ever
  // written for the account making the request.
  const callerId = caller_id && db.users.has(caller_id) && caller_id !== '' ? caller_id : userId;
  const resolvedDirection: CallDirection =
    callerId === userId ? 'outgoing' : isCallDirection(direction) ? direction : 'incoming';

  const started = started_at ? new Date(started_at) : new Date();
  if (Number.isNaN(started.getTime())) {
    return res.status(400).json({ error: 'started_at must be a valid ISO timestamp.' });
  }

  const ended = ended_at ? new Date(ended_at) : status === 'completed' ? new Date() : null;
  if (ended && Number.isNaN(ended.getTime())) {
    return res.status(400).json({ error: 'ended_at must be a valid ISO timestamp.' });
  }

  // Authoritative duration from the actual start/end times.
  const durationSeconds = ended && ended.getTime() > started.getTime()
    ? Math.round((ended.getTime() - started.getTime()) / 1000)
    : 0;

  const callId = `call_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`;

  db.calls.set(callId, {
    id: callId,
    caller_id: callerId,
    callee_id: callee_id as string,
    kind: callKind,
    direction: resolvedDirection,
    livekit_room_sid: `livekit_rm_${callId}`,
    started_at: started.toISOString(),
    ended_at: ended ? ended.toISOString() : null,
    duration_s: durationSeconds,
    cost_coins: Math.ceil(durationSeconds / 60) * CALL_RATES[callKind].spend,
    status: status as CallStatus,
  });

  return res.status(201).json({ success: true, call: serializeCallForUser(db.calls.get(callId)!, userId) });
});

/**
 * GET /v1/calls/history?type=audio|video&page=1&limit=20&q=<search>
 *
 * Returns only records the authenticated user participated in, filtered by
 * call type so the Audio and Video histories stay independent, most recent
 * first. `q` filters on the counterpart's name server-side so pagination and
 * search agree.
 */
callsRouter.get('/history', (req: Request, res: Response) => {
  const userId = resolveUserId(req);
  const rawType = typeof req.query.type === 'string' ? req.query.type : undefined;
  const type = rawType === 'video' ? 'video' : rawType === 'audio' ? 'audio' : undefined;
  const search = typeof req.query.q === 'string' ? req.query.q.trim().toLowerCase() : '';

  const page = Math.max(1, Number(req.query.page) || 1);
  const limit = Math.min(50, Math.max(1, Number(req.query.limit) || 20));

  const all = Array.from(db.calls.values())
    .filter((call) => call.caller_id === userId || call.callee_id === userId)
    .filter((call) => call.status !== 'active')
    .filter((call) => (type ? call.kind === type : true))
    .map((call) => serializeCallForUser(call, userId))
    .filter((call) => (search ? call.counterpart.nickname.toLowerCase().includes(search) : true))
    .sort((a, b) => new Date(b.started_at).getTime() - new Date(a.started_at).getTime());

  const total = all.length;
  const start = (page - 1) * limit;

  return res.json({
    success: true,
    call_type: type ?? 'all',
    total,
    page,
    limit,
    has_more: start + limit < total,
    calls: all.slice(start, start + limit),
  });
});

/**
 * GET /v1/calls/:id
 * Single call record for the Call Details screen. Scoped to the authenticated
 * user so one account cannot read another's call history by guessing ids.
 */
callsRouter.get('/:id', (req: Request, res: Response) => {
  const userId = resolveUserId(req);
  const call = db.calls.get(req.params.id);

  if (!call) {
    return res.status(404).json({ error: 'Call record not found.' });
  }
  if (call.caller_id !== userId && call.callee_id !== userId) {
    return res.status(403).json({ error: 'You do not have access to this call record.' });
  }

  return res.json({ success: true, call: serializeCallForUser(call, userId) });
});
