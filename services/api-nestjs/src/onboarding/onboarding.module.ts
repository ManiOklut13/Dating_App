/**
 * YoUnMe Dating App — Onboarding & Verification NestJS Module
 * Packages controllers, services, and repository providers with dependency injection.
 */

import { Module } from '@nestjs/common';
import { OnboardingController } from './onboarding.controller.js';
import { OnboardingService } from './onboarding.service.js';
import {
  PostgresOnboardingRepository,
  ONBOARDING_REPOSITORY_TOKEN,
} from './onboarding.repository.js';

@Module({
  controllers: [OnboardingController],
  providers: [
    OnboardingService,
    {
      provide: ONBOARDING_REPOSITORY_TOKEN,
      useClass: PostgresOnboardingRepository,
    },
  ],
  exports: [OnboardingService, ONBOARDING_REPOSITORY_TOKEN],
})
export class OnboardingModule {}
