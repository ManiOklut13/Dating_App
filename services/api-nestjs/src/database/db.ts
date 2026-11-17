/**
 * YoUnMe Dating App — In-Memory Database Adapter
 * Mirrors the 24-table PostgreSQL schema (v3.2) for local dev / fallback mode.
 * Table mapping:
 *   app_users           → AppUser
 *   user_profiles       → UserProfile
 *   swipes_interactions → SwipeInteraction
 *   matches             → Match
 *   chat_rooms          → ChatRoom
 *   chat_messages       → ChatMessage
 *   user_wallets        → UserWallet
 *   wallet_transactions → WalletTransaction
 */

// ==========================================
// 1. app_users
// ==========================================
export interface AppUser {
  id: string;
  authentication_uid: string;              // Supabase Auth UID
  email: string;
  email_verified: boolean;
  phone_country_code: string;
  phone_number: string;
  full_phone_number: string;
  phone_verified: boolean;
  google_sso_id?: string;
  apple_sso_id?: string;
  password_hash?: string;
  account_status: 'active' | 'deactivated' | 'restricted' | 'suspended' | 'deletion_pending' | 'deleted';
  deactivation_reason?: string;
  deletion_reason?: string;
  deactivated_at?: string;
  deletion_scheduled_at?: string;
  reactivate_after?: string;
  role: 'user' | 'moderator' | 'admin';
  referral_code?: string;
  referred_by_user_id?: string;
  created_at: string;
  updated_at: string;
  deleted_at?: string;
}

// ==========================================
// 2. user_profiles
// ==========================================
export interface UserProfile {
  user_id: string;
  first_name?: string;
  nickname: string;
  date_of_birth?: string;
  gender?: 'male' | 'female' | 'non_binary' | 'other';
  sexual_orientations: string[];
  looking_for: string[];
  languages: string[];
  interests: string[];
  bio?: string;
  profession?: string;
  education?: string;
  city?: string;
  country_code?: string;
  avatar_object_key?: string;
  random_avatar_object_key?: string;
  app_language: string;
  app_theme: string;
  chat_lock_passcode_hash?: string;
  read_receipts_status: boolean;
  profile_visibility: 'everyone' | 'limited' | 'hidden';
  show_online_status: boolean;
  who_can_message: 'everyone' | 'matches' | 'nobody';
  who_can_message_request: 'everyone' | 'matches' | 'nobody';
  push_notifications_enabled: boolean;
  push_notifications: Record<string, any>;
  email_notifications_enabled: boolean;
  email_notifications: Record<string, any>;
  min_age?: number;
  max_age?: number;
  max_distance_km?: number;
  is_verified: boolean;
  verification_status: 'not_started' | 'pending' | 'approved' | 'rejected' | 'manual_review';
  is_voice_verified: boolean;
  liveness_verified: boolean;
  face_embedding_vector?: number[];
  profile_progress: number;
  // PostGIS GEOGRAPHY(POINT,4326) represented as raw coordinates in-memory
  location?: { lat: number; lng: number };
  location_updated_at?: string;
  last_active_at?: string;
  created_at: string;
  updated_at: string;
}

// ==========================================
// 2b. user_photos
// ==========================================
export interface UserPhoto {
  id: string;
  user_id: string;
  photo_uri: string;
  display_order: number;
  is_primary: boolean;
  is_face_verified: boolean;
  caption?: string;
  comments_json: Record<string, any>;
  location_tag?: string;
  moderation_status: 'pending' | 'approved' | 'rejected';
  created_at: string;
  updated_at: string;
}

// ==========================================
// 3. swipes_interactions
// ==========================================
export interface SwipeInteraction {
  id: string;
  actor_user_id: string;
  target_user_id: string;
  action_type: 'like' | 'dislike' | 'spark' | 'snooze';
  is_message_request: boolean;
  message_request_id?: string;
  is_reverted: boolean;
  snoozed_until?: string;
  created_at: string;
}

// ==========================================
// 3b. user_quotas
// ==========================================
export interface UserQuota {
  user_id: string;
  quota_date: string;
  daily_sparks_left: number;
  daily_msg_requests_left: number;
  daily_snoozes_left: number;
  daily_reverts_left: number;
  daily_audio_call_mins_left: number;
  daily_video_call_mins_left: number;
  daily_random_audio_call_mins_left: number;
  daily_random_video_call_mins_left: number;
  lifetime_bonuses_json: Record<string, any>;
  updated_at: string;
}

// ==========================================
// 4. matches
// ==========================================
export interface Match {
  id: string;
  user_a_id: string;
  user_b_id: string;
  status: 'active' | 'unmatched' | 'blocked' | 'restricted' | 'reported';
  matched_at: string;
}

// ==========================================
// 5. chat_rooms
// ==========================================
export interface ChatRoom {
  id: string;
  match_id?: string;
  request_sender_id?: string;
  request_receiver_id?: string;
  request_status?: 'pending' | 'accepted' | 'declined';
  contact_share_unlocked: boolean;
  last_message_at?: string;
  created_at: string;
}

// ==========================================
// 6. chat_messages
// ==========================================
export interface ChatMessage {
  id: string;
  room_id: string;
  sender_id: string;
  message_type: 'text' | 'gif' | 'voice' | 'image' | 'sticker' | 'gift' | 'date_invite' | 'call_log' | 'memory_card';
  raw_content: string;
  is_view_once: boolean;
  scan_status: 'clean' | 'flagged_contact' | 'flagged_nsfw';
  is_flagged: boolean;
  is_message_pinned: boolean;
  message_pinned_by_user_id?: string;
  message_pinned_at?: string;
  status: 'sent' | 'delivered' | 'read' | 'failed';
  sent_at?: string;
  delivered_at?: string;
  read_at?: string;
  created_at: string;
}

// ==========================================
// 7. user_wallets
// ==========================================
export interface UserWallet {
  user_id: string;
  coin_balance: number;
  locked_coins: number;
  lifetime_earned_coins: number;
  lifetime_spent_coins: number;
  current_streak_days: number;
  longest_streak_days: number;
  last_claimed_date?: string;
  updated_at: string;
}

// ==========================================
// 8. wallet_transactions (append-only ledger)
// ==========================================
export type WalletTxType =
  | 'purchase'
  | 'random_audio_call_spend'
  | 'random_video_call_spend'
  | 'audio_call_spend'
  | 'video_call_spend'
  | 'virtual_date_coins_spent'
  | 'offline_date_coins_spend'
  | 'sparks_coins_spent'
  | 'message_request_coins_spent'
  | 'revert_coins_spent'
  | 'snooze_coins_spent'
  | 'rematch_coins_spent'
  | 'incoming_likes_full_profiles_view_coins_spent'
  | 'incoming_sparks_full_profiles_view_coins_spent'
  | 'most_recommended_potential_matches_full_profiles_view_coins_spent'
  | 'rewards'
  | 'spin_wheel_coins_earned'
  | 'payout'
  | 'admin_adjustment'
  | 'referrals_used'
  | 'login_time_first_use_reward_coins'
  | 'login_time_referral_link_coins_earned'
  | 'coins_earned_through_streaks'
  | 'gift_purchase'
  | 'gift_received'
  | 'gifts_bundle_redeemed/converted_to_coins'
  | 'extra_quota_spend';

export interface WalletTransaction {
  id: string;
  user_id: string;
  direction: 'incoming' | 'outgoing';
  tx_type: WalletTxType;
  coin_amount: number;
  balance_after: number;
  created_at: string;
}

// ==========================================
// 9. Discovery candidate card (projected from user_profiles + user_photos)
// ==========================================
export interface CandidateCard {
  user_id: string;
  nickname: string;
  bio: string;
  city: string;
  distance_km: number;
  age?: number;
  photo_urls: string[];
  is_verified: boolean;
  profile_progress: number;
  avatar_object_key?: string;
  vibe_score?: number;
}

// ==========================================
// 9. call_sessions (in-memory record for calls service fallback)
// ==========================================
export interface CallSessionRecord {
  id: string;
  livekit_room_name: string;
  caller_user_id: string;
  callee_user_id: string;
  match_id?: string;
  call_type: 'audio' | 'video';
  is_random_blind_call: boolean;
  status: 'initiating' | 'active' | 'completed' | 'missed' | 'declined';
  duration_seconds: number;
  audio_duration_seconds: number;
  video_duration_seconds: number;
  media_switches_log: Record<string, any>[];
  caller_coins_type: 'debited' | 'credited' | 'daily_free_calls' | 'subscription_plan_free_call';
  caller_coins: number;
  callee_coins_type: 'debited' | 'credited' | 'daily_free_calls' | 'subscription_plan_free_call';
  callee_coins: number;
  is_hidden_for_caller: boolean;
  is_hidden_for_callee: boolean;
  caller_ratings_json: Record<string, any>;
  callee_ratings_json: Record<string, any>;
  caller_overall_rating?: number;
  callee_overall_rating?: number;
  caller_feedback?: string;
  callee_feedback?: string;
  created_at: string;
  started_at?: string;
  ended_at?: string;
}

// ---------------------------------------------------------------------------
// Haversine in-memory distance simulation (mirrors PostGIS ST_Distance)
// ---------------------------------------------------------------------------
function calculateDistanceKm(lat1: number, lon1: number, lat2: number, lon2: number): number {
  const R = 6371;
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLon = ((lon2 - lon1) * Math.PI) / 180;
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos((lat1 * Math.PI) / 180) *
      Math.cos((lat2 * Math.PI) / 180) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return Math.round(R * c * 10) / 10;
}

// ---------------------------------------------------------------------------
// In-Memory Database Store — mirrors the live PostgreSQL schema
// ---------------------------------------------------------------------------
class DatabaseStore {
  public users: Map<string, AppUser> = new Map();
  public profiles: Map<string, UserProfile> = new Map();
  public photos: Map<string, UserPhoto[]> = new Map();
  public quotas: Map<string, UserQuota> = new Map();
  public swipes: SwipeInteraction[] = [];
  public matches: Map<string, Match> = new Map();
  public chatRooms: Map<string, ChatRoom> = new Map();
  public messages: ChatMessage[] = [];
  public wallets: Map<string, UserWallet> = new Map();
  public transactions: WalletTransaction[] = [];
  public calls: Map<string, CallSessionRecord> = new Map();

  constructor() {
    this.seedDefaults();
  }

  private makeId(): string {
    return `${Date.now()}-${Math.random().toString(36).substring(2, 9)}`;
  }

  private seedPhotos(userId: string, photoUris: string[]) {
    const now = new Date().toISOString();
    this.photos.set(
      userId,
      photoUris.map((photoUri, index) => ({
        id: `photo_${userId.slice(0, 4)}_${index + 1}`,
        user_id: userId,
        photo_uri: photoUri,
        display_order: index + 1,
        is_primary: index === 0,
        is_face_verified: true,
        comments_json: {},
        moderation_status: 'approved',
        created_at: now,
        updated_at: now,
      })),
    );
  }

  private seedQuota(userId: string) {
    const now = new Date().toISOString();
    this.quotas.set(userId, {
      user_id: userId,
      quota_date: now.split('T')[0],
      daily_sparks_left: 5,
      daily_msg_requests_left: 3,
      daily_snoozes_left: 5,
      daily_reverts_left: 5,
      daily_audio_call_mins_left: 0,
      daily_video_call_mins_left: 0,
      daily_random_audio_call_mins_left: 0,
      daily_random_video_call_mins_left: 0,
      lifetime_bonuses_json: {},
      updated_at: now,
    });
  }

  private seedDefaults() {
    // ── Arjun ──────────────────────────────────────────────────────────────
    const arjunId = '11111111-1111-1111-1111-111111111111';
    this.users.set(arjunId, {
      id: arjunId,
      authentication_uid: 'supabase_uid_arjun_111',
      email: 'arjun.mehta@younme.social',
      email_verified: true,
      phone_country_code: '+91',
      phone_number: '9820011111',
      full_phone_number: '+919820011111',
      phone_verified: true,
      account_status: 'active',
      role: 'user',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    });
    this.profiles.set(arjunId, {
      user_id: arjunId,
      nickname: 'Arjun',
      first_name: 'Arjun',
      date_of_birth: '1998-05-14',
      gender: 'male',
      sexual_orientations: ['straight'],
      looking_for: ['relationship'],
      languages: ['English', 'Hindi', 'Marathi'],
      bio: 'Building next-gen AI tech. Coffee addict, indie vinyl records & sunset runs across Bandra Bandstand ☕⚡',
      avatar_object_key: 'avatar_neon_tiger',
      profession: 'Tech Founder',
      city: 'Mumbai',
      country_code: 'IN',
      interests: ['coffee', 'vinyl_records', 'indie_music', 'running'],
      app_language: 'en',
      app_theme: 'dark',
      read_receipts_status: true,
      profile_visibility: 'everyone',
      show_online_status: true,
      who_can_message: 'everyone',
      who_can_message_request: 'everyone',
      push_notifications_enabled: true,
      push_notifications: {},
      email_notifications_enabled: true,
      email_notifications: {},
      min_age: 22,
      max_age: 30,
      max_distance_km: 50,
      is_verified: true,
      verification_status: 'approved',
      is_voice_verified: false,
      liveness_verified: true,
      profile_progress: 92,
      location: { lat: 19.0596, lng: 72.8295 },
      location_updated_at: new Date().toISOString(),
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    });
    this.wallets.set(arjunId, {
      user_id: arjunId,
      coin_balance: 250,
      locked_coins: 0,
      lifetime_earned_coins: 250,
      lifetime_spent_coins: 0,
      current_streak_days: 4,
      longest_streak_days: 7,
      updated_at: new Date().toISOString(),
    });
    this.transactions.push({
      id: 'tx_init_arjun',
      user_id: arjunId,
      direction: 'incoming',
      tx_type: 'rewards',
      coin_amount: 250,
      balance_after: 250,
      created_at: new Date().toISOString(),
    });

    // ── Ananya ─────────────────────────────────────────────────────────────
    const ananyaId = '22222222-2222-2222-2222-222222222222';
    this.users.set(ananyaId, {
      id: ananyaId,
      authentication_uid: 'supabase_uid_ananya_222',
      email: 'ananya.sharma@younme.social',
      email_verified: true,
      phone_country_code: '+91',
      phone_number: '9820022222',
      full_phone_number: '+919820022222',
      phone_verified: true,
      account_status: 'active',
      role: 'user',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    });
    this.profiles.set(ananyaId, {
      user_id: ananyaId,
      nickname: 'Ananya',
      first_name: 'Ananya',
      date_of_birth: '2000-08-22',
      gender: 'female',
      sexual_orientations: ['straight'],
      looking_for: ['relationship'],
      languages: ['English', 'Hindi'],
      bio: "UI designer & matcha lover 🍵 Seeking someone who laughs at witty dry humor. Let's explore quaint cafes or art galleries!",
      avatar_object_key: 'avatar_rose_glass',
      profession: 'Creative Designer',
      city: 'Mumbai',
      country_code: 'IN',
      interests: ['design', 'matcha', 'art', 'cafes'],
      app_language: 'en',
      app_theme: 'dark',
      read_receipts_status: true,
      profile_visibility: 'everyone',
      show_online_status: true,
      who_can_message: 'everyone',
      who_can_message_request: 'everyone',
      push_notifications_enabled: true,
      push_notifications: {},
      email_notifications_enabled: true,
      email_notifications: {},
      min_age: 23,
      max_age: 32,
      max_distance_km: 40,
      is_verified: true,
      verification_status: 'approved',
      is_voice_verified: false,
      liveness_verified: true,
      profile_progress: 95,
      location: { lat: 19.065, lng: 72.828 },
      location_updated_at: new Date().toISOString(),
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    });
    this.wallets.set(ananyaId, {
      user_id: ananyaId,
      coin_balance: 620,
      locked_coins: 0,
      lifetime_earned_coins: 620,
      lifetime_spent_coins: 0,
      current_streak_days: 12,
      longest_streak_days: 15,
      updated_at: new Date().toISOString(),
    });

    // ── Rohit ──────────────────────────────────────────────────────────────
    const rohitId = '33333333-3333-3333-3333-333333333333';
    this.users.set(rohitId, {
      id: rohitId,
      authentication_uid: 'supabase_uid_rohit_333',
      email: 'rohit.verma@younme.social',
      email_verified: true,
      phone_country_code: '+91',
      phone_number: '9820033333',
      full_phone_number: '+919820033333',
      phone_verified: true,
      account_status: 'active',
      role: 'user',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    });
    this.profiles.set(rohitId, {
      user_id: rohitId,
      nickname: 'Rohit',
      first_name: 'Rohit',
      date_of_birth: '1997-12-05',
      gender: 'male',
      sexual_orientations: ['straight'],
      looking_for: ['relationship'],
      languages: ['English', 'Hindi'],
      bio: 'Architecting spaces by day, chasing sunsets by evening. Fitness, rock climbing, and deep late-night conversations 🌇🧗‍♂️',
      avatar_object_key: 'avatar_ocean_breeze',
      profession: 'Architect',
      city: 'Mumbai',
      country_code: 'IN',
      interests: ['fitness', 'rock_climbing', 'architecture'],
      app_language: 'en',
      app_theme: 'dark',
      read_receipts_status: true,
      profile_visibility: 'everyone',
      show_online_status: true,
      who_can_message: 'everyone',
      who_can_message_request: 'everyone',
      push_notifications_enabled: true,
      push_notifications: {},
      email_notifications_enabled: true,
      email_notifications: {},
      min_age: 22,
      max_age: 30,
      max_distance_km: 50,
      is_verified: true,
      verification_status: 'approved',
      is_voice_verified: false,
      liveness_verified: true,
      profile_progress: 88,
      location: { lat: 19.1075, lng: 72.8263 },
      location_updated_at: new Date().toISOString(),
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    });
    this.wallets.set(rohitId, {
      user_id: rohitId,
      coin_balance: 180,
      locked_coins: 0,
      lifetime_earned_coins: 180,
      lifetime_spent_coins: 0,
      current_streak_days: 2,
      longest_streak_days: 5,
      updated_at: new Date().toISOString(),
    });

    // ── Riya ───────────────────────────────────────────────────────────────
    const riyaId = '44444444-4444-4444-4444-444444444444';
    this.users.set(riyaId, {
      id: riyaId,
      authentication_uid: 'supabase_uid_riya_444',
      email: 'riya.sen@younme.social',
      email_verified: true,
      phone_country_code: '+91',
      phone_number: '9820044444',
      full_phone_number: '+919820044444',
      phone_verified: true,
      account_status: 'active',
      role: 'user',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    });
    this.profiles.set(riyaId, {
      user_id: riyaId,
      nickname: 'Riya',
      first_name: 'Riya',
      date_of_birth: '2001-03-18',
      gender: 'female',
      sexual_orientations: ['straight'],
      looking_for: ['relationship'],
      languages: ['English', 'Bengali', 'Hindi'],
      bio: 'Curating art exhibitions, vintage bookstores, and jazz nights. Swipe right if you have an eclectic Spotify playlist 🎨🎷',
      avatar_object_key: 'avatar_midnight_pearl',
      profession: 'Art Curator',
      city: 'Mumbai',
      country_code: 'IN',
      interests: ['art', 'jazz', 'vintage', 'books'],
      app_language: 'en',
      app_theme: 'dark',
      read_receipts_status: true,
      profile_visibility: 'everyone',
      show_online_status: true,
      who_can_message: 'everyone',
      who_can_message_request: 'everyone',
      push_notifications_enabled: true,
      push_notifications: {},
      email_notifications_enabled: true,
      email_notifications: {},
      min_age: 23,
      max_age: 32,
      max_distance_km: 40,
      is_verified: true,
      verification_status: 'approved',
      is_voice_verified: false,
      liveness_verified: true,
      profile_progress: 85,
      location: { lat: 18.922, lng: 72.8347 },
      location_updated_at: new Date().toISOString(),
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    });
    this.wallets.set(riyaId, {
      user_id: riyaId,
      coin_balance: 340,
      locked_coins: 0,
      lifetime_earned_coins: 340,
      lifetime_spent_coins: 0,
      current_streak_days: 3,
      longest_streak_days: 8,
      updated_at: new Date().toISOString(),
    });

    // ── Profile photos + daily quotas ──────────────────────────────────────
    this.seedPhotos(arjunId, ['/arjun.jpg', '/arjun-2.jpg', '/arjun-3.jpg']);
    this.seedPhotos(ananyaId, ['/ananya.jpg', '/ananya-2.jpg', '/ananya-3.jpg']);
    this.seedPhotos(rohitId, ['/rohit.jpg', '/rohit-2.jpg', '/rohit-3.jpg']);
    this.seedPhotos(riyaId, ['/riya.jpg', '/riya-2.jpg', '/riya-3.jpg']);
    this.seedQuota(arjunId);
    this.seedQuota(ananyaId);
    this.seedQuota(rohitId);
    this.seedQuota(riyaId);

    // ── Pre-seed match + chat room + messages between Arjun & Ananya ───────
    const matchId = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
    const roomId  = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';

    this.matches.set(matchId, {
      id: matchId,
      user_a_id: arjunId,
      user_b_id: ananyaId,
      status: 'active',
      matched_at: new Date(Date.now() - 86400000).toISOString(),
    });

    this.chatRooms.set(roomId, {
      id: roomId,
      match_id: matchId,
      request_sender_id: ananyaId,
      request_receiver_id: arjunId,
      request_status: 'accepted',
      contact_share_unlocked: false,
      last_message_at: new Date(Date.now() - 3600000 * 10).toISOString(),
      created_at: new Date(Date.now() - 86400000).toISOString(),
    });

    this.messages.push(
      {
        id: `${this.makeId()}_1`,
        room_id: roomId,
        sender_id: ananyaId,
        message_type: 'text',
        raw_content: 'Hey Arjun! Saw you love filter kaapi and vinyl records. Have you tried Subko in Bandra?',
        is_view_once: false,
        scan_status: 'clean',
        is_flagged: false,
        is_message_pinned: false,
        status: 'read',
        created_at: new Date(Date.now() - 3600000 * 12).toISOString(),
      },
      {
        id: `${this.makeId()}_2`,
        room_id: roomId,
        sender_id: arjunId,
        message_type: 'text',
        raw_content: 'Subko is practically my second office! Their sourdough croissants and pour-over are unbeatable.',
        is_view_once: false,
        scan_status: 'clean',
        is_flagged: false,
        is_message_pinned: false,
        status: 'read',
        created_at: new Date(Date.now() - 3600000 * 11).toISOString(),
      },
      {
        id: `${this.makeId()}_3`,
        room_id: roomId,
        sender_id: ananyaId,
        message_type: 'text',
        raw_content: 'Haha great taste! What indie records are currently spinning on your turntable?',
        is_view_once: false,
        scan_status: 'clean',
        is_flagged: false,
        is_message_pinned: false,
        status: 'delivered',
        created_at: new Date(Date.now() - 3600000 * 10).toISOString(),
      },
    );

    // Pre-seed swipes (mutual like)
    this.swipes.push(
      {
        id: `swipe_arjun_ananya`,
        actor_user_id: arjunId,
        target_user_id: ananyaId,
        action_type: 'like',
        is_message_request: false,
        is_reverted: false,
        created_at: new Date(Date.now() - 86400000 * 2).toISOString(),
      },
      {
        id: `swipe_ananya_arjun`,
        actor_user_id: ananyaId,
        target_user_id: arjunId,
        action_type: 'like',
        is_message_request: false,
        is_reverted: false,
        created_at: new Date(Date.now() - 86400000).toISOString(),
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Atomic coin ledger — mirrors user_wallets + wallet_transactions upsert
  // ---------------------------------------------------------------------------
  public executeCoinTransaction(
    userId: string,
    direction: 'incoming' | 'outgoing',
    txType: WalletTxType,
    coinAmount: number,
  ): { balance: number; txId: string } {
    const wallet = this.wallets.get(userId) || {
      user_id: userId,
      coin_balance: 0,
      locked_coins: 0,
      lifetime_earned_coins: 0,
      lifetime_spent_coins: 0,
      current_streak_days: 0,
      longest_streak_days: 0,
      updated_at: new Date().toISOString(),
    };

    if (direction === 'outgoing' && wallet.coin_balance < coinAmount) {
      throw new Error(`INSUFFICIENT_COINS: Required ${coinAmount} coins, currently have ${wallet.coin_balance}`);
    }

    const newBalance =
      direction === 'incoming' ? wallet.coin_balance + coinAmount : wallet.coin_balance - coinAmount;

    wallet.coin_balance = newBalance;
    wallet.lifetime_earned_coins += direction === 'incoming' ? coinAmount : 0;
    wallet.lifetime_spent_coins  += direction === 'outgoing' ? coinAmount : 0;
    wallet.updated_at = new Date().toISOString();
    this.wallets.set(userId, wallet);

    const txId = `tx_${Date.now()}_${Math.random().toString(36).substring(2, 9)}`;
    this.transactions.push({
      id: txId,
      user_id: userId,
      direction,
      tx_type: txType,
      coin_amount: coinAmount,
      balance_after: newBalance,
      created_at: new Date().toISOString(),
    });

    return { balance: newBalance, txId };
  }

  // ---------------------------------------------------------------------------
  // PostGIS ST_DWithin in-memory simulation — mirrors discovery.service.ts query
  // ---------------------------------------------------------------------------
  public getNearbyCandidates(userId: string, maxRadiusKm: number = 50, limit: number = 10): CandidateCard[] {
    const userProfile = this.profiles.get(userId);
    const userLat = userProfile?.location?.lat ?? 19.0596;
    const userLng = userProfile?.location?.lng ?? 72.8295;

    // Exclude users already swiped (not reverted)
    const swipedTargetIds = new Set<string>(
      this.swipes
        .filter((s) => s.actor_user_id === userId && !s.is_reverted)
        .map((s) => s.target_user_id),
    );

    const candidates: CandidateCard[] = [];

    for (const [id, prof] of this.profiles.entries()) {
      if (id === userId) continue;
      if (swipedTargetIds.has(id)) continue;

      const user = this.users.get(id);
      if (!user || user.account_status !== 'active') continue;

      const dist = calculateDistanceKm(
        userLat,
        userLng,
        prof.location?.lat ?? 19.0596,
        prof.location?.lng ?? 72.8295,
      );
      if (dist <= maxRadiusKm) {
        const baseVibe = 75;
        const distPenalty = Math.min(20, Math.floor(dist * 0.8));
        const progressBonus = Math.floor(prof.profile_progress * 0.15);
        const vibeScore = Math.min(99, Math.max(60, baseVibe - distPenalty + progressBonus));
        const photoUrls = (this.photos.get(id) || [])
          .slice()
          .sort((a, b) => a.display_order - b.display_order)
          .map((photo) => photo.photo_uri);

        candidates.push({
          user_id: prof.user_id,
          nickname: prof.nickname,
          bio: prof.bio || '',
          city: prof.city || 'Mumbai',
          distance_km: dist,
          photo_urls: photoUrls.length > 0 ? photoUrls : ['/ananya.jpg'],
          is_verified: prof.is_verified,
          profile_progress: prof.profile_progress,
          avatar_object_key: prof.avatar_object_key,
          vibe_score: vibeScore,
        });
      }
    }

    candidates.sort((a, b) => a.distance_km - b.distance_km);
    return candidates.slice(0, limit);
  }

  // ---------------------------------------------------------------------------
  // Swipe recording — mirrors swipes_interactions + matches upsert
  // ---------------------------------------------------------------------------
  public recordSwipe(
    actorId: string,
    targetId: string,
    actionType: 'like' | 'dislike' | 'spark' | 'snooze',
  ): { isMatch: boolean; matchId?: string } {
    // Upsert (conflict on actor_user_id, target_user_id)
    const existing = this.swipes.find(
      (s) => s.actor_user_id === actorId && s.target_user_id === targetId,
    );
    if (existing) {
      existing.action_type = actionType;
      existing.is_reverted = false;
      existing.created_at = new Date().toISOString();
    } else {
      this.swipes.push({
        id: `swipe_${this.makeId()}`,
        actor_user_id: actorId,
        target_user_id: targetId,
        action_type: actionType,
        is_message_request: false,
        is_reverted: false,
        created_at: new Date().toISOString(),
      });
    }

    if (actionType === 'like' || actionType === 'spark') {
      const reciprocal = this.swipes.find(
        (s) =>
          s.actor_user_id === targetId &&
          s.target_user_id === actorId &&
          (s.action_type === 'like' || s.action_type === 'spark') &&
          !s.is_reverted,
      );

      if (reciprocal) {
        const userA = actorId < targetId ? actorId : targetId;
        const userB = actorId < targetId ? targetId : actorId;
        const matchId = `match_${userA.slice(0, 4)}_${userB.slice(0, 4)}_${Date.now()}`;

        this.matches.set(matchId, {
          id: matchId,
          user_a_id: userA,
          user_b_id: userB,
          status: 'active',
          matched_at: new Date().toISOString(),
        });

        return { isMatch: true, matchId };
      }
    }

    return { isMatch: false };
  }

  // ---------------------------------------------------------------------------
  // Revert last non-reverted swipe — mirrors swipes_interactions UPDATE
  // ---------------------------------------------------------------------------
  public revertLastSwipe(actorId: string): { restoredTargetId?: string; success: boolean } {
    for (let i = this.swipes.length - 1; i >= 0; i--) {
      if (this.swipes[i].actor_user_id === actorId && !this.swipes[i].is_reverted) {
        this.swipes[i].is_reverted = true;
        return { restoredTargetId: this.swipes[i].target_user_id, success: true };
      }
    }
    return { success: false };
  }
}

export const db = new DatabaseStore();
