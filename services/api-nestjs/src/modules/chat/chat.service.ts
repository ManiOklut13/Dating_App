/**
 * YoUnMe Dating App — Chat Service
 * Matches, conversation messages, "Likes You" stack, and in-flight Contact Guard enforcement.
 * Aligned with 22-table schema v3.2 (matches → user_a_id/user_b_id, chat_messages → raw_content/room_id,
 * swipes_interactions → actor_user_id/target_user_id/action_type/is_reverted).
 */

import { Injectable, NotFoundException, HttpException, HttpStatus } from '@nestjs/common';
import { db } from '../../database/db.js';
import { ContactGuardService } from './contact-guard.service.js';
import type { SendMessageDto } from './dto/send-message.dto.js';

const DEFAULT_USER_ID = '11111111-1111-1111-1111-111111111111';

@Injectable()
export class ChatService {
  constructor(private readonly contactGuard: ContactGuardService) {}

  getMatches(userId?: string) {
    const currentUserId = userId || DEFAULT_USER_ID;
    const userMatches: any[] = [];

    for (const m of db.matches.values()) {
      if (m.user_a_id === currentUserId || m.user_b_id === currentUserId) {
        const counterpartId = m.user_a_id === currentUserId ? m.user_b_id : m.user_a_id;
        const counterpartProfile = db.profiles.get(counterpartId);
        const counterpartUser   = db.users.get(counterpartId);

        // Find the chat room for this match
        const chatRoom = Array.from(db.chatRooms.values()).find((r) => r.match_id === m.id);
        const roomMessages = chatRoom
          ? db.messages.filter((msg) => msg.room_id === chatRoom.id)
          : [];
        const lastMsg = roomMessages[roomMessages.length - 1] || null;

        userMatches.push({
          id: m.id,
          matched_at: m.matched_at,
          status: m.status,
          counterpart: {
            user_id: counterpartId,
            nickname: counterpartProfile?.nickname || 'Match',
            avatar: '/ananya.jpg',
            city: counterpartProfile?.city || 'Mumbai',
            is_verified: counterpartProfile?.is_verified || false,
          },
          last_message: lastMsg
            ? {
                id: lastMsg.id,
                raw_content: lastMsg.raw_content,
                sender_id: lastMsg.sender_id,
                status: lastMsg.status,
                created_at: lastMsg.created_at,
              }
            : null,
          unread_count: 0,
        });
      }
    }

    return { success: true, matches: userMatches };
  }

  getLikesYou(userId?: string) {
    const currentUserId = userId || DEFAULT_USER_ID;

    // swipes_interactions: find incoming likes / sparks targeting current user
    const incomingLikes = db.swipes.filter(
      (s) =>
        s.target_user_id === currentUserId &&
        (s.action_type === 'like' || s.action_type === 'spark') &&
        !s.is_reverted,
    );

    const items = incomingLikes.map((s) => {
      const prof = db.profiles.get(s.actor_user_id);
      return {
        actor_user_id: s.actor_user_id,
        nickname: prof?.nickname ? prof.nickname[0] + '***' : 'User',
        age: 23,
        blurred_avatar: '/ananya.jpg',
        city: prof?.city || 'Mumbai',
        action_type: s.action_type,
        created_at: s.created_at,
        blur_hash: 'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
      };
    });

    return {
      success: true,
      count: items.length,
      likes_stack: items,
      unlock_fee_coins: 50,
    };
  }

  getMessages(roomId: string) {
    const chatRoom = db.chatRooms.get(roomId);
    if (!chatRoom) {
      throw new NotFoundException('Chat room not found');
    }

    const match = chatRoom.match_id ? db.matches.get(chatRoom.match_id) : null;
    const msgs = db.messages.filter((m) => m.room_id === roomId);

    const matchedDate = match ? new Date(match.matched_at).getTime() : Date.now();
    const activeDays = Math.floor((Date.now() - matchedDate) / (1000 * 60 * 60 * 24));

    return {
      success: true,
      room_id: roomId,
      match_id: chatRoom.match_id,
      active_days: activeDays,
      messages: msgs,
    };
  }

  sendMessage(body: SendMessageDto) {
    const { room_id, message_type, raw_content, vanish_seconds } = body || {};
    const currentSender = body?.sender_id || DEFAULT_USER_ID;

    const chatRoom = db.chatRooms.get(room_id);
    if (!chatRoom) {
      throw new NotFoundException('Chat room not found');
    }

    const match = chatRoom.match_id ? db.matches.get(chatRoom.match_id) : null;
    const matchedDate = match ? new Date(match.matched_at).getTime() : Date.now();
    const activeDays = Math.floor((Date.now() - matchedDate) / (1000 * 60 * 60 * 24));
    const messagePairCount = db.messages.filter((m) => m.room_id === room_id).length;

    const guard = this.contactGuard.check(raw_content || '', activeDays, messagePairCount);
    if (guard.blocked) {
      const currentStrikes = this.contactGuard.registerStrike(currentSender);
      throw new HttpException(
        {
          error: 'CONTACT_GUARD_VIOLATION',
          reason: guard.reason,
          detected_type: guard.detected,
          strike_count: currentStrikes,
          unlock_rule: 'Unlocks after 3 days of matching or 20 message pairs exchanged.',
        },
        HttpStatus.UNPROCESSABLE_ENTITY,
      );
    }

    const newMsg = {
      id: `msg_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`,
      room_id,
      sender_id: currentSender,
      message_type: (message_type || 'text') as any,
      raw_content: raw_content || '',
      is_view_once: !!vanish_seconds,
      scan_status: 'clean' as const,
      is_flagged: false,
      is_message_pinned: false,
      status: 'sent' as const,
      sent_at: new Date().toISOString(),
      created_at: new Date().toISOString(),
    };

    db.messages.push(newMsg);

    // Update last_message_at on the room
    const room = db.chatRooms.get(room_id);
    if (room) {
      room.last_message_at = newMsg.created_at;
    }

    return {
      success: true,
      message: newMsg,
    };
  }
}
