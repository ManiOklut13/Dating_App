/**
 * YoUnMe Dating App — Home Controller
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
import { HomeService } from './home.service.js';
import { SupabaseAuthGuard } from '../../common/guards/supabase-auth.guard.js';
import { CurrentUser } from '../../auth/decorators/current-user.decorator.js';
import { AuthenticatedUser } from '../../auth/interfaces/authenticated-user.interface.js';
import { SpinWheelDto } from './dto/spin-wheel.dto.js';

@Controller('v1/home')
@UseGuards(SupabaseAuthGuard)
export class HomeController {
  constructor(private readonly homeService: HomeService) {}

  @Get('feed')
  getFeed(
    @CurrentUser() user: AuthenticatedUser,
    @Query('user_id') userId?: string,
  ) {
    const effectiveUserId = userId || user?.id || user?.uid;
    return this.homeService.getFeed(effectiveUserId);
  }

  @Post('spin-wheel')
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  spinWheel(
    @CurrentUser() user: AuthenticatedUser,
    @Body() body: SpinWheelDto,
  ) {
    const effectiveUserId = body.user_id || user?.id || user?.uid;
    return this.homeService.spinWheel(effectiveUserId);
  }
}
