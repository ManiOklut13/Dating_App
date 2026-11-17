import { Module } from '@nestjs/common';
import { MeetupController } from './meetup.controller.js';
import { MeetupService } from './meetup.service.js';
import { WalletModule } from '../wallet/wallet.module.js';

@Module({
  imports: [WalletModule],
  controllers: [MeetupController],
  providers: [MeetupService],
  exports: [MeetupService],
})
export class MeetupModule {}
