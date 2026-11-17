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
}
