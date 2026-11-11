-- =====================================================================
-- YoUnMe — Post-apply verification
-- Run this in the Supabase SQL Editor AFTER applying schema.sql + seeds.sql.
-- =====================================================================

-- 1. All 24 tables present, with row counts
SELECT 'app_users' AS table_name, count(*) FROM app_users
UNION ALL SELECT 'user_profiles', count(*) FROM user_profiles
UNION ALL SELECT 'user_photos', count(*) FROM user_photos
UNION ALL SELECT 'prompts_master', count(*) FROM prompts_master
UNION ALL SELECT 'user_prompt_answers', count(*) FROM user_prompt_answers
UNION ALL SELECT 'swipes_interactions', count(*) FROM swipes_interactions
UNION ALL SELECT 'user_quotas', count(*) FROM user_quotas
UNION ALL SELECT 'matches', count(*) FROM matches
UNION ALL SELECT 'gifts', count(*) FROM gifts
UNION ALL SELECT 'user_gifts', count(*) FROM user_gifts
UNION ALL SELECT 'chat_rooms', count(*) FROM chat_rooms
UNION ALL SELECT 'chat_participant_settings', count(*) FROM chat_participant_settings
UNION ALL SELECT 'chat_messages', count(*) FROM chat_messages
UNION ALL SELECT 'call_sessions', count(*) FROM call_sessions
UNION ALL SELECT 'user_wallets', count(*) FROM user_wallets
UNION ALL SELECT 'wallet_transactions', count(*) FROM wallet_transactions
UNION ALL SELECT 'user_blocks_reports', count(*) FROM user_blocks_reports
UNION ALL SELECT 'meetup', count(*) FROM meetup
UNION ALL SELECT 'date_memories', count(*) FROM date_memories
UNION ALL SELECT 'plans', count(*) FROM plans
UNION ALL SELECT 'payment_orders', count(*) FROM payment_orders
UNION ALL SELECT 'user_subscriptions', count(*) FROM user_subscriptions
UNION ALL SELECT 'user_payout_kyc', count(*) FROM user_payout_kyc
UNION ALL SELECT 'payout_requests', count(*) FROM payout_requests
ORDER BY 1;

-- 2. RLS check (must be ON for all public tables)
SELECT relname AS table_name, relrowsecurity AS rls_enabled
FROM pg_class
WHERE relnamespace = 'public'::regnamespace AND relkind = 'r'
ORDER BY 1;

-- 3. Stored procedures / authoritative functions
SELECT p.proname AS function, pg_get_function_result(p.oid) AS returns
FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname = 'public' AND p.proname LIKE 'fn_%'
ORDER BY 1;

-- 4. PostGIS + pgcrypto extensions
SELECT extname, extversion FROM pg_extension
WHERE extname IN ('postgis', 'pgcrypto', 'uuid-ossp') ORDER BY 1;

-- 5. Nearby candidate discovery test (around Arjun in Bandra West)
SELECT nickname, city, ROUND(distance_km::numeric, 2) AS distance_km, is_verified
FROM fn_get_nearby_candidates('11111111-1111-1111-1111-111111111111', 50000, 10)
ORDER BY distance_km;

-- 6. User wallet ledger balance check
SELECT w.user_id, p.nickname, w.coin_balance,
       COALESCE(SUM(t.coin_amount), 0) AS ledger_sum
FROM user_wallets w
JOIN user_profiles p ON p.user_id = w.user_id
LEFT JOIN wallet_transactions t ON t.user_id = w.user_id
GROUP BY w.user_id, p.nickname, w.coin_balance
ORDER BY p.nickname;
