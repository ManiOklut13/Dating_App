-- =====================================================================
-- YoUnMe — Migration 0002: drop user_profiles.latitude/longitude,
--          add flag / snooze / contact-share columns.
-- =====================================================================
-- WHY THIS FILE EXISTS
-- database/schema.sql starts with `DROP TABLE IF EXISTS ... CASCADE` — it is
-- a full teardown-and-rebuild script and it WILL destroy existing data.
-- This migration is the incremental, non-destructive delta for a database
-- that already has the v3.2 schema. Apply THIS one to a live project.
--
-- Safe to run more than once (every statement is IF EXISTS / IF NOT EXISTS).
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Drop the redundant latitude/longitude columns from user_profiles
--    `location` (GEOGRAPHY POINT, 4326) is now the single source of truth.
--    The CHECK constraint on those columns is dropped automatically with them.
-- ---------------------------------------------------------------------
ALTER TABLE user_profiles DROP COLUMN IF EXISTS latitude;
ALTER TABLE user_profiles DROP COLUMN IF EXISTS longitude;

-- ---------------------------------------------------------------------
-- 2. Rewrite the geo trigger.
--    The old body read NEW.latitude / NEW.longitude, so once those columns
--    were gone it would raise
--      ERROR: record "new" has no field "latitude"
--    on every INSERT/UPDATE of user_profiles. The trigger is kept, but it
--    now only maintains the derived timestamps.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION trg_sync_user_profile_geo()
RETURNS TRIGGER AS $$
BEGIN
    -- OLD is only populated on UPDATE, so it must not be read on INSERT.
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

-- ---------------------------------------------------------------------
-- 3. Convenience helper: the app can still send raw coordinates and let
--    the database do the PostGIS conversion + validation (this is where
--    the old CHECK constraint used to enforce the bounds).
-- ---------------------------------------------------------------------
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

-- ---------------------------------------------------------------------
-- 4. New columns
-- ---------------------------------------------------------------------

-- Contact & Link Guard flag on a message (phone numbers, WhatsApp,
-- Telegram, Instagram handles, external URLs).
ALTER TABLE chat_messages
    ADD COLUMN IF NOT EXISTS is_flagged BOOLEAN NOT NULL DEFAULT false;

-- When a 'snooze' swipe becomes eligible again.
ALTER TABLE swipes_interactions
    ADD COLUMN IF NOT EXISTS snoozed_until TIMESTAMPTZ;

-- Contact & Link Guard unlock for a conversation: after 3 days of active
-- matching OR 20 message pairs exchanged.
ALTER TABLE chat_rooms
    ADD COLUMN IF NOT EXISTS contact_share_unlocked BOOLEAN NOT NULL DEFAULT false;

-- ---------------------------------------------------------------------
-- 5. Confirm the result
-- ---------------------------------------------------------------------
SELECT 'chat_messages.is_flagged' AS column, count(*)::text AS value
FROM chat_messages WHERE is_flagged
UNION ALL
SELECT 'chat_rooms.contact_share_unlocked', count(*)::text
FROM chat_rooms WHERE contact_share_unlocked
UNION ALL
SELECT 'swipes_interactions.snoozed_until', count(*)::text
FROM swipes_interactions WHERE snoozed_until IS NOT NULL
UNION ALL
SELECT 'user_profiles.latitude (should be 0)', count(*)::text
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'user_profiles' AND column_name = 'latitude'
UNION ALL
SELECT 'user_profiles.longitude (should be 0)', count(*)::text
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'user_profiles' AND column_name = 'longitude';
