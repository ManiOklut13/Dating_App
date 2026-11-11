-- =====================================================================
-- YoUnMe — Worker Supabase Migration
-- Run this migration on your Supabase project to add the tables
-- required by the background worker.
--
-- Apply via: Supabase Dashboard → SQL Editor → Run
-- Or: supabase db push (if using supabase CLI)
-- =====================================================================

-- ─────────────────────────────────────────────────────────────────────
-- TABLE: media_moderation
-- Written by: worker-bullmq vision processor (idempotent upsert)
-- Read by:    NestJS API (serves media status to Flutter)
-- ─────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS media_moderation (
    asset_id          UUID PRIMARY KEY,
    user_id           UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status            VARCHAR(20) NOT NULL
                          CHECK (status IN ('approved', 'blocked', 'pending_review')),
    safe_search_adult VARCHAR(20) NOT NULL DEFAULT 'UNKNOWN',
    safe_search_racy  VARCHAR(20) NOT NULL DEFAULT 'UNKNOWN',
    safe_search_violence VARCHAR(20) NOT NULL DEFAULT 'UNKNOWN',
    contact_detected  BOOLEAN NOT NULL DEFAULT FALSE,
    action_taken      VARCHAR(64) NOT NULL,
    reviewed_at       TIMESTAMPTZ NOT NULL,
    created_at        TIMESTAMPTZ DEFAULT NOW(),
    updated_at        TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_media_moderation_user
    ON media_moderation(user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_media_moderation_status
    ON media_moderation(status);

-- RLS: Admins and the service role can read all rows.
-- Users cannot read other users' moderation records.
ALTER TABLE media_moderation ENABLE ROW LEVEL SECURITY;

CREATE POLICY "service_role_all_media_moderation"
    ON media_moderation
    FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

CREATE POLICY "user_read_own_media_moderation"
    ON media_moderation
    FOR SELECT
    TO authenticated
    USING (user_id = auth.uid());

-- ─────────────────────────────────────────────────────────────────────
-- TABLE: contact_guard_audits
-- Written by: worker-bullmq contact-guard processor
-- Idempotency: UNIQUE constraint on idempotency_key
-- ─────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS contact_guard_audits (
    id                BIGSERIAL PRIMARY KEY,
    user_id           UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    conversation_id   UUID NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    detected_type     VARCHAR(32) NOT NULL
                          CHECK (detected_type IN ('phone_number', 'social_handle', 'external_url')),
    -- Normalised excerpt only — must NOT contain raw phone numbers or personal data.
    normalised_excerpt VARCHAR(200) NOT NULL DEFAULT '',
    idempotency_key   TEXT UNIQUE NOT NULL,
    created_at        TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_contact_guard_audits_user
    ON contact_guard_audits(user_id, created_at DESC);

CREATE UNIQUE INDEX IF NOT EXISTS idx_contact_guard_audits_idempotency
    ON contact_guard_audits(idempotency_key);

ALTER TABLE contact_guard_audits ENABLE ROW LEVEL SECURITY;

-- Only the service role can write audit records.
-- Authenticated users can view their own audit trail for transparency.
CREATE POLICY "service_role_all_contact_guard_audits"
    ON contact_guard_audits
    FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

CREATE POLICY "user_read_own_contact_guard_audits"
    ON contact_guard_audits
    FOR SELECT
    TO authenticated
    USING (user_id = auth.uid());

-- ─────────────────────────────────────────────────────────────────────
-- TABLE: notifications
-- Written by: worker-bullmq notification processor
-- Read by:    Flutter via Supabase Realtime (INSERT events)
-- ─────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS notifications (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    recipient_id  UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category      VARCHAR(20) NOT NULL
                      CHECK (category IN ('match', 'message', 'call', 'system')),
    title         VARCHAR(128) NOT NULL,
    body          VARCHAR(512) NOT NULL,
    data          JSONB DEFAULT '{}'::JSONB,
    is_read       BOOLEAN NOT NULL DEFAULT FALSE,
    created_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notifications_recipient
    ON notifications(recipient_id, is_read, created_at DESC);

ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Service role writes; authenticated users read their own notifications.
CREATE POLICY "service_role_all_notifications"
    ON notifications
    FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

CREATE POLICY "user_read_own_notifications"
    ON notifications
    FOR SELECT
    TO authenticated
    USING (recipient_id = auth.uid());

-- Allow users to mark their own notifications as read
CREATE POLICY "user_update_own_notifications"
    ON notifications
    FOR UPDATE
    TO authenticated
    USING (recipient_id = auth.uid())
    WITH CHECK (recipient_id = auth.uid());

-- Enable Realtime broadcasts for the notifications table
-- (Supabase Dashboard → Database → Replication → enable for 'notifications')
-- This makes Supabase broadcast INSERT events to subscribed Flutter clients.
COMMENT ON TABLE notifications IS
    'In-app notification records. Supabase Realtime must be enabled on this table for Flutter push delivery.';

-- ─────────────────────────────────────────────────────────────────────
-- TABLE: device_tokens
-- Used by: worker-bullmq push-delivery processor to look up active FCM tokens
-- Written by: Flutter mobile client via authenticated Supabase / NestJS
-- ─────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS device_tokens (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id       UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token         TEXT NOT NULL,
    platform      VARCHAR(20) NOT NULL
                      CHECK (platform IN ('android', 'ios', 'web')),
    device_id     VARCHAR(128),
    created_at    TIMESTAMPTZ DEFAULT NOW(),
    updated_at    TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT unique_user_device_token UNIQUE (user_id, token)
);

CREATE INDEX IF NOT EXISTS idx_device_tokens_user
    ON device_tokens(user_id, updated_at DESC);

CREATE INDEX IF NOT EXISTS idx_device_tokens_token
    ON device_tokens(token);

ALTER TABLE device_tokens ENABLE ROW LEVEL SECURITY;

-- Service role has full access (for worker to query and prune invalid tokens)
CREATE POLICY "service_role_all_device_tokens"
    ON device_tokens
    FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

-- Authenticated users manage their own device tokens
CREATE POLICY "user_manage_own_device_tokens"
    ON device_tokens
    FOR ALL
    TO authenticated
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());
