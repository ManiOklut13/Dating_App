/**
 * YoUnMe Dating App — Onboarding & Verification Controller
 * Exposes RESTful endpoints for multi-step onboarding wizard and verification status.
 * Protected by SupabaseAuthGuard.
 */

import {
  Controller,
  Post,
  Get,
  Put,
  Body,
  Param,
  HttpCode,
  HttpStatus,
  ValidationPipe,
  UsePipes,
  UseGuards,
} from '@nestjs/common';
import { OnboardingService } from './onboarding.service.js';
import { OnboardingWizardDto } from './dto/onboarding-wizard.dto.js';
import {
  IWizardResponse,
  IOnboardingStatusResponse,
} from './interfaces/onboarding.interface.js';
import { SupabaseAuthGuard } from '../common/guards/supabase-auth.guard.js';
import { CurrentUser } from '../auth/decorators/current-user.decorator.js';
import { AuthenticatedUser } from '../auth/interfaces/authenticated-user.interface.js';

@Controller('v1/onboarding')
@UseGuards(SupabaseAuthGuard)
export class OnboardingController {
  constructor(private readonly onboardingService: OnboardingService) {}

  /**
   * POST /v1/onboarding/wizard
   * Incrementally saves onboarding steps, recalculates progress, and awards Blue Tick at >=70% + liveness
   */
  @Post('wizard')
  @HttpCode(HttpStatus.OK)
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  public async submitWizard(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: OnboardingWizardDto,
  ): Promise<IWizardResponse> {
    if (!dto.user_id && (user?.id || user?.uid)) {
      dto.user_id = user.id || user.uid;
    }
    return this.onboardingService.saveWizardStep(dto);
  }

  /**
   * GET /v1/onboarding/status/:userId
   * Returns current profile completion percentage, verification state, and actionable missing items
   */
  @Get('status/:userId')
  @HttpCode(HttpStatus.OK)
  public async getStatus(
    @CurrentUser() user: AuthenticatedUser,
    @Param('userId') userId: string,
  ): Promise<IOnboardingStatusResponse> {
    const effectiveUserId =
      userId && userId !== ':userId' && userId !== 'me'
        ? userId
        : user?.id || user?.uid || userId;
    return this.onboardingService.getStatus(effectiveUserId);
  }

  /**
   * PUT /v1/onboarding/profile/:userId
   * Idempotent update of profile attributes in PostgreSQL
   */
  @Put('profile/:userId')
  @HttpCode(HttpStatus.OK)
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  public async updateProfile(
    @CurrentUser() user: AuthenticatedUser,
    @Param('userId') userId: string,
    @Body() dto: OnboardingWizardDto,
  ): Promise<IWizardResponse> {
    const effectiveUserId =
      userId && userId !== ':userId' && userId !== 'me'
        ? userId
        : user?.id || user?.uid || userId;
    dto.user_id = effectiveUserId;
    return this.onboardingService.saveWizardStep(dto);
  }
}
