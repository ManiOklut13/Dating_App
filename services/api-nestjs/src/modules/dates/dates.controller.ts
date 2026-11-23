/**
 * YoUnMe Dating App — Dates Controller
 * Date planning, scheduling, approval, and financial endpoints.
 * Protected by SupabaseAuthGuard.
 */

import {
  Controller,
  Get,
  Post,
  Put,
  Body,
  Param,
  Query,
  UseGuards,
  UsePipes,
  ValidationPipe,
} from '@nestjs/common';
import { DatesService } from './dates.service.js';
import { PlanDateDto } from './dto/plan-date.dto.js';
import { SupabaseAuthGuard } from '../../common/guards/supabase-auth.guard.js';
import { CurrentUser } from '../../auth/decorators/current-user.decorator.js';
import { AuthenticatedUser } from '../../auth/interfaces/authenticated-user.interface.js';

@Controller('v1')
@UseGuards(SupabaseAuthGuard)
export class DatesController {
  constructor(private readonly datesService: DatesService) {}

  @Post('dates/plan')
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  planDate(
    @CurrentUser() user: AuthenticatedUser,
    @Body() body: PlanDateDto,
  ) {
    const effectiveProposerId = body.proposer_user_id || user?.id || user?.uid;
    return this.datesService.planDate({
      ...body,
      proposer_user_id: effectiveProposerId,
    });
  }

  @Get('dates/:dateId')
  getDateDetails(
    @CurrentUser() user: AuthenticatedUser,
    @Param('dateId') dateId: string,
  ) {
    const effectiveUserId = user?.id || user?.uid || '';
    return this.datesService.getDateDetails(dateId, effectiveUserId);
  }

  @Put('dates/:dateId')
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  editDate(
    @CurrentUser() user: AuthenticatedUser,
    @Param('dateId') dateId: string,
    @Body() body: PlanDateDto,
  ) {
    const effectiveUserId = user?.id || user?.uid || '';
    return this.datesService.editDate(dateId, effectiveUserId, body);
  }

  @Post('dates/:dateId/approve')
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  approveDate(
    @CurrentUser() user: AuthenticatedUser,
    @Param('dateId') dateId: string,
  ) {
    const effectiveUserId = user?.id || user?.uid || '';
    return this.datesService.approveDate(dateId, effectiveUserId);
  }

  @Post('dates/:dateId/reject')
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  rejectDate(
    @CurrentUser() user: AuthenticatedUser,
    @Param('dateId') dateId: string,
  ) {
    const effectiveUserId = user?.id || user?.uid || '';
    return this.datesService.rejectDate(dateId, effectiveUserId);
  }

  @Post('dates/:dateId/cancel')
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  cancelDate(
    @CurrentUser() user: AuthenticatedUser,
    @Param('dateId') dateId: string,
  ) {
    const effectiveUserId = user?.id || user?.uid || '';
    return this.datesService.cancelDate(dateId, effectiveUserId);
  }
}