/**
 * YoUnMe Dating App — Root Application Module
 * Assembles infrastructure and domain feature modules under a single NestJS container.
 */

import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';

import { AppController } from './app.controller.js';
import { SupabaseModule } from './supabase/supabase.module.js';

// Infrastructure Modules
import { DatabaseModule } from './modules/database/database.module.js';
import { RedisModule } from './modules/redis/redis.module.js';
import { HealthController } from './health.controller.js';

// Domain Feature Modules
import { AuthModule } from './auth/auth.module.js';
import { OnboardingModule } from './onboarding/onboarding.module.js';
import { DiscoveryModule } from './modules/discovery/discovery.module.js';
import { ChatModule } from './modules/chat/chat.module.js';
import { CallsModule } from './modules/calls/calls.module.js';
import { WalletModule } from './modules/wallet/wallet.module.js';
import { HomeModule } from './modules/home/home.module.js';
import { WorkerModule } from './modules/worker/worker.module.js';
import { MeetupModule } from './modules/meetup/meetup.module.js';

@Module({
  imports: [
    // Configuration
    ConfigModule.forRoot({ isGlobal: true }),

    // Infrastructure Modules
    DatabaseModule,
    RedisModule,
    SupabaseModule,

    // Domain Feature Modules
    AuthModule,
    OnboardingModule,
    DiscoveryModule,
    ChatModule,
    CallsModule,
    WalletModule,
    HomeModule,
    WorkerModule,
    MeetupModule,
  ],
  controllers: [AppController, HealthController],
})
export class AppModule {}
