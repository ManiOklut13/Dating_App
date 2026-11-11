/**
 * YoUnMe Dating App — Global Supabase NestJS Module
 * Provides SupabaseService across all NestJS modules and guards.
 */

import { Global, Module } from '@nestjs/common';
import { SupabaseService } from './supabase.service.js';

@Global()
@Module({
  providers: [SupabaseService],
  exports: [SupabaseService],
})
export class SupabaseModule {}
