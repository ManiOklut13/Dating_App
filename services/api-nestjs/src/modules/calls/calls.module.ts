import { Module } from '@nestjs/common';
import { CallsController } from './calls.controller.js';
import { CallsService } from './calls.service.js';
import { WalletModule } from '../wallet/wallet.module.js';

@Module({
  imports: [WalletModule],
  controllers: [CallsController],
  providers: [CallsService],
  exports: [CallsService],
})
export class CallsModule {}
