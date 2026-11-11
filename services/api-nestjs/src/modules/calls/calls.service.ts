/**
 * YoUnMe Dating App — Calls Service
 * Provision LiveKit room tokens, server-authoritative per-minute billing,
 * LiveKit API webhook handling, and duration logging in call_sessions.
 */

import {
  Injectable,
  HttpException,
  HttpStatus,
  NotFoundException,
  Logger,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as crypto from 'crypto';
import { AccessToken } from 'livekit-server-sdk';
import { RedisService } from '../redis/redis.service.js';
import { DatabaseService } from '../database/database.service.js';
import { WalletService } from '../wallet/wallet.service.js';
import { db } from '../../database/db.js';
import type { WalletTxType } from '../../database/db.js';

const DEFAULT_CALLER_ID = '11111111-1111-1111-1111-111111111111';
const DEFAULT_CALLEE_ID = '22222222-2222-2222-2222-222222222222';

export const CALL_RATES = {
  audio: { spend: 20, earn: 5 },
  video: { spend: 50, earn: 10 },
  random: { spend: 20, earn: 5 },
} as const;

@Injectable()
export class CallsService {
  private readonly logger = new Logger(CallsService.name);

  private resolveCallSpendTxType(
    kind: 'audio' | 'video',
    isRandom: boolean,
  ): WalletTxType {
    if (isRandom) {
      return kind === 'video' ? 'random_video_call_spend' : 'random_audio_call_spend';
    }
    return kind === 'video' ? 'video_call_spend' : 'audio_call_spend';
  }

  constructor(
    private readonly configService: ConfigService,
    private readonly databaseService: DatabaseService,
    private readonly walletService: WalletService,
    private readonly redisService: RedisService,
  ) {}

  /**
   * Generates a signed LiveKit AccessToken using livekit-server-sdk
   * with 10-minute TTL and proper room join grants.
   */
  private async generateLiveKitToken(
    roomName: string,
    participantIdentity: string,
    participantName: string,
    isCaller: boolean,
    isVideo: boolean,
  ): Promise<string> {
    const apiKey =
      this.configService.get<string>('LIVEKIT_API_KEY') || 'devkey_younme_livekit';
    const apiSecret =
      this.configService.get<string>('LIVEKIT_API_SECRET') ||
      'devsecret_younme_livekit_super_secret_key';

    const token = new AccessToken(apiKey, apiSecret, {
      ttl: 600, // 10-minute TTL
      identity: participantIdentity,
      name: participantName,
    });

    const isVideoRoom = isVideo;
    token.addGrant({
      room: roomName,
      roomJoin: true,
      canPublish: true,
      canSubscribe: true,
      canPublishData: true,
    } as const);

    token.metadata = JSON.stringify({
      is_caller: isCaller,
      is_video: isVideoRoom,
    });

    return await token.toJwt();
  }

  /**
   * Provisions a LiveKit room token and records initiating call session in call_sessions table.
   */
  async createToken(body: {
    caller_id?: string;
    callee_id?: string;
    kind?: 'audio' | 'video' | 'random';
    anonymous_avatar?: boolean;
    match_id?: string;
  }) {
    const currentCaller = body?.caller_id || DEFAULT_CALLER_ID;
    const targetCallee = body?.callee_id || DEFAULT_CALLEE_ID;
    const callKind: 'audio' | 'video' | 'random' = body?.kind || 'audio';
    const isRandom = callKind === 'random';
    const isVideo = callKind === 'video';

    // 1. Pre-flight check: caller wallet balance must cover at least 1 minute
    const requiredFirstMinute = CALL_RATES[callKind].spend;
    const walletData = await this.walletService.getWallet(currentCaller);

    if (walletData.balance < requiredFirstMinute) {
      throw new HttpException(
        {
          error: 'INSUFFICIENT_COINS',
          message: `At least ${requiredFirstMinute} coins required for 1 minute of ${callKind} call. Current balance: ${walletData.balance}`,
          required_coins: requiredFirstMinute,
          current_balance: walletData.balance,
        },
        HttpStatus.PAYMENT_REQUIRED,
      );
    }

    const callId = `call_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`;
    const livekitRoomName = `rm_${callKind}_${callId}`;

    // 2. Insert call session record into call_sessions table
    if (this.databaseService?.isConnected) {
      try {
        await this.databaseService.query(
          `INSERT INTO call_sessions (
             livekit_room_name, caller_user_id, callee_user_id, match_id,
             call_type, is_random_blind_call, status,
             duration_seconds, caller_coins_type, caller_coins,
             callee_coins_type, callee_coins, created_at
           ) VALUES (
             $1, $2, $3, $4,
             $5, $6, 'initiating',
             0, 'debited', 0,
             'credited', 0, now()
           )`,
          [
            livekitRoomName,
            currentCaller,
            targetCallee,
            body?.match_id || null,
            isVideo ? 'video' : 'audio',
            isRandom,
          ],
        );
      } catch (err: any) {
        this.logger.warn(`Failed to insert call_sessions: ${err.message}`);
      }
    }

    // Fallback store sync
    db.calls.set(callId, {
      id: callId,
      livekit_room_name: livekitRoomName,
      caller_user_id: currentCaller,
      callee_user_id: targetCallee,
      match_id: body?.match_id,
      call_type: isVideo ? 'video' : 'audio',
      is_random_blind_call: isRandom,
      status: 'active',
      duration_seconds: 0,
      audio_duration_seconds: 0,
      video_duration_seconds: 0,
      media_switches_log: [],
      caller_coins_type: 'debited',
      caller_coins: 0,
      callee_coins_type: 'credited',
      callee_coins: 0,
      is_hidden_for_caller: false,
      is_hidden_for_callee: false,
      caller_ratings_json: {},
      callee_ratings_json: {},
      created_at: new Date().toISOString(),
      started_at: new Date().toISOString(),
    });

    // Publish call initiated event to Redis Pub/Sub so Go service can trigger real-time ringing
    if (this.redisService?.isConnected && this.redisService.getClient()) {
      try {
        await this.redisService.getClient().publish(
          'call.initiated',
          JSON.stringify({
            callId,
            livekitRoomName: livekitRoomName,
            callerId: currentCaller,
            calleeId: targetCallee,
            kind: callKind,
          })
        );
      } catch (err: any) {
        this.logger.warn(`Redis Pub/Sub publish notice: ${err.message}`);
      }
    }

    // 3. Generate LiveKit WebRTC tokens
    const callerName = body?.anonymous_avatar ? 'Anonymous Caller' : 'Caller';
    const callerToken = await this.generateLiveKitToken(
      livekitRoomName,
      currentCaller,
      callerName,
      true,
      isVideo,
    );

    return {
      success: true,
      call_id: callId,
      livekit_room_name: livekitRoomName,
      livekit_room_sid: livekitRoomName,
      livekit_token: callerToken,
      rates: CALL_RATES[callKind],
      caller_balance: walletData.balance,
    };
  }

  /**
   * Handles server-authoritative 60-second billing heartbeat tick
   */
  async heartbeat(id: string) {
    let callSession: any = null;

    if (this.databaseService?.isConnected) {
      const res = await this.databaseService.query(
        `SELECT id, livekit_room_name, caller_user_id, callee_user_id, call_type,
                is_random_blind_call, status, duration_seconds, caller_coins, callee_coins
         FROM call_sessions
         WHERE id::text = $1 OR livekit_room_name = $1
         LIMIT 1`,
        [id],
      );
      callSession = res.rows[0];
    }

    if (!callSession) {
      const mockCall = db.calls.get(id);
      if (mockCall) {
        callSession = {
          id: mockCall.id,
          livekit_room_name: mockCall.livekit_room_name,
          caller_user_id: mockCall.caller_user_id,
          callee_user_id: mockCall.callee_user_id,
          call_type: mockCall.call_type,
          is_random_blind_call: mockCall.is_random_blind_call,
          duration_seconds: mockCall.duration_seconds,
          caller_coins: mockCall.caller_coins,
          callee_coins: mockCall.callee_coins,
        };
      }
    }

    if (!callSession) {
      throw new NotFoundException('Call session not active or not found');
    }

    const kind = (callSession.call_type as 'audio' | 'video') || 'audio';
    const rates = CALL_RATES[kind] || CALL_RATES.audio;
    const spendTxType = this.resolveCallSpendTxType(
      kind,
      !!callSession.is_random_blind_call,
    );

    // Atomically debit caller coins
    const callerLedger = await this.walletService.executeAtomicLedgerTransaction(
      callSession.caller_user_id,
      'outgoing',
      spendTxType,
      rates.spend,
    );

    // Atomically credit callee creator coins
    await this.walletService.executeAtomicLedgerTransaction(
      callSession.callee_user_id,
      'incoming',
      'rewards',
      rates.earn,
    );

    const newDuration = (callSession.duration_seconds || 0) + 60;
    const newCallerCoins = (callSession.caller_coins || 0) + rates.spend;
    const newCalleeCoins = (callSession.callee_coins || 0) + rates.earn;

    if (this.databaseService?.isConnected) {
      await this.databaseService.query(
        `UPDATE call_sessions
         SET duration_seconds = $1,
             caller_coins = $2,
             callee_coins = $3,
             status = 'active'
         WHERE id::text = $4 OR livekit_room_name = $4`,
        [newDuration, newCallerCoins, newCalleeCoins, id],
      );
    }

    return {
      success: true,
      call_id: id,
      duration_seconds: newDuration,
      coins_deducted: rates.spend,
      creator_coins_earned: rates.earn,
      caller_remaining_balance: callerLedger.balance,
      session_status: 'active',
    };
  }

  /**
   * Processes LiveKit API Webhook events (room_started, participant_joined, room_finished, participant_left)
   * for duration logging and server-authoritative final billing.
   */
  async handleLiveKitWebhook(payload: any, headers: any = {}) {
    const event = payload?.event;
    const roomName = payload?.room?.name;

    // Verify LiveKit Cloud webhook signature
    const signature = headers['x-livekit-signature'];
    const apiSecret =
      this.configService.get<string>('LIVEKIT_API_SECRET') ||
      'devsecret_younme_livekit_super_secret_key';

    if (signature) {
      const bodyString = JSON.stringify(payload);
      const expectedSig = crypto
        .createHmac('sha256', apiSecret)
        .update(bodyString)
        .digest('base64url');
      if (signature !== expectedSig) {
        this.logger.warn(
          `LiveKit Webhook signature mismatch. Expected: ${expectedSig}, Got: ${signature}`,
        );
        return { received: false, notice: 'Webhook signature verification failed' };
      }
    }

    this.logger.log(`LiveKit Webhook Received: Event "${event}" for room "${roomName}"`);

    if (!roomName) {
      return { received: true, notice: 'No room name provided' };
    }

    if (event === 'room_started') {
      if (this.databaseService?.isConnected) {
        await this.databaseService.query(
          `UPDATE call_sessions
            SET status = 'active', started_at = COALESCE(started_at, now())
            WHERE livekit_room_name = $1`,
          [roomName],
        );
      }
      return { received: true, action: 'session_activated' };
    }

    if (event === 'participant_joined') {
      if (this.databaseService?.isConnected) {
        await this.databaseService.query(
          `UPDATE call_sessions
            SET status = 'active', started_at = COALESCE(started_at, now())
            WHERE livekit_room_name = $1`,
          [roomName],
        );
      }
      return { received: true, action: 'session_activated' };
    }

    if (event === 'room_finished') {
      const durationSeconds = Number(payload?.room?.duration || 60);

      if (this.databaseService?.isConnected) {
        // Fetch session
        const sessionRes = await this.databaseService.query(
          `SELECT id, caller_user_id, callee_user_id, call_type,
                  is_random_blind_call, caller_coins, callee_coins
           FROM call_sessions 
           WHERE livekit_room_name = $1`,
          [roomName],
        );

        const session = sessionRes.rows[0];
        if (session) {
          const kind = (session.call_type as 'audio' | 'video') || 'audio';
          const rates = CALL_RATES[kind] || CALL_RATES.audio;
          const spendTxType = this.resolveCallSpendTxType(
            kind,
            !!session.is_random_blind_call,
          );
          const billedMinutes = Math.max(1, Math.ceil(durationSeconds / 60));
          const totalSpend = billedMinutes * rates.spend;
          const totalEarn = billedMinutes * rates.earn;

          // If coins haven't been debited during session, reconcile final billing
          if (!session.caller_coins || session.caller_coins < totalSpend) {
            const remainderSpend = totalSpend - (session.caller_coins || 0);
            const remainderEarn = totalEarn - (session.callee_coins || 0);

            try {
              await this.walletService.executeAtomicLedgerTransaction(
                session.caller_user_id,
                'outgoing',
                spendTxType,
                remainderSpend,
              );
              await this.walletService.executeAtomicLedgerTransaction(
                session.callee_user_id,
                'incoming',
                'rewards',
                remainderEarn,
              );
            } catch (err: any) {
              this.logger.warn(`Webhook final billing notice: ${err.message}`);
            }
          }

          await this.databaseService.query(
            `UPDATE call_sessions
              SET status = 'completed',
                  duration_seconds = $1,
                  caller_coins = $2,
                  callee_coins = $3,
                  ended_at = now()
              WHERE livekit_room_name = $4`,
            [durationSeconds, totalSpend, totalEarn, roomName],
          );
        }
      }

      return { received: true, action: 'session_completed', duration_seconds: durationSeconds };
    }

    if (event === 'participant_left') {
      this.logger.log(`Participant left room "${roomName}"`);

      if (this.databaseService?.isConnected) {
        // Optionally update session status if still active
        await this.databaseService.query(
          `UPDATE call_sessions
            SET status = 'completed'
            WHERE livekit_room_name = $1 AND status = 'active'`,
          [roomName],
        );
      }
      return { received: true, action: 'participant_left' };
    }

    return { received: true, event };
  }

  /**
   * Ends call session and stores ratings/feedback in call_sessions
   */
  async endCall(
    id: string,
    rating?: number,
    feedback?: string,
    isCaller: boolean = true,
  ) {
    if (this.databaseService?.isConnected) {
      const ratingField = isCaller ? 'caller_overall_rating' : 'callee_overall_rating';
      const feedbackField = isCaller ? 'caller_feedback' : 'callee_feedback';
      const ratingsJsonField = isCaller ? 'caller_ratings_json' : 'callee_ratings_json';

      const ratingsObj = JSON.stringify({ rating, feedback, submitted_at: new Date() });

      await this.databaseService.query(
        `UPDATE call_sessions
          SET status = 'completed',
              ended_at = COALESCE(ended_at, now()),
              ${ratingField} = COALESCE($1, ${ratingField}),
              ${feedbackField} = COALESCE($2, ${feedbackField}),
              ${ratingsJsonField} = $3::jsonb
          WHERE id::text = $4 OR livekit_room_name = $4`,
        [rating || null, feedback || null, ratingsObj, id],
      );
    }

    return {
      success: true,
      call_id: id,
      rating: rating || 5,
      feedback: feedback || '',
      message: 'Call session ended and feedback logged successfully.',
    };
  }

  async randomMatch(body: { user_id?: string; kind?: string }) {
    const currentUserId = body?.user_id || DEFAULT_CALLER_ID;
    const kind = (body?.kind as 'audio' | 'video') || 'audio';

    // Find candidate for blind random call
    let partnerId = DEFAULT_CALLEE_ID;
    if (this.databaseService?.isConnected) {
      try {
        const candidateRes = await this.databaseService.query(
          `SELECT user_id FROM user_profiles WHERE user_id != $1 LIMIT 1`,
          [currentUserId],
        );
        if (candidateRes.rows.length > 0) {
          partnerId = candidateRes.rows[0].user_id;
        }
      } catch (err: any) {
        this.logger.debug(`Random match DB lookup: ${err.message}`);
      }
    }

    return this.createToken({
      caller_id: currentUserId,
      callee_id: partnerId,
      kind: 'random',
      anonymous_avatar: true,
    });
  }
}