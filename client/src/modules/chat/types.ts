export interface UserProfile {
  id: string;
  nickname: string;
  avatar: string;
  photos?: string[];
  age: number;
  city: string;
  occupation: string;
  bio: string;
  interests: string[];
  is_verified: boolean;
  is_online: boolean;
  last_seen?: string;
  vibe_score: number;
  phone_masked?: string;
}

export interface ChatMessage {
  id: string;
  conv_id: string;
  sender_id: string; // 'me' | counterpart.id | 'system'
  type: 'text' | 'image' | 'gif' | 'audio' | 'sticker' | 'icebreaker' | 'date_invite' | 'match_system';
  body: string;
  media_url?: string;
  audio_duration?: string;
  icebreaker_prompt?: {
    question: string;
    answer?: string;
  };
  date_invite?: {
    id: string;
    activity: string;
    date: string;
    time: string;
    location?: string;
    status: 'pending' | 'accepted' | 'declined';
  };
  sticker_id?: string;
  is_flagged?: boolean;
  vanish_seconds?: number | null;
  status: 'sending' | 'sent' | 'delivered' | 'read';
  created_at: string;
}

export interface ChatConversation {
  id: string;
  counterpart: UserProfile;
  is_pinned: boolean;
  is_muted: boolean;
  is_locked: boolean;
  unread_count: number;
  wallpaper?: string;
  disappearing_mode?: 'off' | '60s' | '24h' | '7d';
  last_message: ChatMessage;
}

export interface MessageRequest {
  id: string;
  user_id: string;
  nickname: string;
  avatar: string;
  age: number;
  city: string;
  occupation: string;
  bio: string;
  is_verified: boolean;
  vibe_score: number;
  message: string;
  created_at: string;
  status: 'pending' | 'accepted' | 'declined';
}

export interface SentRequest {
  id: string;
  user_id: string;
  nickname: string;
  avatar: string;
  age: number;
  city: string;
  occupation: string;
  message: string;
  status: 'pending' | 'viewed';
  created_at: string;
}

export interface CallRecord {
  id: string;
  user_id: string;
  caller_name: string;
  caller_avatar: string;
  type: 'audio' | 'video';
  direction: 'incoming' | 'outgoing' | 'missed';
  duration: string;
  timestamp: string;
}

export interface ChatSettings {
  who_can_message: 'everyone' | 'matches' | 'nobody';
  show_online_status: boolean;
  read_receipts: boolean;
  dm_notifications: boolean;
  call_alerts: boolean;
  sound_effects: boolean;
  dark_mode: boolean;
  blocked_users: { id: string; name: string; avatar: string; date: string }[];
  restricted_users: { id: string; name: string; avatar: string; date: string }[];
}
