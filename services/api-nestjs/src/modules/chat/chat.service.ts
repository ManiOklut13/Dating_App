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

  // ── New Conversation & Messaging Service Methods ─────────────────────

  getConversations(userId?: string) {
    const currentUserId = userId || DEFAULT_USER_ID;
    const userMatches: any[] = [];

    // Find all matches for the current user
    for (const m of db.matches.values()) {
      if (m.user_a_id === currentUserId || m.user_b_id === currentUserId) {
        const counterpartId = m.user_a_id === currentUserId ? m.user_b_id : m.user_a_id;
        const counterpartProfile = db.profiles.get(counterpartId);
        const chatRoom = Array.from(db.chatRooms.values()).find((r) => r.match_id === m.id);
        const roomMessages = chatRoom
          ? db.messages.filter((msg) => msg.room_id === chatRoom.id)
          : [];
        const lastMsg = roomMessages[roomMessages.length - 1] || null;
        const matchedDate = m.matched_at ? new Date(m.matched_at).getTime() : Date.now();
        const activeDays = Math.floor((Date.now() - matchedDate) / (1000 * 60 * 60 * 24));

        userMatches.push({
          id: m.id,
          match_id: m.id,
          counterpart_user_id: counterpartId,
          counterpart_nickname: counterpartProfile?.nickname || 'Match',
          counterpart_avatar: counterpartProfile?.avatar_object_key || '/ananya.jpg',
          counterpart_city: counterpartProfile?.city || 'Mumbai',
          counterpart_is_verified: counterpartProfile?.is_verified || false,
          status: m.status,
          matched_at: m.matched_at,
          last_message: lastMsg
            ? {
                id: lastMsg.id,
                raw_content: lastMsg.raw_content,
                sender_id: lastMsg.sender_id,
                status: lastMsg.status,
                created_at: lastMsg.created_at,
              }
            : null,
          active_days: activeDays,
          contact_share_unlocked: chatRoom?.contact_share_unlocked || false,
        });
      }
    }

    // Also include active chat rooms that may not have a match (e.g., pending requests)
    for (const room of db.chatRooms.values()) {
      const alreadyMatch = userMatches.find((m) => m.match_id === room.id);
      if (alreadyMatch) continue;

      const requestSender = room.request_sender_id;
      const requestReceiver = room.request_receiver_id;

      let counterpartId: string;
      let counterpartNickname: string;
      let counterpartAvatar: string;
      let counterpartCity: string;
      let counterpartVerified: boolean;
      let isIncomingRequest = false;

      if (requestReceiver === currentUserId) {
        // Incoming request (someone wants to chat with current user)
        counterpartId = requestSender;
        isIncomingRequest = true;
      } else if (requestSender === currentUserId) {
        // Outgoing request (current user sent a request)
        counterpartId = requestReceiver;
      } else {
        // Chat room unrelated to current user skip
        continue;
      }

      const counterpartProfile = db.profiles.get(counterpartId);
      if (!counterpartProfile) continue;

      counterpartNickname = counterpartProfile?.nickname || 'User';
      counterpartAvatar = counterpartProfile?.avatar_object_key || '/ananya.jpg';
      counterpartCity = counterpartProfile?.city || 'Mumbai';
      counterpartVerified = counterpartProfile?.is_verified || false;

      // Find last message in this room
      const roomMessages = db.messages.filter((msg) => msg.room_id === room.id);
      const lastMsg = roomMessages[roomMessages.length - 1] || null;
      const matchedDate = room.last_message_at ? new Date(room.last_message_at).getTime() : Date.now();
      const activeDays = Math.floor((Date.now() - matchedDate) / (1000 * 60 * 60 * 24));

userMatches.push({
          id: room.id,
          match_id: room.match_id || null,
          counterpart_user_id: counterpartId,
          counterpart_nickname: counterpartNickname,
          counterpart_avatar: counterpartAvatar,
          counterpart_city: counterpartCity,
          counterpart_is_verified: counterpartVerified,
          status: room.request_status || 'pending',
          matched_at: room.created_at,
          last_message: lastMsg
            ? {
                id: lastMsg.id,
                raw_content: lastMsg.raw_content,
                sender_id: lastMsg.sender_id,
                status: lastMsg.status,
                created_at: lastMsg.created_at,
              }
            : null,
          active_days: activeDays,
          contact_share_unlocked: room.contact_share_unlocked || false,
          is_incoming_request: isIncomingRequest,
        });
    }

    return {
      success: true,
      conversations: userMatches,
    };
  }

  getConversationMessages(
    userId: string,
    conversationId: string,
    page?: number,
    limit?: number,
  ) {
    const chatRoom = db.chatRooms.get(conversationId);
    if (!chatRoom) {
      throw new NotFoundException('Conversation not found');
    }

    const msgs = db.messages.filter((m) => m.room_id === conversationId);

    // Sort by created_at descending (newest first)
    const sortedMsgs = msgs.sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime());

    // Apply pagination
    const pageNum = page || 1;
    const pageSize = limit || 50;
    const startIdx = (pageNum - 1) * pageSize;
    const endIdx = startIdx + pageSize;
    const paginatedMsgs = sortedMsgs.slice(startIdx, endIdx);

    return {
      success: true,
      room_id: conversationId,
      messages: paginatedMsgs,
      page: pageNum,
      page_size: pageSize,
      total_count: sortedMsgs.length,
    };
  }

  sendConversationMessage(
    conversationId: string,
    body: SendMessageDto,
  ) {
    const room_id = conversationId;
    const { room_id: _, message_type, raw_content, vanish_seconds } = body || {};
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
      throw new HttpException(
        {
          error: 'CONTACT_GUARD_VIOLATION',
          reason: guard.reason,
          detected_type: guard.detected,
          strike_count: 0,
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

  getIcebreakers() {
    const icebreakers = [
      { id: 'ib_1', text: 'Hey! Your profile says you love coffee. What\'s your favorite local spot?' },
      { id: 'ib_2', text: 'I noticed you\'re into [interest]. How did you get into that?' },
      { id: 'ib_3', text: 'Travel question: if you could teleport anywhere right now, where would you go?' },
      { id: 'ib_4', text: 'Best book you\'ve read recently? Always down for recommendations.' },
      { id: 'ib_5', text: 'If you could have dinner with anyone, living or dead, who would it be?' },
    ];

    return {
      success: true,
      icebreakers,
    };
  }

  getCallHistory(conversationId: string, userId?: string) {
    const chatRoom = db.chatRooms.get(conversationId);
    if (!chatRoom) {
      throw new NotFoundException('Conversation not found');
    }

    // Find calls associated with this chat room / match
    const userCalls = Array.from(db.calls.values()).filter(
      (call) =>
        (call.caller_user_id === userId || call.callee_user_id === userId) &&
        call.match_id !== undefined,
    );

    // Also filter by match if chat room has a match_id
    const filteredCalls = userCalls.filter(
      (call) => chatRoom.match_id ? call.match_id === chatRoom.match_id : true,
    );

    return {
      success: true,
      conversation_id: conversationId,
      calls: filteredCalls,
    };
  }

  initiateCall(
    conversationId: string,
    userId: string,
    callType: 'audio' | 'video',
    durationSeconds?: number,
  ) {
    const chatRoom = db.chatRooms.get(conversationId);
    if (!chatRoom) {
      throw new NotFoundException('Conversation not found');
    }

    const callId = `call_${Date.now()}_${Math.random().toString(36).substring(2, 9)}`;

    // Determine the counterpart user ID
    let counterpartId: string;
    if (chatRoom.request_sender_id === userId) {
      counterpartId = chatRoom.request_receiver_id;
    } else if (chatRoom.request_receiver_id === userId) {
      counterpartId = chatRoom.request_sender_id;
    } else {
      // For matched users, find the counterpart from the match
      const match = db.matches.get(chatRoom.match_id || '');
      if (match) {
        counterpartId = userId === match.user_a_id ? match.user_b_id : match.user_a_id;
      } else {
        counterpartId = '';
      }
    }

    const callRecord: any = {
      id: callId,
      livekit_room_name: `room_${callId}`,
      caller_user_id: userId,
      callee_user_id: counterpartId,
      match_id: chatRoom.match_id,
      call_type: callType,
      is_random_blind_call: false,
      status: 'initiating',
      duration_seconds: durationSeconds || 0,
      audio_duration_seconds: 0,
      video_duration_seconds: 0,
      media_switches_log: [],
      caller_coins_type: 'debited',
      caller_coins: 10,
      callee_coins_type: 'credited',
      callee_coins: 10,
      is_hidden_for_caller: false,
      is_hidden_for_callee: false,
      caller_ratings_json: {},
      callee_ratings_json: {},
      created_at: new Date().toISOString(),
      started_at: new Date().toISOString(),
    };

    db.calls.set(callId, callRecord);

    // Deduct coins from caller
    // TODO: In production, use databaseService.executeCoinTransaction

    return {
      success: true,
      call_id: callId,
      livekit_room_name: callRecord.livekit_room_name,
      call_type: callType,
      counterpart_user_id: counterpartId,
      status: 'initiating',
      coins_deducted: 10,
    };
  }

  chatSettingsAction(
    conversationId: string,
    userId: string,
    action: 'block' | 'restrict' | 'report' | 'unmatch',
    reason?: string,
  ) {
    const chatRoom = db.chatRooms.get(conversationId);
    if (!chatRoom) {
      throw new NotFoundException('Conversation not found');
    }

    const match = chatRoom.match_id ? db.matches.get(chatRoom.match_id) : null;

    // Block or restrict the counterpart
    if (action === 'block' || action === 'restrict') {
      const counterpartId = match
        ? match.user_a_id === userId ? match.user_b_id : match.user_a_id
        : chatRoom.request_sender_id === userId
          ? chatRoom.request_receiver_id
          : chatRoom.request_sender_id;

      // Add to user_blocks_reports
      const blockReportId = `br_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`;
      const blockRecord: any = {
        id: blockReportId,
        actor_user_id: userId,
        target_user_id: counterpartId,
        action_type: action,
        action_location: '',
        reason_category: reason || 'other',
        description: reason || 'User action',
        status: 'actioned',
        created_at: new Date().toISOString(),
      };

      db.blocksReports.push(blockRecord);

      // Update chat room status
      chatRoom.request_status = action === 'block' ? 'declined' : 'restricted';

      return {
        success: true,
        action,
        blocked_user_id: counterpartId,
        status: chatRoom.request_status,
      };
    }

    // Report
    if (action === 'report') {
      const counterpartId = match
        ? match.user_a_id === userId ? match.user_b_id : match.user_a_id
        : chatRoom.request_sender_id === userId
          ? chatRoom.request_receiver_id
          : chatRoom.request_sender_id;

      const reportRecord: any = {
        id: `br_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`,
        actor_user_id: userId,
        target_user_id: counterpartId,
        action_type: 'report',
        action_location: '',
        reason_category: reason || 'other',
        description: reason || 'User report',
        status: 'open',
        created_at: new Date().toISOString(),
      };

      db.blocksReports.push(reportRecord);

      return {
        success: true,
        action: 'report',
        reported_user_id: counterpartId,
        status: 'open',
      };
    }

    // Unmatch
    if (action === 'unmatch') {
      const counterpartId = match
        ? match.user_a_id === userId ? match.user_b_id : match.user_a_id
        : null;

      // Remove the match
      if (match) {
        db.matches.delete(match.id);
      }

      // Remove the chat room
      db.chatRooms.delete(conversationId);

      // Remove associated messages
      db.messages = db.messages.filter((m) => m.room_id !== conversationId);

      return {
        success: true,
        action: 'unmatch',
        unmatched_user_id: counterpartId,
      };
    }

    throw new HttpException('Invalid action', HttpStatus.BAD_REQUEST);
  }
}
