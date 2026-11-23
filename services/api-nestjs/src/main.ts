/**
 * YoUnMe Dating App — NestJS Application Bootstrap
 * Canonical entry point replacing the legacy raw Express server.
 */

import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { ValidationPipe, Logger } from '@nestjs/common';
import type { NestExpressApplication } from '@nestjs/platform-express';
import { existsSync } from 'fs';
import { join } from 'path';
import { AppModule } from './app.module.js';

async function bootstrap() {
  const logger = new Logger('Bootstrap');
  const app = await NestFactory.create<NestExpressApplication>(AppModule);

  // Global middleware & security
  app.enableCors({ origin: '*' });

  // Global DTO validation pipe
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidNonWhitelisted: false,
    }),
  );

  // Public static assets (profile pictures, photos) — present only in local dev
  const clientPublicPath = join(process.cwd(), '..', '..', 'client', 'public');
  if (existsSync(clientPublicPath)) {
    app.useStaticAssets(clientPublicPath, { prefix: '/assets/' });
    app.useStaticAssets(clientPublicPath);
  }

  const port = process.env.PORT || 8080;
  await app.listen(port);

  logger.log(`=======================================================`);
  logger.log(`🚀 YoUnMe Unified NestJS Core API running on port ${port}`);
  logger.log(`📦 Architecture: Cloud Run Tri-Microservices (Stateless API)`);
  logger.log(`=======================================================`);
}

bootstrap();
