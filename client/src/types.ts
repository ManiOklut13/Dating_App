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
  bio: string;
  city: string;
  distance_km: number;
  photo_urls: string[];
  is_verified: boolean;
  profile_progress: number;
  vibe_score?: number;
}

export interface MatchItem {
  id: string;
  matched_at: string;
  source: string;
  message_pair_count: number;
  counterpart: {
    user_id: string;
    nickname: string;
    avatar: string;
    city: string;
    is_verified: boolean;
    call_avatar_ref?: string;
  };
  last_message?: {
    body: string;
    type: string;
    created_at: string;
  };
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
