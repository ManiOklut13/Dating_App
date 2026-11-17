/**
 * YoUnMe Dating App — Discovery Controller
 * Candidate deck, swipes, and geo map radar endpoints.
 * Protected by SupabaseAuthGuard.
 */

import {
  Controller,
  Get,
  Post,
  Body,
  Query,
  UseGuards,
  UsePipes,
  ValidationPipe,
} from '@nestjs/common';
import { DiscoveryService } from './discovery.service.js';
import { SupabaseAuthGuard } from '../../common/guards/supabase-auth.guard.js';
import { CurrentUser } from '../../auth/decorators/current-user.decorator.js';
import { AuthenticatedUser } from '../../auth/interfaces/authenticated-user.interface.js';
import { RecordSwipeDto } from './dto/record-swipe.dto.js';
import { RevertSwipeDto } from './dto/revert-swipe.dto.js';
import { DiscoveryDeckQueryDto } from './dto/discovery-deck-query.dto.js';

@Controller('v1')
@UseGuards(SupabaseAuthGuard)
export class DiscoveryController {
  constructor(private readonly discoveryService: DiscoveryService) {}

  @Get('discovery/deck')
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  getDeck(
    @CurrentUser() user: AuthenticatedUser,
    @Query() query: DiscoveryDeckQueryDto,
  ) {
    const effectiveUserId = query.user_id || user?.id || user?.uid;
    return this.discoveryService.getDeck(
      effectiveUserId,
      parseFloat(query.radius_km || '50'),
      query.min_age ? parseInt(query.min_age, 10) : undefined,
      query.max_age ? parseInt(query.max_age, 10) : undefined,
    );
  }

  @Get('discovery/map')
  getMap(
    @CurrentUser() user: AuthenticatedUser,
    @Query('user_id') userId?: string,
  ) {
    const effectiveUserId = userId || user?.id || user?.uid;
    return this.discoveryService.getMap(effectiveUserId);
  }

  @Post('swipes')
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  recordSwipe(
    @CurrentUser() user: AuthenticatedUser,
    @Body() body: RecordSwipeDto,
  ) {
    const effectiveActorId = body.actor_id || user?.id || user?.uid;
    return this.discoveryService.recordSwipe(
      effectiveActorId,
      body.target_id,
      body.action,
    );
  }

  @Post('swipes/revert')
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  revertSwipe(
    @CurrentUser() user: AuthenticatedUser,
    @Body() body: RevertSwipeDto,
  ) {
    const effectiveUserId = body.user_id || user?.id || user?.uid;
    return this.discoveryService.revertSwipe(effectiveUserId);
  }
}
