/**
 * YoUnMe Dating App — Message Requests Controller
 * Incoming/outgoing message request endpoints for crushes, likes, and dislikes.
 * Protected by SupabaseAuthGuard.
 */

import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  UseGuards,
  UsePipes,
  ValidationPipe,
} from '@nestjs/common';
import { SupabaseAuthGuard } from '../../common/guards/supabase-auth.guard.js';
import { CurrentUser } from '../../auth/decorators/current-user.decorator.js';
import { AuthenticatedUser } from '../../auth/interfaces/authenticated-user.interface.js';
import { RecordMessageRequestDto } from './dto/record-message-request.dto.js';

@Controller('v1')
@UseGuards(SupabaseAuthGuard)
export class RequestsController {
  constructor() {}

  @Get('chats/requests/incoming')
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  getIncomingRequests(
    @CurrentUser() user: AuthenticatedUser,
  ) {
    const currentUserId = user?.id || user?.uid || '';
    // In a real implementation, this would query swipes_interactions or a dedicated
    // message_requests table for incoming requests targeting the current user
    return {
      success: true,
      incoming_requests: [],
      message: 'Incoming message requests endpoint - placeholder',
    };
  }

  @Post('chats/requests/:requestId/action')
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  actionOnRequest(
    @CurrentUser() user: AuthenticatedUser,
    @Param('requestId') requestId: string,
    @Body() body: RecordMessageRequestDto,
  ) {
    const currentUserId = user?.id || user?.uid || '';
    const { action } = body;

    return {
      success: true,
      request_id: requestId,
      action,
      acted_by: currentUserId,
      message: `Request ${action} processed successfully`,
    };
  }

  @Get('chats/requests/outgoing')
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  getOutgoingRequests(
    @CurrentUser() user: AuthenticatedUser,
  ) {
    const currentUserId = user?.id || user?.uid || '';
    // In a real implementation, this would query swipes_interactions or a dedicated
    // message_requests table for outgoing requests from the current user
    return {
      success: true,
      outgoing_requests: [],
      message: 'Outgoing message requests endpoint - placeholder',
    };
  }
}