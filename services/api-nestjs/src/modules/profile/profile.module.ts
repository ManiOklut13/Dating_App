/**
 * YoUnMe Dating App — Profile Module
 * Assembles ProfileController, UsersController, and ProfileService.
 */

import { Module } from '@nestjs/common';
import { ProfileController } from './profile.controller.js';
import { UsersController } from './users.controller.js';
import { ProfileService } from './profile.service.js';
import { SupabaseModule } from '../../supabase/supabase.module.js';
import { DatabaseModule } from '../database/database.module.js';
import { WorkerModule } from '../worker/worker.module.js';
import { SupabaseAuthGuard } from '../../auth/guards/supabase-auth.guard.js';

@Module({
  imports: [SupabaseModule, DatabaseModule, WorkerModule],
  controllers: [ProfileController, UsersController],
  providers: [ProfileService, SupabaseAuthGuard],
  exports: [ProfileService],
})
export class ProfileModule {}

