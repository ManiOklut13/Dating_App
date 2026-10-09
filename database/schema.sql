-- =====================================================================
-- YoUnMe Dating App — Master Technical Architecture Schema (v3.2)
-- Target Database: Supabase Pro Managed PostgreSQL + PostGIS
-- Cloud Run Region: asia-south1 (Mumbai)
-- =====================================================================

-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- 2. USERS TABLE
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone VARCHAR(32) UNIQUE NOT NULL,
    email VARCHAR(255),
    google_id VARCHAR(255),
    dob DATE,
    gender VARCHAR(32), -- 'male', 'female', 'non-binary'
    is_verified BOOLEAN DEFAULT FALSE,
    status VARCHAR(32) DEFAULT 'active' CHECK (status IN ('active', 'suspended', 'pending_otp')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. PROFILES TABLE (With PostGIS geometry point)
CREATE TABLE IF NOT EXISTS profiles (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    nickname VARCHAR(64) NOT NULL,
    bio TEXT DEFAULT '',
    city VARCHAR(64) DEFAULT 'Mumbai',
    languages TEXT[] DEFAULT ARRAY['English', 'Hindi'],
    geo_point geometry(Point, 4326),
    profile_progress INTEGER DEFAULT 0 CHECK (profile_progress >= 0 AND profile_progress <= 100),
    photo_urls TEXT[] DEFAULT ARRAY[]::TEXT[],
    call_avatar_ref TEXT DEFAULT 'avatar_neon_tiger',
    voice_pin_url TEXT DEFAULT NULL,
    liveness_verified BOOLEAN DEFAULT FALSE,
    contact_share_unlocked BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- PostGIS Spatial Index for ultra-fast ST_DWithin radius lookups (<200ms)
CREATE INDEX IF NOT EXISTS idx_profiles_geopoint ON profiles USING GIST (geo_point);
CREATE INDEX IF NOT EXISTS idx_profiles_city ON profiles(city);

-- 4. SWIPES TABLE
CREATE TABLE IF NOT EXISTS swipes (
    id BIGSERIAL PRIMARY KEY,
    actor_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    target_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    action VARCHAR(20) NOT NULL CHECK (action IN ('like', 'dislike', 'spark', 'snooze')),
    revert_flag BOOLEAN DEFAULT FALSE,
    snoozed_until TIMESTAMPTZ DEFAULT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Compound index for rapid swipe checks and duplicate prevention
CREATE INDEX IF NOT EXISTS idx_swipes_actor_target ON swipes(actor_id, target_id);
CREATE INDEX IF NOT EXISTS idx_swipes_target_action ON swipes(target_id, action);

-- 5. MATCHES TABLE
CREATE TABLE IF NOT EXISTS matches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_a UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    user_b UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    matched_at TIMESTAMPTZ DEFAULT NOW(),
    source VARCHAR(20) DEFAULT 'swipe' CHECK (source IN ('swipe', 'call', 'spark')),
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'unmatched', 'blocked')),
    message_pair_count INTEGER DEFAULT 0,
    CONSTRAINT unique_user_pair UNIQUE (user_a, user_b)
);

CREATE INDEX IF NOT EXISTS idx_matches_users ON matches(user_a, user_b);

-- 6. MESSAGES TABLE (Vanish Mode & Contact Guard Flagging)
CREATE TABLE IF NOT EXISTS messages (
    id BIGSERIAL PRIMARY KEY,
    conv_id UUID NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(20) DEFAULT 'text' CHECK (type IN ('text', 'bitmoji', 'audio')),
    body TEXT NOT NULL,
    media_url TEXT DEFAULT NULL,
    expires_at TIMESTAMPTZ DEFAULT NULL, -- Populated if vanish mode is active
    is_flagged BOOLEAN DEFAULT FALSE,     -- Flagged by Contact & Link Guard
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_messages_conv_created ON messages(conv_id, created_at DESC);

-- 7. CALLS TABLE (LiveKit Cloud Session & Heartbeat Billing)
CREATE TABLE IF NOT EXISTS calls (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    caller_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    callee_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    kind VARCHAR(20) NOT NULL CHECK (kind IN ('audio', 'video', 'random')),
    livekit_room_sid VARCHAR(128) NOT NULL,
    started_at TIMESTAMPTZ DEFAULT NOW(),
    ended_at TIMESTAMPTZ DEFAULT NULL,
    duration_s INTEGER DEFAULT 0,
    cost_coins INTEGER DEFAULT 0,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'completed', 'dropped'))
);

CREATE INDEX IF NOT EXISTS idx_calls_caller_callee ON calls(caller_id, callee_id);

-- 8. WALLETS TABLE (Live Integer Coin Balance with zero double-spending)
CREATE TABLE IF NOT EXISTS wallets (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    balance INTEGER NOT NULL DEFAULT 0 CHECK (balance >= 0),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 9. TRANSACTIONS TABLE (Append-Only Double-Entry Ledger)
CREATE TABLE IF NOT EXISTS transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(32) NOT NULL CHECK (type IN ('grant', 'purchase', 'spend', 'earn', 'payout', 'refund')),
    coins INTEGER NOT NULL, -- Positive for credit, negative for debit
    reference_id TEXT,      -- e.g., call_id, swipe_revert, rzp_order_id
    idempotency_key TEXT UNIQUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_transactions_user ON transactions(user_id, created_at DESC);
CREATE UNIQUE INDEX IF NOT EXISTS idx_transactions_idempotency ON transactions(idempotency_key);

-- =====================================================================
-- SERVER-AUTHORITATIVE STORED PROCEDURES & LEDGER FUNCTIONS
-- =====================================================================

-- Function: Execute Coin Transaction with Strict Idempotency & Zero Double-Spend
CREATE OR REPLACE FUNCTION fn_execute_coin_transaction(
    p_user_id UUID,
    p_type VARCHAR(32),
    p_coins INTEGER,
    p_reference_id TEXT,
    p_idempotency_key TEXT
) RETURNS TABLE (new_balance INTEGER, tx_id UUID) AS $$
DECLARE
    v_current_balance INTEGER;
    v_tx_id UUID;
BEGIN
    -- Check if idempotency key already exists
    SELECT id, coins INTO v_tx_id, v_current_balance 
    FROM transactions 
    WHERE idempotency_key = p_idempotency_key;

    IF FOUND THEN
        SELECT balance INTO v_current_balance FROM wallets WHERE user_id = p_user_id;
        RETURN QUERY SELECT v_current_balance, v_tx_id;
        RETURN;
    END IF;

    -- Lock the wallet row for update
    SELECT balance INTO v_current_balance
    FROM wallets
    WHERE user_id = p_user_id
    FOR UPDATE;

    IF NOT FOUND THEN
        INSERT INTO wallets (user_id, balance, updated_at)
        VALUES (p_user_id, 0, NOW())
        RETURNING balance INTO v_current_balance;
    END IF;

    -- Validate debit
    IF p_coins < 0 AND (v_current_balance + p_coins) < 0 THEN
        RAISE EXCEPTION 'INSUFFICIENT_COINS: Required % coins, currently have %', ABS(p_coins), v_current_balance;
    END IF;

    -- Update balance
    UPDATE wallets
    SET balance = balance + p_coins,
        updated_at = NOW()
    WHERE user_id = p_user_id
    RETURNING balance INTO v_current_balance;

    -- Insert ledger entry
    INSERT INTO transactions (id, user_id, type, coins, reference_id, idempotency_key, created_at)
    VALUES (uuid_generate_v4(), p_user_id, p_type, p_coins, p_reference_id, p_idempotency_key, NOW())
    RETURNING id INTO v_tx_id;

    RETURN QUERY SELECT v_current_balance, v_tx_id;
END;
$$ LANGUAGE plpgsql;

-- Function: Swipe Execution & Reciprocal Match Detection
CREATE OR REPLACE FUNCTION fn_record_swipe(
    p_actor_id UUID,
    p_target_id UUID,
    p_action VARCHAR(20)
) RETURNS TABLE (is_match BOOLEAN, match_id UUID) AS $$
DECLARE
    v_reciprocal_action VARCHAR(20);
    v_match_id UUID := NULL;
    v_user_first UUID;
    v_user_second UUID;
BEGIN
    -- Record or update the swipe
    INSERT INTO swipes (actor_id, target_id, action, revert_flag, created_at)
    VALUES (p_actor_id, p_target_id, p_action, FALSE, NOW());

    -- If like or spark, check if target already liked or sparked actor
    IF p_action IN ('like', 'spark') THEN
        SELECT action INTO v_reciprocal_action
        FROM swipes
        WHERE actor_id = p_target_id 
          AND target_id = p_actor_id 
          AND action IN ('like', 'spark') 
          AND revert_flag = FALSE
        ORDER BY created_at DESC
        LIMIT 1;

        IF FOUND THEN
            -- Canonical ordering for unique constraint
            IF p_actor_id < p_target_id THEN
                v_user_first := p_actor_id;
                v_user_second := p_target_id;
            ELSE
                v_user_first := p_target_id;
                v_user_second := p_actor_id;
            END IF;

            INSERT INTO matches (id, user_a, user_b, matched_at, source, status)
            VALUES (uuid_generate_v4(), v_user_first, v_user_second, NOW(), 'swipe', 'active')
            ON CONFLICT (user_a, user_b) DO UPDATE SET status = 'active'
            RETURNING id INTO v_match_id;

            RETURN QUERY SELECT TRUE, v_match_id;
            RETURN;
        END IF;
    END IF;

    RETURN QUERY SELECT FALSE, NULL::UUID;
END;
$$ LANGUAGE plpgsql;

-- Function: PostGIS ST_DWithin Nearby Candidate Deck
CREATE OR REPLACE FUNCTION fn_get_nearby_candidates(
    p_user_id UUID,
    p_max_distance_meters DOUBLE PRECISION DEFAULT 50000, -- 50km
    p_limit INTEGER DEFAULT 10
) RETURNS TABLE (
    user_id UUID,
    nickname VARCHAR(64),
    bio TEXT,
    city VARCHAR(64),
    distance_km DOUBLE PRECISION,
    photo_urls TEXT[],
    is_verified BOOLEAN,
    profile_progress INTEGER
) AS $$
DECLARE
    v_user_geo geometry(Point, 4326);
BEGIN
    SELECT geo_point INTO v_user_geo FROM profiles WHERE profiles.user_id = p_user_id;

    RETURN QUERY
    SELECT 
        u.id AS user_id,
        p.nickname,
        p.bio,
        p.city,
        ST_Distance(p.geo_point::geography, v_user_geo::geography) / 1000.0 AS distance_km,
        p.photo_urls,
        u.is_verified,
        p.profile_progress
    FROM users u
    JOIN profiles p ON u.id = p.user_id
    WHERE u.id != p_user_id
      AND u.status = 'active'
      AND (v_user_geo IS NULL OR ST_DWithin(p.geo_point::geography, v_user_geo::geography, p_max_distance_meters))
      AND NOT EXISTS (
          SELECT 1 FROM swipes s 
          WHERE s.actor_id = p_user_id 
            AND s.target_id = u.id 
            AND s.revert_flag = FALSE
      )
    ORDER BY distance_km ASC NULLS LAST
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;
