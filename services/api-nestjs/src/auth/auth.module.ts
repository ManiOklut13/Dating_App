/**
 * YoUnMe Dating App — Auth NestJS Module
 * Exposes sign-in and current-user endpoints backed by Supabase Auth verification.
 * SupabaseModule is global, so SupabaseService resolves without an explicit import.
 */

import { Module } from '@nestjs/common';
import { AuthController } from './auth.controller.js';
import { AuthService } from './auth.service.js';
import { SupabaseAuthGuard } from './guards/supabase-auth.guard.js';

@Module({
  controllers: [AuthController],
  providers: [AuthService, SupabaseAuthGuard],
  exports: [AuthService, SupabaseAuthGuard],
})
export class AuthModule {}
