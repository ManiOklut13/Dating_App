/**
 * Wire types for the Calls pages. These mirror the payload returned by
 * services/api-nestjs/src/calls.controller.ts (GET /v1/calls/history,
 * GET /v1/calls/:id, POST /v1/calls).
 */

export type CallType = 'audio' | 'video';

/** Direction is from the authenticated user's point of view. */
export type CallDirection = 'incoming' | 'outgoing';

/** `missed` implies incoming; `declined` implies outgoing was not answered. */
export type CallStatus = 'completed' | 'missed' | 'declined' | 'failed';

export interface CallCounterpart {
  user_id: string;
  nickname: string;
  avatar: string;
  city?: string | null;
}

export interface CallHistoryRecord {
  call_id: string;
  caller_id: string;
  receiver_id: string;
  call_type: CallType;
  call_direction: CallDirection;
  call_status: CallStatus;
  started_at: string;
  ended_at: string | null;
  /** Derived server-side from started_at / ended_at. */
  duration_seconds: number;
  cost_coins: number;
  livekit_room_sid: string;
  rating: number | null;
  counterpart: CallCounterpart;
}

export interface CallHistoryPage {
  call_type: CallType | 'all';
  total: number;
  page: number;
  limit: number;
  has_more: boolean;
  calls: CallHistoryRecord[];
}

export const CALL_STATUS_META: Record<
  CallStatus,
  { label: string; color: string; tint: string }
> = {
  completed: { label: 'Completed', color: '#00e676', tint: 'rgba(0, 230, 118, 0.15)' },
  missed: { label: 'Missed', color: '#ff4757', tint: 'rgba(255, 71, 87, 0.15)' },
  declined: { label: 'Declined', color: '#ffa502', tint: 'rgba(255, 165, 2, 0.15)' },
  failed: { label: 'Failed', color: '#ff2d55', tint: 'rgba(255, 45, 85, 0.15)' },
};

export const CALL_DIRECTION_META: Record<
  CallDirection,
  { label: string; color: string }
> = {
  incoming: { label: 'Incoming', color: '#00e676' },
  outgoing: { label: 'Outgoing', color: '#00e5ff' },
};

/** "14m 20s" / "1h 04m" / "0s" */
export const formatDuration = (seconds: number): string => {
  const safe = Math.max(0, Math.round(seconds || 0));
  const hours = Math.floor(safe / 3600);
  const minutes = Math.floor((safe % 3600) / 60);
  const secs = safe % 60;
  if (hours > 0) return `${hours}h ${String(minutes).padStart(2, '0')}m`;
  if (minutes > 0) return `${minutes}m ${String(secs).padStart(2, '0')}s`;
  return `${secs}s`;
};

/** Readable local date + time, e.g. "13 Oct 2026, 9:15 AM". */
export const formatCallDateTime = (iso: string): string => {
  const date = new Date(iso);
  if (Number.isNaN(date.getTime())) return 'Unknown date';
  return date.toLocaleString(undefined, {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
    hour: 'numeric',
    minute: '2-digit',
  });
};

/** Short relative label used in list rows. */
export const formatRelativeDay = (iso: string): string => {
  const date = new Date(iso);
  if (Number.isNaN(date.getTime())) return 'Unknown';
  const now = new Date();
  const startOfDay = (d: Date) => new Date(d.getFullYear(), d.getMonth(), d.getDate()).getTime();
  const diffDays = Math.round((startOfDay(now) - startOfDay(date)) / 86400000);

  if (diffDays <= 0) {
    return `Today, ${date.toLocaleTimeString(undefined, { hour: 'numeric', minute: '2-digit' })}`;
  }
  if (diffDays === 1) return 'Yesterday';
  if (diffDays < 7) return `${diffDays} days ago`;
  return date.toLocaleDateString(undefined, { day: 'numeric', month: 'short', year: 'numeric' });
};