/**
 * YoUnMe Dating App — Wallet Controller
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
import { WalletService } from './wallet.service.js';
import { SupabaseAuthGuard } from '../../common/guards/supabase-auth.guard.js';
import { CurrentUser } from '../../auth/decorators/current-user.decorator.js';
import { AuthenticatedUser } from '../../auth/interfaces/authenticated-user.interface.js';
import { PurchasePackageDto } from './dto/purchase-package.dto.js';
import { RequestPayoutDto } from './dto/request-payout.dto.js';

@Controller('v1/wallet')
@UseGuards(SupabaseAuthGuard)
export class WalletController {
  constructor(private readonly walletService: WalletService) {}

  @Get()
  getWallet(
    @CurrentUser() user: AuthenticatedUser,
    @Query('user_id') userId?: string,
  ) {
    const effectiveUserId = userId || user?.id || user?.uid;
    return this.walletService.getWallet(effectiveUserId);
  }

  @Post('purchase')
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  purchasePackage(
    @CurrentUser() user: AuthenticatedUser,
    @Body() body: PurchasePackageDto,
  ) {
    const effectiveUserId = body.user_id || user?.id || user?.uid;
    const normalised = {
      ...body,
      user_id: effectiveUserId,
      package_id: body.package_id || body.pack_id,
    };
    return this.walletService.purchasePackage(normalised);
  }

  @Post('payout')
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  requestPayout(
    @CurrentUser() user: AuthenticatedUser,
    @Body() body: RequestPayoutDto,
  ) {
    const effectiveUserId = body.user_id || user?.id || user?.uid;
    return this.walletService.requestPayout({
      ...body,
      user_id: effectiveUserId,
    });
  }
}
