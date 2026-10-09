import { Router, Request, Response } from 'express';
import { db } from '../../../database/db.js';

export const chatRouter = Router();

// In-memory link guard strike counts
const userStrikes = new Map<string, number>();

/**
 * Normalizes text to catch homoglyphs and phone number leaks
 */
function checkContactGuard(text: string, activeDays: number, pairCount: number) {
  if (activeDays >= 3 || pairCount >= 20) {
    return { blocked: false };
  }

  const clean = text.replace(/[@0]/g, (m) => (m === '@' ? 'a' : 'o')).toLowerCase();
  const digitsOnly = text.replace(/\D/g, '');

  if (digitsOnly.length >= 10) {
    return {
      blocked: true,
      reason: 'Sharing phone numbers is restricted during the trust-building phase (Unlocks after 3 days or 20 messages).',
      detected: 'phone_number',
    };
  }

  const socialRegex = /(insta|ig|telegram|snap|snapchat|t\.me|wa\.me|whatsapp)\s*[:@\s_-]?\s*([a-zA-Z0-9_.]{3,})/i;
  if (socialRegex.test(clean)) {
    return {
      blocked: true,
      reason: 'Social handles (Instagram, Telegram, WhatsApp) unlock automatically after 3 days of active connection.',
      detected: 'social_handle',
    };
  }

  const urlRegex = /(https?:\/\/|www\.)[^\s]+|([a-zA-Z0-9-]+\.(com|org|net|io|in|me|app))/i;
  if (urlRegex.test(text)) {
    return {
      blocked: true,
      reason: 'External web links are blocked for anti-fraud and user safety.',
      detected: 'external_url',
    };
  }

  return { blocked: false };
}

/**
 * GET /v1/matches
 */
chatRouter.get('/matches', (req: Request, res: Response) => {
  const userId = (req.query.user_id as string) || '11111111-1111-1111-1111-111111111111';

  const userMatches: any[] = [];
  for (const m of db.matches.values()) {
    if (m.user_a === userId || m.user_b === userId) {
      const counterpartId = m.user_a === userId ? m.user_b : m.user_a;
      const counterpartProfile = db.profiles.get(counterpartId);
      const counterpartUser = db.users.get(counterpartId);

      const convMessages = db.messages.filter((msg) => msg.conv_id === m.id);
      const lastMsg = convMessages[convMessages.length - 1];

      userMatches.push({
        id: m.id,
        matched_at: m.matched_at,
        source: m.source,
        message_pair_count: m.message_pair_count,
        counterpart: {
          user_id: counterpartId,
          nickname: counterpartProfile?.nickname || 'Match',
          avatar: counterpartProfile?.photo_urls[0] || '/ananya.jpg',
          city: counterpartProfile?.city || 'Mumbai',
          is_verified: counterpartUser?.is_verified || false,
          call_avatar_ref: counterpartProfile?.call_avatar_ref,
        },
        last_message: lastMsg || null,
        unread_count: 0,
      });
    }
  }

  return res.json({ success: true, matches: userMatches });
});

/**
 * GET /v1/connect/likes-you
 * 'Likes You' blurred profile stack
 */
chatRouter.get('/connect/likes-you', (req: Request, res: Response) => {
  const userId = (req.query.user_id as string) || '11111111-1111-1111-1111-111111111111';

  // Find users who swiped like on this user
  const incomingLikes = db.swipes.filter((s) => s.target_id === userId && (s.action === 'like' || s.action === 'spark'));

  const items = incomingLikes.map((s) => {
    const prof = db.profiles.get(s.actor_id);
    return {
      actor_id: s.actor_id,
      nickname: prof?.nickname ? prof.nickname[0] + '***' : 'User', // Blurred teaser
      age: 23,
      blurred_avatar: prof?.photo_urls[0] || '/ananya.jpg',
      city: prof?.city || 'Mumbai',
      action: s.action,
      created_at: s.created_at,
      blur_hash: 'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
    };
  });

  return res.json({
    success: true,
    count: items.length,
    likes_stack: items,
    unlock_fee_coins: 50,
  });
});

/**
 * GET /v1/messages/:convId
 */
chatRouter.get('/messages/:convId', (req: Request, res: Response) => {
  const { convId } = req.params;
  const match = db.matches.get(convId);
  if (!match) {
    return res.status(404).json({ error: 'Conversation not found' });
  }

  const msgs = db.messages.filter((m) => m.conv_id === convId);
  const matchedDate = new Date(match.matched_at).getTime();
  const activeDays = Math.floor((Date.now() - matchedDate) / (1000 * 60 * 60 * 24));
  const contactUnlocked = activeDays >= 3 || match.message_pair_count >= 20;

  return res.json({
    success: true,
    conversation_id: convId,
    contact_sharing_unlocked: contactUnlocked,
    active_days: activeDays,
    message_pair_count: match.message_pair_count,
    messages: msgs,
  });
});

/**
 * POST /v1/messages
 * Sends message with in-flight Contact & Link Guard
 */
chatRouter.post('/messages', (req: Request, res: Response) => {
  const { conv_id, sender_id, type, body, media_url, vanish_seconds } = req.body;
  const currentSender = sender_id || '11111111-1111-1111-1111-111111111111';

  const match = db.matches.get(conv_id);
  if (!match) {
    return res.status(404).json({ error: 'Conversation not found' });
  }

  const matchedDate = new Date(match.matched_at).getTime();
  const activeDays = Math.floor((Date.now() - matchedDate) / (1000 * 60 * 60 * 24));

  // Run in-flight Contact & Link Guard
  const guard = checkContactGuard(body || '', activeDays, match.message_pair_count);
  if (guard.blocked) {
    const currentStrikes = (userStrikes.get(currentSender) || 0) + 1;
    userStrikes.set(currentSender, currentStrikes);

    return res.status(422).json({
      error: 'CONTACT_GUARD_VIOLATION',
      reason: guard.reason,
      detected_type: guard.detected,
      strike_count: currentStrikes,
      unlock_rule: 'Unlocks after 3 days of matching or 20 message pairs exchanged.',
    });
  }

  const expiresAt = vanish_seconds ? new Date(Date.now() + vanish_seconds * 1000).toISOString() : null;

  const newMsg = {
    id: db.messages.length + 1,
    conv_id,
    sender_id: currentSender,
    type: type || 'text',
    body: body || '',
    media_url: media_url || undefined,
    expires_at: expiresAt,
    is_flagged: false,
    created_at: new Date().toISOString(),
  };

  db.messages.push(newMsg);
  match.message_pair_count += 1;

  return res.json({
    success: true,
    message: newMsg,
    message_pair_count: match.message_pair_count,
  });
});
