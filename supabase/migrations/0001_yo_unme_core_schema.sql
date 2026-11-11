-- =====================================================================
-- YoUnMe Dating App — Master Technical Architecture Schema
-- Database: Supabase Managed PostgreSQL + PostGIS
-- =====================================================================
--
--  !!  DESTRUCTIVE — THIS SCRIPT TEARS DOWN EVERY TABLE BEFORE REBUILDING.
--      Section "TEARDOWN" runs `DROP TABLE IF EXISTS ... CASCADE` on all 24
--      tables, so running this against a database that holds real data WILL
--      destroy it.
--
--      • Fresh/empty database  -> this file is correct, run it.
--      • Live database          -> run supabase/migrations/0002_*.sql instead
--                                   (incremental, non-destructive) and use
--                                   `supabase db push`.
--
--  Every change made after a database was first created also lives as an
--  incremental migration under supabase/migrations/ — those are the files
--  you apply to a live project.
-- =====================================================================

-- 0. EXTENSIONS & SEARCH PATH
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";
SET search_path = public;

-- =====================================================================
-- TEARDOWN: Cleanly remove all existing tables in reverse dependency
-- =====================================================================
DROP TABLE IF EXISTS date_memories CASCADE;
DROP TABLE IF EXISTS meetup CASCADE;
DROP TABLE IF EXISTS user_blocks_reports CASCADE;
DROP TABLE IF EXISTS wallet_transactions CASCADE;
DROP TABLE IF EXISTS user_wallets CASCADE;
DROP TABLE IF EXISTS call_sessions CASCADE;
DROP TABLE IF EXISTS chat_participant_settings CASCADE;
DROP TABLE IF EXISTS chat_messages CASCADE;
DROP TABLE IF EXISTS swipes_interactions CASCADE;
DROP TABLE IF EXISTS chat_rooms CASCADE;
DROP TABLE IF EXISTS user_gifts CASCADE;
DROP TABLE IF EXISTS gifts CASCADE;
DROP TABLE IF EXISTS matches CASCADE;
DROP TABLE IF EXISTS user_quotas CASCADE;
DROP TABLE IF EXISTS user_prompt_answers CASCADE;
DROP TABLE IF EXISTS prompts_master CASCADE;
DROP TABLE IF EXISTS user_photos CASCADE;
DROP TABLE IF EXISTS user_profiles CASCADE;
DROP TABLE IF EXISTS payout_requests CASCADE;
DROP TABLE IF EXISTS user_payout_kyc CASCADE;
DROP TABLE IF EXISTS user_subscriptions CASCADE;
DROP TABLE IF EXISTS payment_orders CASCADE;
DROP TABLE IF EXISTS plans CASCADE;
DROP TABLE IF EXISTS app_users CASCADE;

-- Legacy table drops from previous versions
DROP TABLE IF EXISTS transactions CASCADE;
DROP TABLE IF EXISTS wallets CASCADE;
DROP TABLE IF EXISTS calls CASCADE;
DROP TABLE IF EXISTS messages CASCADE;
DROP TABLE IF EXISTS swipes CASCADE;
DROP TABLE IF EXISTS profiles CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- ==========================================
-- 1. AUTHENTICATION & CORE IDENTITY
-- ==========================================
CREATE TABLE app_users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    authentication_uid VARCHAR(128) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    email_verified BOOLEAN DEFAULT FALSE,
    phone_country_code VARCHAR(8) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    full_phone_number VARCHAR(32) GENERATED ALWAYS AS (phone_country_code || phone_number) STORED UNIQUE,
    phone_verified BOOLEAN NOT NULL DEFAULT false,
    
    -- SSO & Credentials
    google_sso_id VARCHAR(128) UNIQUE,
    apple_sso_id VARCHAR(128) UNIQUE,
    password_hash TEXT,                                    -- Optional local password hash if not purely SSO

    -- Account Lifecycle State
    account_status TEXT NOT NULL DEFAULT 'active'
        CHECK (account_status IN ('active','deactivated','restricted','suspended','deletion_pending','deleted')),
    deactivation_reason TEXT,
    deletion_reason TEXT,
    deactivated_at TIMESTAMPTZ,
    deletion_scheduled_at TIMESTAMPTZ,
    reactivate_after TIMESTAMPTZ,

    role TEXT NOT NULL DEFAULT 'user' CHECK (role IN ('user','moderator','admin')),
    referral_code VARCHAR(16) UNIQUE,
    referred_by_user_id UUID REFERENCES app_users(id) ON DELETE SET NULL,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

-- ==========================================
-- 2. CONSOLIDATED PROFILES & PREFERENCES
-- ==========================================
CREATE TABLE user_profiles (
    user_id UUID PRIMARY KEY REFERENCES app_users(id) ON DELETE CASCADE,
    first_name TEXT,
    nickname VARCHAR(40) NOT NULL,
    date_of_birth DATE,
    gender TEXT CHECK (gender IN ('male','female','non_binary','other')),
    sexual_orientations TEXT[] NOT NULL DEFAULT '{}',
    looking_for TEXT[] NOT NULL DEFAULT '{}',
    languages TEXT[] NOT NULL DEFAULT '{}',
    interests TEXT[] NOT NULL DEFAULT '{}',
    bio VARCHAR(500),
    profession VARCHAR(120),
    education VARCHAR(160),
    city VARCHAR(120),
    country_code CHAR(2),
    
    -- Avatars & Customization
    avatar_object_key TEXT,                                -- Customized face avatar asset
    random_avatar_object_key TEXT,                         -- Random pre-built avatar asset

    -- App & UI Settings
    app_language VARCHAR(10) NOT NULL DEFAULT 'en',
    app_theme VARCHAR(10) NOT NULL DEFAULT 'dark',
    chat_lock_passcode_hash VARCHAR(128),                  -- Global PIN passcode to view all locked chats
    read_receipts_status BOOLEAN NOT NULL DEFAULT true,    -- Global read receipts toggle
    profile_visibility TEXT NOT NULL DEFAULT 'everyone'
        CHECK (profile_visibility IN ('everyone','limited','hidden')),
    show_online_status BOOLEAN NOT NULL DEFAULT true,
    who_can_message TEXT NOT NULL DEFAULT 'everyone'
        CHECK (who_can_message IN ('everyone', 'matches', 'nobody')),
    who_can_message_request TEXT NOT NULL DEFAULT 'everyone'
        CHECK (who_can_message_request IN ('everyone', 'matches', 'nobody')),
    push_notifications_enabled BOOLEAN NOT NULL DEFAULT true,
    push_notifications JSONB NOT NULL DEFAULT '{}'::jsonb,
    email_notifications_enabled BOOLEAN NOT NULL DEFAULT true,
    email_notifications JSONB NOT NULL DEFAULT '{}'::jsonb,

    -- Discovery Preferences
    min_age SMALLINT DEFAULT 18,
    max_age SMALLINT DEFAULT 50,
    max_distance_km INTEGER DEFAULT 50,

    -- Verification & Biometric Flags
    is_verified BOOLEAN NOT NULL DEFAULT false,
    verification_status TEXT NOT NULL DEFAULT 'not_started'
        CHECK (verification_status IN ('not_started','pending','approved','rejected','manual_review')),
    is_voice_verified BOOLEAN NOT NULL DEFAULT false,
    liveness_verified BOOLEAN NOT NULL DEFAULT false,
    face_embedding_vector REAL[],
    profile_progress SMALLINT NOT NULL DEFAULT 0 CHECK (profile_progress BETWEEN 0 AND 100),

    -- Geographic Location (PostGIS) — single source of truth.
    -- latitude/longitude were removed: the client now writes `location`
    -- directly as ST_SetSRID(ST_MakePoint(lng, lat), 4326)::geography, and
    -- the trg_user_profiles_geo_sync trigger keeps location_updated_at fresh.
    location GEOGRAPHY(POINT, 4326),
    location_updated_at TIMESTAMPTZ,
    last_active_at TIMESTAMPTZ,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_user_profiles_location ON user_profiles USING GIST (location);

-- ==========================================
-- 3. USER PHOTOS & MEDIA
-- ==========================================
CREATE TABLE user_photos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES app_users(id) ON DELETE CASCADE,
    photo_uri TEXT NOT NULL,
    display_order SMALLINT NOT NULL CHECK (display_order BETWEEN 1 AND 7),
    is_primary BOOLEAN NOT NULL DEFAULT false,
    is_face_verified BOOLEAN NOT NULL DEFAULT false,       -- Photo-specific facial verification flag
    caption VARCHAR(300),                                  -- Short text description below photo
    comments_json JSONB NOT NULL DEFAULT '{}'::jsonb,       -- Photo comments stored as a JSON object
    location_tag VARCHAR(128),                             -- Tagged location for the photo
    moderation_status TEXT NOT NULL DEFAULT 'pending'
        CHECK (moderation_status IN ('pending', 'approved', 'rejected')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_user_photos_order ON user_photos (user_id, display_order);

-- ==========================================
-- 4. ICEBREAKER PROMPTS & USER ANSWERS
-- ==========================================
CREATE TABLE prompts_master (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    prompt_text VARCHAR(200) NOT NULL,
    prompt_type TEXT NOT NULL DEFAULT 'text' CHECK (prompt_type IN ('text', 'multiple_choice', 'location')),
    options_json JSONB DEFAULT '[]',
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE user_prompt_answers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES app_users(id) ON DELETE CASCADE,
    prompt_id UUID REFERENCES prompts_master(id) ON DELETE CASCADE,
    answer_text TEXT NOT NULL,
    display_order SMALLINT DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (user_id, prompt_id)
);

-- ==========================================
-- 5. SWIPES, INTERACTIONS & QUOTAS
-- ==========================================
CREATE TABLE swipes_interactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_user_id UUID REFERENCES app_users(id) ON DELETE CASCADE,
    target_user_id UUID REFERENCES app_users(id) ON DELETE CASCADE,
    action_type TEXT NOT NULL CHECK (action_type IN ('like', 'dislike', 'spark', 'snooze')),
    is_message_request BOOLEAN NOT NULL DEFAULT false,
    message_request_id UUID, -- FK added after chat_messages is created
    is_reverted BOOLEAN DEFAULT false,
    snoozed_until TIMESTAMPTZ,                              -- When a 'snooze' swipe becomes eligible again
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (actor_user_id, target_user_id)
);

CREATE INDEX idx_swipes_actor_target ON swipes_interactions(actor_user_id, target_user_id);

CREATE TABLE user_quotas (
    user_id UUID PRIMARY KEY REFERENCES app_users(id) ON DELETE CASCADE,
    quota_date DATE NOT NULL DEFAULT CURRENT_DATE,
    daily_sparks_left SMALLINT NOT NULL DEFAULT 5,
    daily_msg_requests_left SMALLINT NOT NULL DEFAULT 3,
    daily_snoozes_left SMALLINT NOT NULL DEFAULT 5,
    daily_reverts_left SMALLINT NOT NULL DEFAULT 5,
    daily_audio_call_mins_left SMALLINT NOT NULL DEFAULT 0,
    daily_video_call_mins_left SMALLINT NOT NULL DEFAULT 0,
    daily_random_audio_call_mins_left SMALLINT NOT NULL DEFAULT 0,
    daily_random_video_call_mins_left SMALLINT NOT NULL DEFAULT 0,
    lifetime_bonuses_json JSONB NOT NULL DEFAULT '{}',     -- Flexible pool for extra spin-wheel/reward add-ons
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ==========================================
-- 6. MATCHES
-- ==========================================
CREATE TABLE matches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_a_id UUID REFERENCES app_users(id) ON DELETE CASCADE,
    user_b_id UUID REFERENCES app_users(id) ON DELETE CASCADE,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'unmatched', 'blocked', 'restricted', 'reported')),
    matched_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (user_a_id, user_b_id)
);

CREATE INDEX idx_matches_users ON matches(user_a_id, user_b_id);

-- ==========================================
-- 7. GIFTS & COLLECTIBLES CATALOG
-- ==========================================
CREATE TABLE gifts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(64) NOT NULL,
    uri TEXT NOT NULL,                                     -- Asset URI / Image / Icon
    gift_type VARCHAR(32) NOT NULL CHECK (gift_type IN ('gift_pack', 'sticker', 'avatar_asset', 'dress_item')),
    coins_cost INTEGER NOT NULL DEFAULT 0,
    is_free BOOLEAN NOT NULL DEFAULT false,
    is_free_for_subscribed_user BOOLEAN NOT NULL DEFAULT false,
    count_required_to_convert_coins INTEGER DEFAULT 0,     -- Required quantity to redeem/convert to coins
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE user_gifts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES app_users(id) ON DELETE CASCADE,
    gift_id UUID REFERENCES gifts(id) ON DELETE CASCADE,
    gift_received_at_type TEXT NOT NULL CHECK (gift_received_at_type IN ('purchased', 'sent_by_user', 'reward_earned')),
    sender_id UUID REFERENCES app_users(id) ON DELETE SET NULL,
    received_date TIMESTAMPTZ NOT NULL DEFAULT now(),
    expires_at TIMESTAMPTZ                                 -- Null if permanent collectible
);

-- ==========================================
-- 8. CHAT ROOMS, PARTICIPANT SETTINGS & MESSAGES
-- ==========================================
CREATE TABLE chat_rooms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    match_id UUID REFERENCES matches(id) ON DELETE CASCADE UNIQUE,
    
    -- Explicit Message Request Fields
    request_sender_id UUID REFERENCES app_users(id) ON DELETE CASCADE,
    request_receiver_id UUID REFERENCES app_users(id) ON DELETE CASCADE,
    request_status TEXT CHECK (request_status IN ('pending', 'accepted', 'declined')),

    -- Contact & Link Guard: unlocks phone/handle/URL sharing in this room
    -- after 3 days of active matching or 20 message pairs exchanged.
    contact_share_unlocked BOOLEAN NOT NULL DEFAULT false,

    last_message_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE chat_participant_settings (
    room_id UUID REFERENCES chat_rooms(id) ON DELETE CASCADE,
    user_id UUID REFERENCES app_users(id) ON DELETE CASCADE,
    nickname_override VARCHAR(40),
    theme_id VARCHAR(32) DEFAULT 'default',
    wallpaper_uri VARCHAR(255),
    disappearing_messages_ttl INTEGER DEFAULT 0,
    is_hidden BOOLEAN DEFAULT false,
    is_muted BOOLEAN DEFAULT false,
    is_chat_pinned BOOLEAN DEFAULT false,                  -- Pinned chat thread toggle
    chat_pinned_at TIMESTAMPTZ,
    cleared_history_before_at TIMESTAMPTZ,
    PRIMARY KEY (room_id, user_id)
);

CREATE TABLE chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_id UUID REFERENCES chat_rooms(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES app_users(id) ON DELETE CASCADE,
    message_type TEXT NOT NULL DEFAULT 'text' CHECK (message_type IN ('text', 'gif', 'voice', 'image', 'sticker', 'gift', 'date_invite', 'call_log', 'memory_card')),
    raw_content TEXT NOT NULL,
    is_view_once BOOLEAN DEFAULT false,
    scan_status TEXT NOT NULL DEFAULT 'clean' CHECK (scan_status IN ('clean', 'flagged_contact', 'flagged_nsfw')),
    is_flagged BOOLEAN NOT NULL DEFAULT false,              -- Contact & Link Guard flag: message contains contact details
    
    -- Message Pinning
    is_message_pinned BOOLEAN DEFAULT false,
    message_pinned_by_user_id UUID REFERENCES app_users(id) ON DELETE CASCADE,
    message_pinned_at TIMESTAMPTZ DEFAULT now(),

    -- Read Receipts & Delivery Status
    status TEXT NOT NULL DEFAULT 'sent' CHECK (status IN ('sent', 'delivered', 'read', 'failed')),
    sent_at TIMESTAMPTZ,
    delivered_at TIMESTAMPTZ,
    read_at TIMESTAMPTZ,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_chat_messages_room_created ON chat_messages(room_id, created_at DESC);

ALTER TABLE swipes_interactions
    ADD CONSTRAINT fk_swipes_message_request
    FOREIGN KEY (message_request_id) REFERENCES chat_messages(id) ON DELETE SET NULL;

-- ==========================================
-- 9. LIVEKIT CLOUD CALL SESSIONS & FEEDBACK
-- ==========================================
CREATE TABLE call_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    livekit_room_name VARCHAR(128) UNIQUE NOT NULL,
    caller_user_id UUID REFERENCES app_users(id) ON DELETE CASCADE,
    callee_user_id UUID REFERENCES app_users(id) ON DELETE CASCADE,
    match_id UUID REFERENCES matches(id) ON DELETE SET NULL,
    call_type TEXT NOT NULL CHECK (call_type IN ('audio', 'video')),
    is_random_blind_call BOOLEAN NOT NULL DEFAULT false,
    status TEXT NOT NULL DEFAULT 'initiating' CHECK (status IN ('initiating', 'active', 'completed', 'missed', 'declined')),
    
    -- Durations & Mid-Call Switch Tracking
    duration_seconds INTEGER DEFAULT 0,
    audio_duration_seconds INTEGER DEFAULT 0,
    video_duration_seconds INTEGER DEFAULT 0,
    media_switches_log JSONB DEFAULT '[]',
    
    -- Granular Financial Split
    caller_coins_type TEXT NOT NULL CHECK (caller_coins_type IN ('debited', 'credited', 'daily_free_calls', 'subscription_plan_free_call')),
    caller_coins INTEGER DEFAULT 0,
    callee_coins_type TEXT NOT NULL CHECK (callee_coins_type IN ('debited', 'credited', 'daily_free_calls', 'subscription_plan_free_call')),
    callee_coins INTEGER DEFAULT 0,
    
    -- Per-User History Hiding
    is_hidden_for_caller BOOLEAN NOT NULL DEFAULT false,
    is_hidden_for_callee BOOLEAN NOT NULL DEFAULT false,

    -- Multi-Category Ratings & Feedback JSON
    caller_ratings_json JSONB DEFAULT '{}',
    callee_ratings_json JSONB DEFAULT '{}',

    -- Ratings & Feedback
    caller_overall_rating SMALLINT CHECK (caller_overall_rating BETWEEN 1 AND 5),
    callee_overall_rating SMALLINT CHECK (callee_overall_rating BETWEEN 1 AND 5),
    caller_feedback TEXT,
    callee_feedback TEXT,

    started_at TIMESTAMPTZ,
    ended_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ==========================================
-- 10. WALLETS & LEDGER TRANSACTIONS
-- ==========================================
CREATE TABLE user_wallets (
    user_id UUID PRIMARY KEY REFERENCES app_users(id) ON DELETE CASCADE,
    coin_balance INTEGER NOT NULL DEFAULT 0 CHECK (coin_balance >= 0),
    locked_coins INTEGER NOT NULL DEFAULT 0,
    lifetime_earned_coins INTEGER NOT NULL DEFAULT 0,
    lifetime_spent_coins INTEGER NOT NULL DEFAULT 0,
    current_streak_days INTEGER NOT NULL DEFAULT 0,
    longest_streak_days INTEGER NOT NULL DEFAULT 0,
    last_claimed_date DATE,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE wallet_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES app_users(id) ON DELETE CASCADE,
    direction TEXT NOT NULL CHECK (direction IN ('incoming', 'outgoing')),
    tx_type TEXT NOT NULL CHECK (tx_type IN (
        'purchase', 'random_audio_call_spend', 'random_video_call_spend', 
        'audio_call_spend', 'video_call_spend', 'virtual_date_coins_spent', 
        'offline_date_coins_spend', 'sparks_coins_spent', 'message_request_coins_spent', 
        'revert_coins_spent', 'snooze_coins_spent', 'rematch_coins_spent', 
        'incoming_likes_full_profiles_view_coins_spent', 'incoming_sparks_full_profiles_view_coins_spent', 
        'most_recommended_potential_matches_full_profiles_view_coins_spent', 'rewards', 
        'spin_wheel_coins_earned', 'payout', 'admin_adjustment', 'referrals_used', 
        'login_time_first_use_reward_coins', 'login_time_referral_link_coins_earned', 
        'coins_earned_through_streaks', 'gift_purchase', 'gift_received', 
        'gifts_bundle_redeemed/converted_to_coins', 'extra_quota_spend'
    )),
    coin_amount INTEGER NOT NULL,
    balance_after INTEGER NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_wallet_transactions_user_created ON wallet_transactions(user_id, created_at DESC);

-- ==========================================
-- 11. UNIFIED BLOCKS, REPORTS & ACTION LOCATIONS
-- ==========================================
CREATE TABLE user_blocks_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_user_id UUID REFERENCES app_users(id) ON DELETE CASCADE,
    target_user_id UUID REFERENCES app_users(id) ON DELETE CASCADE,
    reported_message_id UUID REFERENCES chat_messages(id) ON DELETE SET NULL,
    action_type TEXT NOT NULL CHECK (action_type IN ('block', 'report', 'restrict')),
    action_location TEXT NOT NULL CHECK (action_location IN (
        'chat', 'message_request', 'audio_call', 'video_call', 
        'random_audio_call', 'random_video_call', 'discovery', 
        'profile', 'online_date', 'offline_date'
    )),
    reason_category VARCHAR(64),
    description TEXT,
    status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'actioned', 'dismissed')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ==========================================
-- 12. MEETUP & DATE MEMORIES
-- ==========================================
CREATE TABLE meetup (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    match_id UUID REFERENCES matches(id) ON DELETE CASCADE,
    proposer_user_id UUID REFERENCES app_users(id) ON DELETE CASCADE,
    partner_user_id UUID REFERENCES app_users(id) ON DELETE CASCADE,
    date_mode TEXT NOT NULL CHECK (date_mode IN ('online', 'offline')),
    date_type VARCHAR(32) NOT NULL,
    scheduled_start_at TIMESTAMPTZ NOT NULL,
    scheduled_end_at TIMESTAMPTZ,
    date_started_at TIMESTAMPTZ,
    date_ended_at TIMESTAMPTZ,
    reminder_at TIMESTAMPTZ,
    status TEXT NOT NULL DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'completed', 'cancelled', 'missed', 'reported')),
    
    -- Custom Date Config & Notes
    split_bill_config JSONB DEFAULT '{}',
    dress_code VARCHAR(64),
    todo_list JSONB DEFAULT '[]',
    proposer_custom_notes TEXT,  
    partner_custom_notes TEXT,
    venue_name VARCHAR(128),
    osm_place_id VARCHAR(128),                    -- OpenStreetMap Node/Way/Relation ID reference
    latitude DOUBLE PRECISION,                    -- To drop the pin via MapLibre GL
    longitude DOUBLE PRECISION,                   -- To drop the pin via MapLibre GL

    -- Financial Tracking JSON (coins spent, free date usage)
    coins_json JSONB DEFAULT '{}',
    
    -- Multi-Category 5-Star Ratings & Feedback JSON
    proposer_ratings_json JSONB DEFAULT '{}',
    partner_ratings_json JSONB DEFAULT '{}',
    
    -- Post-Date Feedback & Ratings
    proposer_overall_rating SMALLINT CHECK (proposer_overall_rating BETWEEN 1 AND 5),
    partner_overall_rating SMALLINT CHECK (partner_overall_rating BETWEEN 1 AND 5),
    proposer_feedback TEXT,
    partner_feedback TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE date_memories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    date_id UUID REFERENCES meetup(id) ON DELETE CASCADE,
    uploaded_by_user_id UUID REFERENCES app_users(id) ON DELETE CASCADE,
    photo_uri TEXT NOT NULL,
    generated_sticker_uri TEXT,
    bitmoji_pack_json JSONB DEFAULT '[]',
    custom_gift_note TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ==========================================
-- 13. UNIFIED CATALOG PLANS (Coin Packs & Subscriptions)
-- ==========================================
CREATE TABLE plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    plan_type TEXT NOT NULL CHECK (plan_type IN ('coin_pack', 'subscription')),
    plan_code VARCHAR(32) UNIQUE NOT NULL,
    plan_title VARCHAR(64) NOT NULL,
    price_inr NUMERIC(10,2) NOT NULL,
    coin_amount INTEGER DEFAULT 0,
    duration_days INTEGER DEFAULT 0,
    features_json JSONB NOT NULL DEFAULT '{}',             -- Stores perks including free monthly dates count & connect view limits
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ==========================================
-- 14. PAYMENT ORDERS (External Gateway Logs)
-- ==========================================
CREATE TABLE payment_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES app_users(id) ON DELETE CASCADE,
    gateway_order_id VARCHAR(128) UNIQUE NOT NULL,
    plan_id UUID REFERENCES plans(id) ON DELETE RESTRICT,
    amount_fiat_type TEXT NOT NULL DEFAULT 'inr',
    amount NUMERIC(10,2) NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'success', 'failed')),
    failure_message TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ==========================================
-- 15. USER ACTIVE SUBSCRIPTIONS
-- ==========================================
CREATE TABLE user_subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES app_users(id) ON DELETE CASCADE,
    plan_id UUID REFERENCES plans(id) ON DELETE RESTRICT,
    payment_order_id UUID REFERENCES payment_orders(id) ON DELETE SET NULL,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'expired', 'cancelled', 'upcoming')),
    autopay BOOLEAN DEFAULT false,
    started_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ==========================================
-- 16 & 17. CREATOR PAYOUT KYC & REQUESTS
-- ==========================================
CREATE TABLE user_payout_kyc (
    user_id UUID PRIMARY KEY REFERENCES app_users(id) ON DELETE CASCADE,
    account_holder_name VARCHAR(128) NOT NULL,
    bank_account_number VARCHAR(32) NOT NULL,
    ifsc_code VARCHAR(11) NOT NULL,
    pan_number VARCHAR(30),
    is_bank_verified BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE payout_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES app_users(id) ON DELETE CASCADE,
    coins_converted INTEGER NOT NULL,
    payout_amount_fiat_type TEXT NOT NULL DEFAULT 'inr',
    payout_amount NUMERIC(10,2) NOT NULL,
    payout_status TEXT NOT NULL DEFAULT 'processing' CHECK (payout_status IN ('processing', 'credited', 'rejected')),
    gateway_payout_ref VARCHAR(128),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_payout_requests_user ON payout_requests(user_id, created_at DESC);

-- =====================================================================
-- TRIGGERS & CONSTRAINTS
-- =====================================================================

-- Trigger: Keep the derived location timestamps fresh.
-- NOTE: latitude/longitude were removed from user_profiles, so this trigger
-- no longer builds the geography value itself — the client (or
-- fn_set_user_location) writes `location` directly. The trigger now only
-- maintains the timestamps, and it still guards `updated_at` on every write.
CREATE OR REPLACE FUNCTION trg_sync_user_profile_geo()
RETURNS TRIGGER AS $$
BEGIN
    -- OLD is only available on UPDATE, so it must not be touched on INSERT.
    IF TG_OP = 'UPDATE' THEN
        IF NEW.location IS DISTINCT FROM OLD.location THEN
            NEW.location_updated_at := now();
        END IF;
    ELSE
        IF NEW.location IS NOT NULL THEN
            NEW.location_updated_at := now();
        END IF;
    END IF;

    NEW.updated_at := now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_user_profiles_geo_sync ON user_profiles;
CREATE TRIGGER trg_user_profiles_geo_sync
BEFORE INSERT OR UPDATE ON user_profiles
FOR EACH ROW
EXECUTE FUNCTION trg_sync_user_profile_geo();

-- Convenience helper: set a user's location from plain latitude/longitude.
-- The lat/lng columns no longer exist — `location` is the single source of
-- truth — but the app can still send raw coordinates and let the database do
-- the PostGIS conversion. Coordinates are validated here, which is where the
-- old CHECK constraint used to live.
CREATE OR REPLACE FUNCTION fn_set_user_location(
    p_user_id UUID,
    p_latitude DOUBLE PRECISION,
    p_longitude DOUBLE PRECISION
) RETURNS VOID AS $$
BEGIN
    IF p_latitude IS NULL OR p_longitude IS NULL THEN
        RAISE EXCEPTION 'INVALID_LOCATION: both latitude and longitude are required';
    END IF;

    IF p_latitude NOT BETWEEN -90 AND 90 OR p_longitude NOT BETWEEN -180 AND 180 THEN
        RAISE EXCEPTION 'INVALID_LOCATION: latitude must be in [-90, 90] and longitude in [-180, 180]';
    END IF;

    UPDATE user_profiles
    SET location = ST_SetSRID(ST_MakePoint(p_longitude, p_latitude), 4326)::geography,
        location_updated_at = now(),
        updated_at = now()
    WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================
-- SERVER-AUTHORITATIVE STORED PROCEDURES & FUNCTIONS
-- =====================================================================

-- Function 1: Execute Coin Transaction with Strict Ledger Locking
CREATE OR REPLACE FUNCTION fn_execute_coin_transaction(
    p_user_id UUID,
    p_direction TEXT,
    p_tx_type TEXT,
    p_coin_amount INTEGER
) RETURNS TABLE (new_balance INTEGER, tx_id UUID) AS $$
DECLARE
    v_current_balance INTEGER;
    v_new_balance INTEGER;
    v_tx_id UUID;
BEGIN
    -- Lock user wallet row for update
    SELECT coin_balance INTO v_current_balance
    FROM user_wallets
    WHERE user_id = p_user_id
    FOR UPDATE;

    IF NOT FOUND THEN
        INSERT INTO user_wallets (user_id, coin_balance, updated_at)
        VALUES (p_user_id, 0, now())
        RETURNING coin_balance INTO v_current_balance;
    END IF;

    IF p_direction = 'incoming' THEN
        v_new_balance := v_current_balance + p_coin_amount;
        UPDATE user_wallets
        SET coin_balance = v_new_balance,
            lifetime_earned_coins = lifetime_earned_coins + p_coin_amount,
            updated_at = now()
        WHERE user_id = p_user_id;
    ELSIF p_direction = 'outgoing' THEN
        IF v_current_balance < p_coin_amount THEN
            RAISE EXCEPTION 'INSUFFICIENT_COINS: Required % coins, currently have %', p_coin_amount, v_current_balance;
        END IF;
        v_new_balance := v_current_balance - p_coin_amount;
        UPDATE user_wallets
        SET coin_balance = v_new_balance,
            lifetime_spent_coins = lifetime_spent_coins + p_coin_amount,
            updated_at = now()
        WHERE user_id = p_user_id;
    ELSE
        RAISE EXCEPTION 'INVALID_DIRECTION: Direction must be incoming or outgoing';
    END IF;

    -- Append into ledger
    INSERT INTO wallet_transactions (id, user_id, direction, tx_type, coin_amount, balance_after, created_at)
    VALUES (gen_random_uuid(), p_user_id, p_direction, p_tx_type, p_coin_amount, v_new_balance, now())
    RETURNING id INTO v_tx_id;

    RETURN QUERY SELECT v_new_balance, v_tx_id;
END;
$$ LANGUAGE plpgsql;

-- Function 2: Swipe Execution & Reciprocal Match Detection
CREATE OR REPLACE FUNCTION fn_record_swipe(
    p_actor_user_id UUID,
    p_target_user_id UUID,
    p_action_type TEXT,
    p_is_message_request BOOLEAN DEFAULT FALSE,
    p_message_request_id UUID DEFAULT NULL
) RETURNS TABLE (is_match BOOLEAN, match_id UUID) AS $$
DECLARE
    v_reciprocal_action TEXT;
    v_match_id UUID := NULL;
    v_user_first UUID;
    v_user_second UUID;
BEGIN
    -- Upsert the swipe
    INSERT INTO swipes_interactions (
        actor_user_id, target_user_id, action_type,
        is_message_request, message_request_id, is_reverted, created_at
    )
    VALUES (
        p_actor_user_id, p_target_user_id, p_action_type,
        p_is_message_request, p_message_request_id, FALSE, now()
    )
    ON CONFLICT (actor_user_id, target_user_id) DO UPDATE
    SET action_type = EXCLUDED.action_type,
        is_message_request = EXCLUDED.is_message_request,
        message_request_id = EXCLUDED.message_request_id,
        is_reverted = FALSE,
        created_at = now();

    -- Check reciprocal swipe if like or spark
    IF p_action_type IN ('like', 'spark') THEN
        SELECT s.action_type INTO v_reciprocal_action
        FROM swipes_interactions s
        WHERE s.actor_user_id = p_target_user_id
          AND s.target_user_id = p_actor_user_id
          AND s.action_type IN ('like', 'spark')
          AND s.is_reverted = FALSE
        ORDER BY s.created_at DESC
        LIMIT 1;

        IF FOUND THEN
            -- Canonical ordering for unique user_a_id, user_b_id constraint
            IF p_actor_user_id < p_target_user_id THEN
                v_user_first := p_actor_user_id;
                v_user_second := p_target_user_id;
            ELSE
                v_user_first := p_target_user_id;
                v_user_second := p_actor_user_id;
            END IF;

            INSERT INTO matches (id, user_a_id, user_b_id, status, matched_at)
            VALUES (gen_random_uuid(), v_user_first, v_user_second, 'active', now())
            ON CONFLICT (user_a_id, user_b_id) DO UPDATE SET status = 'active'
            RETURNING id INTO v_match_id;

            -- Auto-create chat room for mutual match
            INSERT INTO chat_rooms (id, match_id, request_sender_id, request_receiver_id, request_status, created_at)
            VALUES (gen_random_uuid(), v_match_id, p_actor_user_id, p_target_user_id, 'accepted', now())
            ON CONFLICT (match_id) DO NOTHING;

            RETURN QUERY SELECT TRUE, v_match_id;
            RETURN;
        END IF;
    END IF;

    RETURN QUERY SELECT FALSE, NULL::UUID;
END;
$$ LANGUAGE plpgsql;

-- Function 3: PostGIS ST_DWithin Nearby Candidate Deck
CREATE OR REPLACE FUNCTION fn_get_nearby_candidates(
    p_user_id UUID,
    p_max_distance_meters DOUBLE PRECISION DEFAULT 50000, -- 50km
    p_limit INTEGER DEFAULT 10
) RETURNS TABLE (
    user_id UUID,
    nickname VARCHAR(40),
    bio VARCHAR(500),
    city VARCHAR(120),
    distance_km DOUBLE PRECISION,
    is_verified BOOLEAN,
    profile_progress SMALLINT
) AS $$
DECLARE
    v_user_geo GEOGRAPHY(Point, 4326);
BEGIN
    SELECT location INTO v_user_geo FROM user_profiles WHERE user_profiles.user_id = p_user_id;

    RETURN QUERY
    SELECT
        u.id AS user_id,
        p.nickname,
        p.bio,
        p.city,
        ST_Distance(p.location, v_user_geo) / 1000.0 AS distance_km,
        p.is_verified,
        p.profile_progress
    FROM app_users u
    JOIN user_profiles p ON u.id = p.user_id
    WHERE u.id != p_user_id
      AND u.account_status = 'active'
      AND (v_user_geo IS NULL OR ST_DWithin(p.location, v_user_geo, p_max_distance_meters))
      AND NOT EXISTS (
          SELECT 1 FROM swipes_interactions s
          WHERE s.actor_user_id = p_user_id
            AND s.target_user_id = u.id
            AND s.is_reverted = FALSE
      )
      AND NOT EXISTS (
          SELECT 1 FROM user_blocks_reports b
          WHERE (b.actor_user_id = p_user_id AND b.target_user_id = u.id)
             OR (b.actor_user_id = u.id AND b.target_user_id = p_user_id)
      )
    ORDER BY distance_km ASC NULLS LAST
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================
-- ROW LEVEL SECURITY (RLS) FOR SUPABASE
-- =====================================================================
DO $$
DECLARE
    t TEXT;
BEGIN
    FOREACH t IN ARRAY ARRAY[
        'app_users', 'user_profiles', 'user_photos', 'prompts_master',
        'user_prompt_answers', 'swipes_interactions', 'user_quotas', 'matches',
        'gifts', 'user_gifts', 'chat_rooms', 'chat_participant_settings',
        'chat_messages', 'call_sessions', 'user_wallets', 'wallet_transactions',
        'user_blocks_reports', 'meetup', 'date_memories', 'plans',
        'payment_orders', 'user_subscriptions', 'user_payout_kyc', 'payout_requests'
    ]
    LOOP
        EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', t);
    END LOOP;
END $$;

-- Revoke raw client access and grant service_role permissions
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'anon') THEN
        REVOKE ALL ON ALL TABLES IN SCHEMA public FROM anon;
        REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM anon;
        EXECUTE 'ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON TABLES FROM anon';
        EXECUTE 'ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON SEQUENCES FROM anon';
    END IF;

    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'authenticated') THEN
        REVOKE ALL ON ALL TABLES IN SCHEMA public FROM authenticated;
        REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM authenticated;
        EXECUTE 'ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON TABLES FROM authenticated';
        EXECUTE 'ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON SEQUENCES FROM authenticated';
    END IF;

    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'service_role') THEN
        GRANT ALL ON ALL TABLES IN SCHEMA public TO service_role;
        GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO service_role;
        EXECUTE 'ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO service_role';
        EXECUTE 'ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO service_role';
    END IF;
END $$;
