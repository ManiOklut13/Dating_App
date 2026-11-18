/**
 * YoUnMe Dating App — Chat Controller
 * Aligned with 22-table schema v3.2: room_id, raw_content, message_type.
 * Protected by SupabaseAuthGuard.
 */

import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Query,
  UseGuards,
  UsePipes,
  ValidationPipe,
} from '@nestjs/common';
import { ChatService } from './chat.service.js';
import { SendMessageDto } from './dto/send-message.dto.js';
import { SupabaseAuthGuard } from '../../common/guards/supabase-auth.guard.js';
import { CurrentUser } from '../../auth/decorators/current-user.decorator.js';
import { AuthenticatedUser } from '../../auth/interfaces/authenticated-user.interface.js';

@Controller('v1')
@UseGuards(SupabaseAuthGuard)
export class ChatController {
  constructor(private readonly chatService: ChatService) {}

  @Get('matches')
  getMatches(
    @CurrentUser() user: AuthenticatedUser,
    @Query('user_id') userId?: string,
  ) {
    const effectiveUserId = userId || user?.id || user?.uid;
    return this.chatService.getMatches(effectiveUserId);
  }

  @Get('connect/likes-you')
  getLikesYou(
    @CurrentUser() user: AuthenticatedUser,
    @Query('user_id') userId?: string,
  ) {
    const effectiveUserId = userId || user?.id || user?.uid;
    return this.chatService.getLikesYou(effectiveUserId);
  }

  @Get('messages/:roomId')
  getMessages(@Param('roomId') roomId: string) {
    return this.chatService.getMessages(roomId);
  }

  @Post('messages')
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  sendMessage(
    @CurrentUser() user: AuthenticatedUser,
    @Body() body: SendMessageDto,
  ) {
    const effectiveSenderId = body.sender_id || user?.id || user?.uid;
    return this.chatService.sendMessage({
      ...body,
      sender_id: effectiveSenderId,
    });
  }

  // ── Conversation & Messaging Endpoints ────────────────────────────────

  @Get('conversations')
  getConversations(
    @CurrentUser() user: AuthenticatedUser,
    @Query('user_id') userId?: string,
  ) {
    const effectiveUserId = userId || user?.id || user?.uid;
    return this.chatService.getConversations(effectiveUserId);
  }

  @Get('conversations/:conversationId/messages')
  getConversationMessages(
    @CurrentUser() user: AuthenticatedUser,
    @Param('conversationId') conversationId: string,
    @Query('page') page?: number,
    @Query('limit') limit?: number,
  ) {
    const effectiveUserId = user?.id || user?.uid || '';
    return this.chatService.getConversationMessages(
      effectiveUserId,
      conversationId,
      page ? Number(page) : undefined,
      limit ? Number(limit) : undefined,
    );
  }

  @Post('conversations/:conversationId/messages')
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  sendConversationMessage(
    @CurrentUser() user: AuthenticatedUser,
    @Param('conversationId') conversationId: string,
    @Body() body: SendMessageDto,
  ) {
    const effectiveSenderId = body.sender_id || user?.id || user?.uid;
    return this.chatService.sendConversationMessage(
      conversationId,
      {
        ...body,
        sender_id: effectiveSenderId,
      },
    );
  }

  @Get('icebreakers')
  getIcebreakers() {
    return this.chatService.getIcebreakers();
  }

  @Get('conversations/:conversationId/call-history')
  getCallHistory(
    @CurrentUser() user: AuthenticatedUser,
    @Param('conversationId') conversationId: string,
  ) {
    const effectiveUserId = user?.id || user?.uid || '';
    return this.chatService.getCallHistory(conversationId, effectiveUserId);
  }

  @Post('conversations/:conversationId/calls/initiate')
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  initiateCall(
    @CurrentUser() user: AuthenticatedUser,
    @Param('conversationId') conversationId: string,
    @Body() body: { call_type: 'audio' | 'video'; duration_seconds?: number },
  ) {
    const effectiveUserId = user?.id || user?.uid || '';
    return this.chatService.initiateCall(
      conversationId,
      effectiveUserId,
      body.call_type,
      body.duration_seconds,
    );
  }

  @Post('conversations/:conversationId/settings/action')
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  chatSettingsAction(
    @CurrentUser() user: AuthenticatedUser,
    @Param('conversationId') conversationId: string,
    @Body() body: {
      action: 'block' | 'restrict' | 'report' | 'unmatch';
      reason?: string;
    },
  ) {
    const effectiveUserId = user?.id || user?.uid || '';
    return this.chatService.chatSettingsAction(
      conversationId,
      effectiveUserId,
      body.action,
      body.reason,
    );
  }
}
