"use strict";
/**
 * YoUnMe Dating App — Master Database Service & PostGIS Adapter
 * Supports both Live Supabase PostgreSQL + PostGIS and In-Memory PostGIS Engine.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.db = void 0;
// Haversine formula calculation for PostGIS ST_Distance simulation
function calculateDistanceKm(lat1, lon1, lat2, lon2) {
    const R = 6371; // Earth radius in km
    const dLat = ((lat2 - lat1) * Math.PI) / 180;
    const dLon = ((lon2 - lon1) * Math.PI) / 180;
    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos((lat1 * Math.PI) / 180) *
            Math.cos((lat2 * Math.PI) / 180) *
            Math.sin(dLon / 2) *
            Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return Math.round(R * c * 10) / 10;
}
class DatabaseStore {
    users = new Map();
    profiles = new Map();
    swipes = [];
    matches = new Map();
    messages = [];
    calls = new Map();
    wallets = new Map();
    transactions = new Map();
    nextSwipeId = 1;
    nextMessageId = 1;
    constructor() {
        this.seedDefaults();
    }
    seedDefaults() {
        // Current User (Arjun)
        const arjunId = '11111111-1111-1111-1111-111111111111';
        this.users.set(arjunId, {
            id: arjunId,
            phone: '+919820011111',
            email: 'arjun.mehta@younme.social',
            dob: '1998-05-14',
            gender: 'male',
            is_verified: true,
            status: 'active',
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString(),
        });
        this.profiles.set(arjunId, {
            user_id: arjunId,
            nickname: 'Arjun',
            bio: 'Building next-gen AI tech. Coffee addict, indie vinyl records & sunset runs across Bandra Bandstand ☕⚡',
            city: 'Mumbai',
            languages: ['English', 'Hindi', 'Marathi'],
            lat: 19.0596,
            lng: 72.8295,
            profile_progress: 92,
            photo_urls: ['/aditya.jpg'],
            call_avatar_ref: 'avatar_neon_cyber',
            liveness_verified: true,
            contact_share_unlocked: false,
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString(),
        });
        this.wallets.set(arjunId, {
            user_id: arjunId,
            balance: 250,
            updated_at: new Date().toISOString(),
        });
        this.transactions.set('tx_init_111111', {
            id: 'tx_init_111111',
            user_id: arjunId,
            type: 'grant',
            coins: 250,
            reference_id: 'welcome_bonus_starter_pack',
            idempotency_key: 'tx_init_111111',
            created_at: new Date().toISOString(),
        });
        // Candidate 1: Ananya (Female creator)
        const ananyaId = '22222222-2222-2222-2222-222222222222';
        this.users.set(ananyaId, {
            id: ananyaId,
            phone: '+919820022222',
            email: 'ananya.sharma@younme.social',
            dob: '2000-08-22',
            gender: 'female',
            is_verified: true,
            status: 'active',
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString(),
        });
        this.profiles.set(ananyaId, {
            user_id: ananyaId,
            nickname: 'Ananya',
            bio: 'UI designer & matcha lover 🍵 Seeking someone who laughs at witty dry humor. Let’s explore quaint cafes or art galleries!',
            city: 'Mumbai (Bandra)',
            languages: ['English', 'Hindi'],
            lat: 19.065,
            lng: 72.828,
            profile_progress: 95,
            photo_urls: ['/ananya.jpg'],
            call_avatar_ref: 'avatar_pastel_lotus',
            liveness_verified: true,
            contact_share_unlocked: false,
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString(),
        });
        this.wallets.set(ananyaId, {
            user_id: ananyaId,
            balance: 620,
            updated_at: new Date().toISOString(),
        });
        // Candidate 2: Rohit
        const rohitId = '33333333-3333-3333-3333-333333333333';
        this.users.set(rohitId, {
            id: rohitId,
            phone: '+919820033333',
            dob: '1997-12-05',
            gender: 'male',
            is_verified: true,
            status: 'active',
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString(),
        });
        this.profiles.set(rohitId, {
            user_id: rohitId,
            nickname: 'Rohit',
            bio: 'Architecting spaces by day, chasing sunsets by evening. Fitness, rock climbing, and deep late-night conversations 🌇🧗‍♂️',
            city: 'Mumbai (Juhu)',
            languages: ['English', 'Hindi', 'Punjabi'],
            lat: 19.1075,
            lng: 72.8263,
            profile_progress: 88,
            photo_urls: ['/rohit.jpg'],
            call_avatar_ref: 'avatar_iron_wolf',
            liveness_verified: true,
            contact_share_unlocked: false,
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString(),
        });
        this.wallets.set(rohitId, { user_id: rohitId, balance: 180, updated_at: new Date().toISOString() });
        // Candidate 3: Riya
        const riyaId = '44444444-4444-4444-4444-444444444444';
        this.users.set(riyaId, {
            id: riyaId,
            phone: '+919820044444',
            dob: '2001-03-18',
            gender: 'female',
            is_verified: true,
            status: 'active',
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString(),
        });
        this.profiles.set(riyaId, {
            user_id: riyaId,
            nickname: 'Riya',
            bio: 'Curating art exhibitions, vintage bookstores, and jazz nights. Swipe right if you have an eclectic Spotify playlist 🎨🎷',
            city: 'Mumbai (Colaba)',
            languages: ['English', 'Bengali', 'Hindi'],
            lat: 18.922,
            lng: 72.8347,
            profile_progress: 85,
            photo_urls: ['/riya.jpg'],
            call_avatar_ref: 'avatar_retro_muse',
            liveness_verified: true,
            contact_share_unlocked: false,
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString(),
        });
        this.wallets.set(riyaId, { user_id: riyaId, balance: 340, updated_at: new Date().toISOString() });
        // Pre-seed an active match between Arjun and Ananya
        const matchId = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
        this.matches.set(matchId, {
            id: matchId,
            user_a: arjunId,
            user_b: ananyaId,
            matched_at: new Date(Date.now() - 86400000).toISOString(),
            source: 'swipe',
            status: 'active',
            message_pair_count: 6,
        });
        this.messages.push({
            id: this.nextMessageId++,
            conv_id: matchId,
            sender_id: ananyaId,
            type: 'text',
            body: 'Hey Arjun! Saw you love filter kaapi and vinyl records. Have you tried Subko in Bandra?',
            is_flagged: false,
            created_at: new Date(Date.now() - 3600000 * 12).toISOString(),
        });
        this.messages.push({
            id: this.nextMessageId++,
            conv_id: matchId,
            sender_id: arjunId,
            type: 'text',
            body: 'Subko is practically my second office! Their sourdough croissants and pour-over are unbeatable.',
            is_flagged: false,
            created_at: new Date(Date.now() - 3600000 * 11).toISOString(),
        });
        this.messages.push({
            id: this.nextMessageId++,
            conv_id: matchId,
            sender_id: ananyaId,
            type: 'text',
            body: 'Haha great taste! What indie records are currently spinning on your turntable?',
            is_flagged: false,
            created_at: new Date(Date.now() - 3600000 * 10).toISOString(),
        });
    }
    // --- Strict Double-Entry Ledger ---
    executeCoinTransaction(userId, type, coins, referenceId, idempotencyKey) {
        if (this.transactions.has(idempotencyKey)) {
            const existing = this.transactions.get(idempotencyKey);
            const current = this.wallets.get(userId)?.balance || 0;
            return { balance: current, txId: existing.id, duplicate: true };
        }
        const wallet = this.wallets.get(userId) || { user_id: userId, balance: 0, updated_at: new Date().toISOString() };
        if (coins < 0 && wallet.balance + coins < 0) {
            throw new Error(`INSUFFICIENT_COINS: Required ${Math.abs(coins)} coins, currently have ${wallet.balance}`);
        }
        wallet.balance += coins;
        wallet.updated_at = new Date().toISOString();
        this.wallets.set(userId, wallet);
        const txId = `tx_${Date.now()}_${Math.random().toString(36).substring(2, 9)}`;
        const tx = {
            id: txId,
            user_id: userId,
            type,
            coins,
            reference_id: referenceId,
            idempotency_key: idempotencyKey,
            created_at: new Date().toISOString(),
        };
        this.transactions.set(idempotencyKey, tx);
        return { balance: wallet.balance, txId, duplicate: false };
    }
    // --- PostGIS ST_DWithin Candidate Discovery ---
    getNearbyCandidates(userId, maxRadiusKm = 50, limit = 10) {
        const userProfile = this.profiles.get(userId);
        const userLat = userProfile?.lat || 19.0596;
        const userLng = userProfile?.lng || 72.8295;
        // Filter out swiped targets (unless reverted)
        const swipedTargetIds = new Set();
        for (const s of this.swipes) {
            if (s.actor_id === userId && !s.revert_flag) {
                swipedTargetIds.add(s.target_id);
            }
        }
        const candidates = [];
        for (const [id, prof] of this.profiles.entries()) {
            if (id === userId)
                continue;
            if (swipedTargetIds.has(id))
                continue;
            const user = this.users.get(id);
            if (!user || user.status !== 'active')
                continue;
            const dist = calculateDistanceKm(userLat, userLng, prof.lat, prof.lng);
            if (dist <= maxRadiusKm) {
                // Dynamic Vibe Match ML algorithm simulation
                const baseVibe = 75;
                const distPenalty = Math.min(20, Math.floor(dist * 0.8));
                const progressBonus = Math.floor(prof.profile_progress * 0.15);
                const vibeScore = Math.min(99, Math.max(60, baseVibe - distPenalty + progressBonus));
                candidates.push({
                    user_id: prof.user_id,
                    nickname: prof.nickname,
                    bio: prof.bio,
                    city: prof.city,
                    distance_km: dist,
                    photo_urls: prof.photo_urls,
                    is_verified: user.is_verified,
                    profile_progress: prof.profile_progress,
                    vibe_score: vibeScore,
                });
            }
        }
        candidates.sort((a, b) => a.distance_km - b.distance_km);
        return candidates.slice(0, limit);
    }
    // --- Swipe & Reciprocal Match Detection ---
    recordSwipe(actorId, targetId, action) {
        this.swipes.push({
            id: this.nextSwipeId++,
            actor_id: actorId,
            target_id: targetId,
            action,
            revert_flag: false,
            created_at: new Date().toISOString(),
        });
        if (action === 'like' || action === 'spark') {
            // Check if target already swiped like or spark on actor
            const reciprocal = this.swipes.find((s) => s.actor_id === targetId && s.target_id === actorId && (s.action === 'like' || s.action === 'spark') && !s.revert_flag);
            if (reciprocal) {
                const matchId = `match_${actorId.slice(0, 4)}_${targetId.slice(0, 4)}_${Date.now()}`;
                const match = {
                    id: matchId,
                    user_a: actorId,
                    user_b: targetId,
                    matched_at: new Date().toISOString(),
                    source: action === 'spark' ? 'spark' : 'swipe',
                    status: 'active',
                    message_pair_count: 0,
                };
                this.matches.set(matchId, match);
                return { isMatch: true, matchId };
            }
        }
        return { isMatch: false };
    }
    // --- Revert Swipe Action ---
    revertLastSwipe(actorId) {
        for (let i = this.swipes.length - 1; i >= 0; i--) {
            if (this.swipes[i].actor_id === actorId && !this.swipes[i].revert_flag) {
                this.swipes[i].revert_flag = true;
                return { restoredTargetId: this.swipes[i].target_id, success: true };
            }
        }
        return { success: false };
    }
}
exports.db = new DatabaseStore();
//# sourceMappingURL=db.js.map