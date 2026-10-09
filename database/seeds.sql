-- =====================================================================
-- YoUnMe Dating App — Initial Seed Data
-- Region: Mumbai, India (asia-south1)
-- =====================================================================

-- 1. SEED USERS
-- User 1: Current Demo User (Arjun Mehta - Male, Tech Founder)
INSERT INTO users (id, phone, email, google_id, dob, gender, is_verified, status)
VALUES 
('11111111-1111-1111-1111-111111111111', '+919820011111', 'arjun.mehta@younme.social', 'google_111111', '1998-05-14', 'male', TRUE, 'active')
ON CONFLICT (id) DO NOTHING;

-- User 2: Ananya Sharma (Female, Creative Designer in Bandra)
INSERT INTO users (id, phone, email, google_id, dob, gender, is_verified, status)
VALUES 
('22222222-2222-2222-2222-222222222222', '+919820022222', 'ananya.sharma@younme.social', 'google_222222', '2000-08-22', 'female', TRUE, 'active')
ON CONFLICT (id) DO NOTHING;

-- User 3: Rohit Verma (Male, Fitness & Architect in Juhu)
INSERT INTO users (id, phone, email, google_id, dob, gender, is_verified, status)
VALUES 
('33333333-3333-3333-3333-333333333333', '+919820033333', 'rohit.verma@younme.social', 'google_333333', '1997-12-05', 'male', TRUE, 'active')
ON CONFLICT (id) DO NOTHING;

-- User 4: Riya Sen (Female, Art Curator in Colaba)
INSERT INTO users (id, phone, email, google_id, dob, gender, is_verified, status)
VALUES 
('44444444-4444-4444-4444-444444444444', '+919820044444', 'riya.sen@younme.social', 'google_444444', '2001-03-18', 'female', TRUE, 'active')
ON CONFLICT (id) DO NOTHING;

-- User 5: Tanya Kapoor (Female, Creator / Musician in Powai)
INSERT INTO users (id, phone, email, google_id, dob, gender, is_verified, status)
VALUES 
('55555555-5555-5555-5555-555555555555', '+919820055555', 'tanya.kapoor@younme.social', 'google_555555', '1999-11-09', 'female', TRUE, 'active')
ON CONFLICT (id) DO NOTHING;

-- 2. SEED PROFILES (With Mumbai PostGIS Coordinates)
-- Arjun: Bandra West (19.0596° N, 72.8295° E)
INSERT INTO profiles (user_id, nickname, bio, city, languages, geo_point, profile_progress, photo_urls, call_avatar_ref, liveness_verified, contact_share_unlocked)
VALUES 
('11111111-1111-1111-1111-111111111111', 'Arjun', 'Building next-gen AI tech. Coffee addict, indie vinyl records & sunset runs across Bandra Bandstand ☕⚡', 'Mumbai', ARRAY['English', 'Hindi', 'Marathi'], ST_SetSRID(ST_MakePoint(72.8295, 19.0596), 4326), 92, ARRAY['/aditya.jpg'], 'avatar_neon_cyber', TRUE, FALSE)
ON CONFLICT (user_id) DO NOTHING;

-- Ananya: Bandra Pali Hill (19.0650° N, 72.8280° E) ~ 0.8 km from Arjun
INSERT INTO profiles (user_id, nickname, bio, city, languages, geo_point, profile_progress, photo_urls, call_avatar_ref, liveness_verified, contact_share_unlocked)
VALUES 
('22222222-2222-2222-2222-222222222222', 'Ananya', 'UI designer & matcha lover 🍵 Seeking someone who laughs at witty dry humor. Let’s explore quaint cafes or museum galleries!', 'Mumbai', ARRAY['English', 'Hindi'], ST_SetSRID(ST_MakePoint(72.8280, 19.0650), 4326), 95, ARRAY['/ananya.jpg'], 'avatar_pastel_lotus', TRUE, FALSE)
ON CONFLICT (user_id) DO NOTHING;

-- Rohit: Juhu Beach (19.1075° N, 72.8263° E) ~ 5.3 km from Arjun
INSERT INTO profiles (user_id, nickname, bio, city, languages, geo_point, profile_progress, photo_urls, call_avatar_ref, liveness_verified, contact_share_unlocked)
VALUES 
('33333333-3333-3333-3333-333333333333', 'Rohit', 'Architecting spaces by day, chasing sunsets by evening. Fitness, rock climbing, and deep late-night conversations 🌇🧗‍♂️', 'Mumbai', ARRAY['English', 'Hindi', 'Punjabi'], ST_SetSRID(ST_MakePoint(72.8263, 19.1075), 4326), 88, ARRAY['/rohit.jpg'], 'avatar_iron_wolf', TRUE, FALSE)
ON CONFLICT (user_id) DO NOTHING;

-- Riya: Colaba Causeway (18.9220° N, 72.8347° E) ~ 15.2 km from Arjun
INSERT INTO profiles (user_id, nickname, bio, city, languages, geo_point, profile_progress, photo_urls, call_avatar_ref, liveness_verified, contact_share_unlocked)
VALUES 
('44444444-4444-4444-4444-444444444444', 'Riya', 'Curating art exhibitions, vintage bookstores, and jazz nights. Swipe right if you have an eclectic Spotify playlist 🎨🎷', 'Mumbai', ARRAY['English', 'Bengali', 'Hindi'], ST_SetSRID(ST_MakePoint(72.8347, 18.9220), 4326), 85, ARRAY['/riya.jpg'], 'avatar_retro_muse', TRUE, FALSE)
ON CONFLICT (user_id) DO NOTHING;

-- Tanya: Powai Hiranandani (19.1197° N, 72.9051° E) ~ 10.5 km from Arjun
INSERT INTO profiles (user_id, nickname, bio, city, languages, geo_point, profile_progress, photo_urls, call_avatar_ref, liveness_verified, contact_share_unlocked)
VALUES 
('55555555-5555-5555-5555-555555555555', 'Tanya', 'Singer-songwriter & verified creator. Live acoustic jams, travel vlogs, and spicy food quests 🎤🎸', 'Mumbai', ARRAY['English', 'Hindi'], ST_SetSRID(ST_MakePoint(72.9051, 19.1197), 4326), 90, ARRAY['/ananya.jpg'], 'avatar_golden_songbird', TRUE, FALSE)
ON CONFLICT (user_id) DO NOTHING;

-- 3. SEED WALLETS & LEDGER
-- Arjun (User 1): 250 coins
INSERT INTO wallets (user_id, balance, updated_at)
VALUES ('11111111-1111-1111-1111-111111111111', 250, NOW())
ON CONFLICT (user_id) DO NOTHING;

INSERT INTO transactions (id, user_id, type, coins, reference_id, idempotency_key, created_at)
VALUES 
(uuid_generate_v4(), '11111111-1111-1111-1111-111111111111', 'grant', 250, 'welcome_bonus_starter_pack', 'tx_init_111111', NOW())
ON CONFLICT (idempotency_key) DO NOTHING;

-- Ananya (User 2, Verified Creator): 620 coins (Eligible for Creator Cash-Out >500 coins)
INSERT INTO wallets (user_id, balance, updated_at)
VALUES ('22222222-2222-2222-2222-222222222222', 620, NOW())
ON CONFLICT (user_id) DO NOTHING;

INSERT INTO transactions (id, user_id, type, coins, reference_id, idempotency_key, created_at)
VALUES 
(uuid_generate_v4(), '22222222-2222-2222-2222-222222222222', 'earn', 620, 'creator_audio_call_earnings', 'tx_init_222222', NOW())
ON CONFLICT (idempotency_key) DO NOTHING;

-- 4. SEED AN EXISTING MUTUAL MATCH & CONVERSATION BETWEEN ARJUN & ANANYA
INSERT INTO matches (id, user_a, user_b, matched_at, source, status, message_pair_count)
VALUES 
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', NOW() - INTERVAL '1 day', 'swipe', 'active', 6)
ON CONFLICT (user_a, user_b) DO NOTHING;

INSERT INTO messages (conv_id, sender_id, type, body, is_flagged, created_at)
VALUES 
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '22222222-2222-2222-2222-222222222222', 'text', 'Hey Arjun! Saw you love filter kaapi and vinyl records. Have you tried Subko in Bandra?', FALSE, NOW() - INTERVAL '12 hours'),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 'text', 'Subko is practically my second office! Their sourdough croissants and pour-over are unbeatable.', FALSE, NOW() - INTERVAL '11 hours'),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '22222222-2222-2222-2222-222222222222', 'text', 'Haha great taste! What indie bands are currently playing on your turntable?', FALSE, NOW() - INTERVAL '10 hours');
