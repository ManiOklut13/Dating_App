import { Module } from '@nestjs/common';
import { ChatController } from './chat.controller.js';
import { ChatService } from './chat.service.js';
import { ContactGuardService } from './contact-guard.service.js';
import { MeetupModule } from '../meetup/meetup.module.js';

@Module({
  imports: [MeetupModule],
  controllers: [ChatController],
  providers: [ChatService, ContactGuardService],
  exports: [ChatService, MeetupModule],
})
export class ChatModule {}
