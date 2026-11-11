-- =====================================================================
-- YoUnMe Dating App — Initial Seed Data
-- Database: Supabase Managed PostgreSQL + PostGIS
-- Region: Mumbai, India (asia-south1)
-- =====================================================================

-- 1. SEED APP_USERS
-- User 1: Current Demo User (Arjun Mehta - Male, Tech Founder)
INSERT INTO app_users (id, authentication_uid, email, phone_country_code, phone_number, phone_verified, email_verified, google_sso_id, account_status, role)
VALUES 
('11111111-1111-1111-1111-111111111111', 'auth_arjun_111111', 'arjun.mehta@younme.social', '+91', '9820011111', TRUE, TRUE, 'google_111111', 'active', 'user')
ON CONFLICT (id) DO NOTHING;

-- User 2: Ananya Sharma (Female, Creative Designer in Bandra)
INSERT INTO app_users (id, authentication_uid, email, phone_country_code, phone_number, phone_verified, email_verified, google_sso_id, account_status, role)
VALUES 
('22222222-2222-2222-2222-222222222222', 'auth_ananya_222222', 'ananya.sharma@younme.social', '+91', '9820022222', TRUE, TRUE, 'google_222222', 'active', 'user')
ON CONFLICT (id) DO NOTHING;

-- User 3: Rohit Verma (Male, Fitness & Architect in Juhu)
INSERT INTO app_users (id, authentication_uid, email, phone_country_code, phone_number, phone_verified, email_verified, google_sso_id, account_status, role)
VALUES 
('33333333-3333-3333-3333-333333333333', 'auth_rohit_333333', 'rohit.verma@younme.social', '+91', '9820033333', TRUE, TRUE, 'google_333333', 'active', 'user')
ON CONFLICT (id) DO NOTHING;

-- User 4: Riya Sen (Female, Art Curator in Colaba)
INSERT INTO app_users (id, authentication_uid, email, phone_country_code, phone_number, phone_verified, email_verified, google_sso_id, account_status, role)
VALUES 
('44444444-4444-4444-4444-444444444444', 'auth_riya_444444', 'riya.sen@younme.social', '+91', '9820044444', TRUE, TRUE, 'google_444444', 'active', 'user')
ON CONFLICT (id) DO NOTHING;

-- User 5: Tanya Kapoor (Female, Creator / Musician in Powai)
INSERT INTO app_users (id, authentication_uid, email, phone_country_code, phone_number, phone_verified, email_verified, google_sso_id, account_status, role)
VALUES 
('55555555-5555-5555-5555-555555555555', 'auth_tanya_555555', 'tanya.kapoor@younme.social', '+91', '9820055555', TRUE, TRUE, 'google_555555', 'active', 'user')
ON CONFLICT (id) DO NOTHING;

-- 2. SEED USER_PROFILES (With Mumbai Coordinates & Trigger-Generated PostGIS Geography)
-- Arjun: Bandra West (19.0596° N, 72.8295° E)
INSERT INTO user_profiles (user_id, first_name, nickname, date_of_birth, gender, bio, city, languages, location, profile_progress, is_verified, liveness_verified)
VALUES 
('11111111-1111-1111-1111-111111111111', 'Arjun', 'Arjun', '1998-05-14', 'male', 'Building next-gen AI tech. Coffee addict, indie vinyl records & sunset runs across Bandra Bandstand ☕⚡', 'Mumbai', ARRAY['English', 'Hindi', 'Marathi'], ST_SetSRID(ST_MakePoint(72.8295, 19.0596), 4326)::geography, 92, TRUE, TRUE)
ON CONFLICT (user_id) DO NOTHING;

-- Ananya: Bandra Pali Hill (19.0650° N, 72.8280° E) ~ 0.8 km from Arjun
INSERT INTO user_profiles (user_id, first_name, nickname, date_of_birth, gender, bio, city, languages, location, profile_progress, is_verified, liveness_verified)
VALUES 
('22222222-2222-2222-2222-222222222222', 'Ananya', 'Ananya', '2000-08-22', 'female', 'UI designer & matcha lover 🍵 Seeking someone who laughs at witty dry humor. Let’s explore quaint cafes or museum galleries!', 'Mumbai', ARRAY['English', 'Hindi'], ST_SetSRID(ST_MakePoint(72.8280, 19.0650), 4326)::geography, 95, TRUE, TRUE)
ON CONFLICT (user_id) DO NOTHING;

-- Rohit: Juhu Beach (19.1075° N, 72.8263° E) ~ 5.3 km from Arjun
INSERT INTO user_profiles (user_id, first_name, nickname, date_of_birth, gender, bio, city, languages, location, profile_progress, is_verified, liveness_verified)
VALUES 
('33333333-3333-3333-3333-333333333333', 'Rohit', 'Rohit', '1997-12-05', 'male', 'Architecting spaces by day, chasing sunsets by evening. Fitness, rock climbing, and deep late-night conversations 🌇🧗‍♂️', 'Mumbai', ARRAY['English', 'Hindi', 'Punjabi'], ST_SetSRID(ST_MakePoint(72.8263, 19.1075), 4326)::geography, 88, TRUE, TRUE)
ON CONFLICT (user_id) DO NOTHING;

-- Riya: Colaba Causeway (18.9220° N, 72.8347° E) ~ 15.2 km from Arjun
INSERT INTO user_profiles (user_id, first_name, nickname, date_of_birth, gender, bio, city, languages, location, profile_progress, is_verified, liveness_verified)
VALUES 
('44444444-4444-4444-4444-444444444444', 'Riya', 'Riya', '2001-03-18', 'female', 'Curating art exhibitions, vintage bookstores, and jazz nights. Swipe right if you have an eclectic Spotify playlist 🎨🎷', 'Mumbai', ARRAY['English', 'Bengali', 'Hindi'], ST_SetSRID(ST_MakePoint(72.8347, 18.9220), 4326)::geography, 85, TRUE, TRUE)
ON CONFLICT (user_id) DO NOTHING;

-- Tanya: Powai Hiranandani (19.1197° N, 72.9051° E) ~ 10.5 km from Arjun
INSERT INTO user_profiles (user_id, first_name, nickname, date_of_birth, gender, bio, city, languages, location, profile_progress, is_verified, liveness_verified)
VALUES 
('55555555-5555-5555-5555-555555555555', 'Tanya', 'Tanya', '1999-11-09', 'female', 'Singer-songwriter & verified creator. Live acoustic jams, travel vlogs, and spicy food quests 🎤🎸', 'Mumbai', ARRAY['English', 'Hindi'], ST_SetSRID(ST_MakePoint(72.9051, 19.1197), 4326)::geography, 90, TRUE, TRUE)
ON CONFLICT (user_id) DO NOTHING;

-- 3. SEED USER PHOTOS
INSERT INTO user_photos (user_id, photo_uri, display_order, is_primary, is_face_verified, caption)
VALUES
('11111111-1111-1111-1111-111111111111', '/aditya.jpg', 1, TRUE, TRUE, 'Bandra sunset run'),
('22222222-2222-2222-2222-222222222222', '/ananya.jpg', 1, TRUE, TRUE, 'Matcha latte mornings');

-- 4. SEED USER WALLETS & LEDGER
-- Arjun (User 1): 250 coins
INSERT INTO user_wallets (user_id, coin_balance, updated_at)
VALUES ('11111111-1111-1111-1111-111111111111', 250, now())
ON CONFLICT (user_id) DO NOTHING;

INSERT INTO wallet_transactions (id, user_id, direction, tx_type, coin_amount, balance_after, created_at)
VALUES 
('f1111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', 'incoming', 'rewards', 250, 250, now())
ON CONFLICT (id) DO NOTHING;

-- Ananya (User 2, Creator): 620 coins
INSERT INTO user_wallets (user_id, coin_balance, updated_at)
VALUES ('22222222-2222-2222-2222-222222222222', 620, now())
ON CONFLICT (user_id) DO NOTHING;

INSERT INTO wallet_transactions (id, user_id, direction, tx_type, coin_amount, balance_after, created_at)
VALUES 
('f2222222-2222-2222-2222-222222222222', '22222222-2222-2222-2222-222222222222', 'incoming', 'rewards', 620, 620, now())
ON CONFLICT (id) DO NOTHING;

-- 5. SEED MUTUAL MATCH & CHAT ROOM BETWEEN ARJUN & ANANYA
INSERT INTO matches (id, user_a_id, user_b_id, matched_at, status)
VALUES 
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', now() - INTERVAL '1 day', 'active')
ON CONFLICT (user_a_id, user_b_id) DO NOTHING;

INSERT INTO chat_rooms (id, match_id, request_sender_id, request_receiver_id, request_status, last_message_at, created_at)
VALUES
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', 'accepted', now() - INTERVAL '10 hours', now() - INTERVAL '1 day')
ON CONFLICT (match_id) DO NOTHING;

INSERT INTO chat_messages (id, room_id, sender_id, message_type, raw_content, status, created_at)
VALUES 
('c1111111-1111-1111-1111-111111111111', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '22222222-2222-2222-2222-222222222222', 'text', 'Hey Arjun! Saw you love filter kaapi and vinyl records. Have you tried Subko in Bandra?', 'read', now() - INTERVAL '12 hours'),
('c2222222-2222-2222-2222-222222222222', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '11111111-1111-1111-1111-111111111111', 'text', 'Subko is practically my second office! Their sourdough croissants and pour-over are unbeatable.', 'read', now() - INTERVAL '11 hours'),
('c3333333-3333-3333-3333-333333333333', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '22222222-2222-2222-2222-222222222222', 'text', 'Haha great taste! What indie bands are currently playing on your turntable?', 'delivered', now() - INTERVAL '10 hours')
ON CONFLICT (id) DO NOTHING;
