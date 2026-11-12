export interface User {
  id: string;
  phone: string;
  email?: string;
  dob?: string;
  gender: string;
  is_verified: boolean;
  status: string;
}

export interface CandidateCard {
  user_id: string;
  nickname: string;
  age?: number;
  bio: string;
  city: string;
  distance_km: number;
  photo_urls: string[];
  is_verified: boolean;
  is_online?: boolean;
  shared_interests?: string[];
  profile_progress: number;
  gender?: string;
  last_active?: string;
  preference?: string;
  vibe_score?: number;
}

/**
 * An incoming "Likes You" entry.
 * IMPORTANT: a person who liked you is NOT a match — it only becomes a match
 * after you like them back (see the Like action in ConnectTab).
 * Production source: GET /v1/connect/likes-you (not implemented in this build).
 */
export interface IncomingLike {
  actor_id: string;
  nickname: string;
  age?: number;
  gender: string;
  avatar: string;
  bitmoji?: string;
  photo_urls: string[];
  city: string;
  /** General distance only — never an exact location. */
  distance_km: number;
  action: 'like' | 'spark';
  is_verified: boolean;
  is_online?: boolean;
  shared_interests: string[];
  bio: string;
  /** Restricted profiles stay limited even within the daily view limit. */
  is_restricted?: boolean;
  /** Demo-only match percentage shown over a limited-visibility photo. */
  match_percent?: number;
}

export interface MatchItem {
  id: string;
  matched_at: string;
  source: string;
  message_pair_count: number;
  counterpart: {
    user_id: string;
    nickname: string;
    age?: number;
    avatar: string;
    city: string;
    is_verified: boolean;
    is_online?: boolean;
    shared_interests?: string[];
    bio?: string;
    photo_urls?: string[];
    call_avatar_ref?: string;
    /** Vibe / compatibility score (0-100). Demo-only until the backend serves it. */
    vibe_score?: number;
  };
  last_message?: {
    body: string;
    type: string;
    created_at: string;
  };
  /** Unread messages in this conversation. Production source: GET /v1/matches. */
  unread_count?: number;
}

/**
 * A message request. Unlike a match, a request has NOT been accepted yet.
 * Previews here must never expose phone numbers, social handles, links or real
 * IDs (see sanitizePreview in ChatTab). Production source:
 * GET /v1/message-requests?direction=received|sent (not implemented in this build).
 */
export interface MessageRequest {
  id: string;
  user_id: string;
  nickname: string;
  age?: number;
  avatar: string;
  is_verified: boolean;
  is_online?: boolean;
  city?: string;
  /** Short intro message — capped at 150 characters by the composer. */
  message: string;
  direction: 'received' | 'sent';
  created_at: string;
}

export interface MessageItem {
  id: number;
  conv_id: string;
  sender_id: string;
  type: 'text' | 'bitmoji' | 'audio';
  body: string;
  media_url?: string;
  expires_at?: string | null;
  is_flagged: boolean;
  created_at: string;
}

export interface TransactionItem {
  id: string;
  user_id: string;
  type: 'grant' | 'purchase' | 'spend' | 'earn' | 'payout' | 'refund';
  coins: number;
  reference_id?: string;
  idempotency_key: string;
  created_at: string;
}


export type Gender = 'male' | 'female' | 'non-binary' | 'other';

export interface CallHistoryEntry {
  id: string;
  calleeId: string;
  name: string;
  avatar: string;
  city?: string;
  timestamp: string;
  duration: string;
  status: 'completed' | 'missed' | 'declined';
  vibeScore?: number;
}

export interface ScheduledDate {
  id: string;
  with_user_id: string;
  nickname: string;
  avatar: string;
  venue: string;
  address: string;
  city: string;
  scheduled_at: string;
  duration_mins: number;
  is_date: boolean;
  activity_type: string;
  dress_code: string;
  table_reservation?: string;
  romantic_milestone?: string;
  shared_playlist?: string;
  vibe_notes?: string;
  status: 'confirmed' | 'pending' | 'rescheduled';
}
