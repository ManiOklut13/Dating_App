/**
 * YoUnMe Dating App — Calls Controller
 * Provision LiveKit room tokens, handle LiveKit webhooks,
 * server-side billing heartbeats, and call ratings.
 */

import {
  Controller,
  Post,
  Body,
  Param,
  HttpCode,
  HttpStatus,
  UseGuards,
  UsePipes,
  ValidationPipe,
  Request,
} from '@nestjs/common';
import { CallsService } from './calls.service.js';
import { SupabaseAuthGuard } from '../../common/guards/supabase-auth.guard.js';
import { CurrentUser } from '../../auth/decorators/current-user.decorator.js';
import { AuthenticatedUser } from '../../auth/interfaces/authenticated-user.interface.js';
import { CreateCallTokenDto } from './dto/create-call-token.dto.js';
import { EndCallDto } from './dto/end-call.dto.js';
import { SubmitCallRatingDto } from './dto/submit-call-rating.dto.js';
import { RandomMatchDto } from './dto/random-match.dto.js';

@Controller('v1/calls')
export class CallsController {
  constructor(private readonly callsService: CallsService) {}

  @Post('token')
  @UseGuards(SupabaseAuthGuard)
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  createToken(
    @CurrentUser() user: AuthenticatedUser,
    @Body() body: CreateCallTokenDto,
  ) {
    const callerId = body.caller_id || user?.id || user?.uid;
    return this.callsService.createToken({
      ...body,
      caller_id: callerId,
    });
  }

  @Post(':id/heartbeat')
  @UseGuards(SupabaseAuthGuard)
  heartbeat(@Param('id') id: string) {
    return this.callsService.heartbeat(id);
  }

  @Post('webhook')
  @HttpCode(HttpStatus.OK)
  handleWebhook(@Body() payload: any, @Request() request: any) {
    return this.callsService.handleLiveKitWebhook(payload, request.headers);
  }

  @Post(':id/end')
  @UseGuards(SupabaseAuthGuard)
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  endCall(
    @Param('id') id: string,
    @Body() body: EndCallDto,
  ) {
    return this.callsService.endCall(id, body?.rating, body?.feedback || body?.reason);
  }

  @Post(':id/rating')
  @UseGuards(SupabaseAuthGuard)
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  submitRating(
    @Param('id') id: string,
    @Body() body: SubmitCallRatingDto,
  ) {
    return this.callsService.endCall(id, body?.rating, body?.feedback, body?.is_caller ?? true);
  }

  @Post('random/match')
  @UseGuards(SupabaseAuthGuard)
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  randomMatch(
    @CurrentUser() user: AuthenticatedUser,
    @Body() body: RandomMatchDto,
  ) {
    const userId = body.user_id || user?.id || user?.uid;
    return this.callsService.randomMatch({
      ...body,
      user_id: userId,
    });
  }
}
