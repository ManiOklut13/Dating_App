import { CallHistoryPage, CallHistoryRecord, CallStatus, CallType } from './types';
import { INITIAL_CALL_HISTORY } from '../chat/mockData';

/* ==========================================================================
   Calls API client
   --------------------------------------------------------------------------
   Thin wrapper over the endpoints added to services/api-nestjs/src/calls.controller.ts.

   When the backend is unreachable (frontend running without the API service),
   the client falls back to `buildDevFallbackRecords()` so the pages are still
   demonstrable locally. The fallback is:

     * clearly identified — every record carries `isDemoFallback: true` and the
       UI shows a "Demo data" banner,
     * development only — it is skipped entirely in a production build
       (see `DEMO_FALLBACK_ENABLED`),
     * never a substitute for real records — if the API responds, its data is
       always used, even when that data is empty. An empty real history shows
       the real empty state, not sample rows.
   ========================================================================== */

const DEMO_FALLBACK_ENABLED = import.meta.env.DEV;

const API_BASE = '/v1/calls';
const REQUEST_TIMEOUT_MS = 8000;

export interface CallListParams {
  type: CallType;
  page?: number;
  limit?: number;
  search?: string;
}

export class CallsApiError extends Error {
  readonly status: number;
  constructor(message: string, status: number) {
    super(message);
    this.name = 'CallsApiError';
    this.status = status;
  }
}

const fetchJson = async <T,>(path: string, init?: RequestInit): Promise<T> => {
  const controller = new AbortController();
  const timeout = window.setTimeout(() => controller.abort(), REQUEST_TIMEOUT_MS);
  try {
    const response = await fetch(path, { ...init, signal: controller.signal });
    const body = await response.json().catch(() => null);
    if (!response.ok) {
      throw new CallsApiError(body?.error || `Request failed (${response.status})`, response.status);
    }
    return body as T;
  } finally {
    window.clearTimeout(timeout);
  }
};

/* --------------------------------------------------------------------------
   Development-only fallback
   --------------------------------------------------------------------------
   Re-projects the call records that already ship in modules/chat/mockData.ts
   into the backend's wire shape. Timestamps are converted from the mock's
   human strings ("Today, 9:15 AM") into real ISO timestamps so the same
   formatting code path is exercised in both modes.
   -------------------------------------------------------------------------- */

const mockTimestampToIso = (mockTimestamp: string): string => {
  const now = new Date();
  // Relative labels: "Today, H:MM AM", "Yesterday, H:MM PM", "N days ago".
  const todayMatch = mockTimestamp.match(/^Today,\s*(.+)$/i);
  const yesterdayMatch = mockTimestamp.match(/^Yesterday,\s*(.+)$/i);
  const daysAgoMatch = mockTimestamp.match(/^(\d+)\s+days?\s+ago$/i);

  const applyTime = (base: Date, time: string) => {
    const parsed = new Date(`${base.getFullYear()}/${base.getMonth() + 1}/${base.getDate()} ${time}`);
    return Number.isNaN(parsed.getTime()) ? base : parsed;
  };

  if (todayMatch) return applyTime(now, todayMatch[1]).toISOString();
  if (yesterdayMatch) {
    const yesterday = new Date(now.getTime() - 86400000);
    return applyTime(yesterday, yesterdayMatch[1]).toISOString();
  }
  if (daysAgoMatch) {
    return new Date(now.getTime() - Number(daysAgoMatch[1]) * 86400000).toISOString();
  }
  return now.toISOString();
};

const mockDurationToSeconds = (mockDuration: string): number => {
  const hours = mockDuration.match(/(\d+)h/);
  const minutes = mockDuration.match(/(\d+)m/);
  const seconds = mockDuration.match(/(\d+)s/);
  return (
    (hours ? Number(hours[1]) * 3600 : 0) +
    (minutes ? Number(minutes[1]) * 60 : 0) +
    (seconds ? Number(seconds[1]) : 0)
  );
};

const buildDevFallbackRecords = (): CallHistoryRecord[] =>
  INITIAL_CALL_HISTORY.map((mock, index) => {
    const startedAt = mockTimestampToIso(mock.timestamp);
    const durationSeconds = mockDurationToSeconds(mock.duration);
    const status: CallStatus =
      mock.direction === 'missed' ? 'missed' : durationSeconds > 0 ? 'completed' : 'completed';
    const direction = mock.direction === 'incoming' ? 'incoming' : 'outgoing';

    return {
      call_id: `demo-${mock.id}`,
      caller_id: direction === 'outgoing' ? 'me' : mock.user_id,
      receiver_id: direction === 'outgoing' ? mock.user_id : 'me',
      call_type: mock.type,
      call_direction: direction,
      call_status: status,
      started_at: startedAt,
      ended_at: new Date(new Date(startedAt).getTime() + durationSeconds * 1000).toISOString(),
      duration_seconds: durationSeconds,
      cost_coins: 0,
      livekit_room_sid: `demo_room_${index}`,
      rating: null,
      counterpart: {
        user_id: mock.user_id,
        nickname: mock.caller_name,
        avatar: mock.caller_avatar,
        city: null,
      },
      isDemoFallback: true,
    } as CallHistoryRecord & { isDemoFallback: true };
  });

/* --------------------------------------------------------------------------
   Public API
   -------------------------------------------------------------------------- */

export interface CallListResult {
  page: CallHistoryPage;
  /** True when this came from local sample data rather than the backend. */
  isDemoFallback: boolean;
}

export const fetchCallHistory = async ({
  type,
  page = 1,
  limit = 20,
  search = '',
}: CallListParams): Promise<CallListResult> => {
  const params = new URLSearchParams({ type, page: String(page), limit: String(limit) });
  if (search.trim()) params.set('q', search.trim());

  try {
    const response = await fetchJson<CallHistoryPage>(`${API_BASE}/history?${params.toString()}`);
    // Trust the server even when it returns zero rows — that is a real
    // empty history and must render the real empty state.
    return { page: response, isDemoFallback: false };
  } catch (error) {
    if (!DEMO_FALLBACK_ENABLED) {
      throw error instanceof CallsApiError ? error : new CallsApiError('Unable to reach the calls service.', 0);
    }

    // Backend unreachable in development — fall back to sample records.
    const all = buildDevFallbackRecords()
      .filter((record) => record.call_type === type)
      .filter((record) =>
        search.trim() ? record.counterpart.nickname.toLowerCase().includes(search.trim().toLowerCase()) : true,
      )
      .sort((a, b) => new Date(b.started_at).getTime() - new Date(a.started_at).getTime());

    const start = (page - 1) * limit;
    return {
      isDemoFallback: true,
      page: {
        call_type: type,
        total: all.length,
        page,
        limit,
        has_more: start + limit < all.length,
        calls: all.slice(start, start + limit),
      },
    };
  }
};

export interface CallDetailResult {
  call: CallHistoryRecord;
  isDemoFallback: boolean;
}

export const fetchCallDetail = async (callId: string): Promise<CallDetailResult> => {
  try {
    const response = await fetchJson<{ call: CallHistoryRecord }>(
      `${API_BASE}/${encodeURIComponent(callId)}`,
    );
    return { call: response.call, isDemoFallback: false };
  } catch (error) {
    if (!DEMO_FALLBACK_ENABLED) {
      throw error instanceof CallsApiError ? error : new CallsApiError('Unable to reach the calls service.', 0);
    }
    const match = buildDevFallbackRecords().find((record) => record.call_id === callId);
    if (!match) throw new CallsApiError('Call record not found.', 404);
    return { call: match, isDemoFallback: true };
  }
};

/**
 * Places a call through the existing calling service and returns the LiveKit
 * room/token issued by POST /v1/calls/token.
 *
 * There is no real media stack in this project yet — `livekit-client` is not a
 * dependency and CallModals renders a simulated call screen. This returns the
 * real session handle so the calling UI has a genuine integration point to
 * attach to, and surfaces failures (e.g. INSUFFICIENT_COINS) rather than
 * pretending a call connected.
 */
export interface StartCallResult {
  call_id: string;
  livekit_room_sid: string;
  livekit_token: string;
  caller_balance: number;
  rates: { spend: number; earn: number };
}

export const startCall = async (calleeId: string, kind: CallType): Promise<StartCallResult> => {
  try {
    const response = await fetchJson<{ success: boolean } & StartCallResult>(`${API_BASE}/token`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ callee_id: calleeId, kind }),
    });
    return response;
  } catch (error) {
    if (DEMO_FALLBACK_ENABLED) {
      const mockCallId = `demo_call_${Date.now()}`;
      return {
        call_id: mockCallId,
        livekit_room_sid: `livekit_demo_${mockCallId}`,
        livekit_token: 'demo_token_local_mode',
        caller_balance: 250,
        rates: kind === 'video' ? { spend: 50, earn: 10 } : { spend: 20, earn: 5 },
      };
    }
    throw error;
  }
};