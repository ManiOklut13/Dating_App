/**
 * YoUnMe Dating App — Verify Biometrics DTO
 * Handles voice verification audio, facial liveness check flags, and 3D Bitmoji generator payloads.
 */

import {
  IsBoolean,
  IsIn,
  IsNumber,
  IsOptional,
  IsString,
  Max,
  Min,
} from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class VerifyBiometricsDto {
  @ApiPropertyOptional({
    example: true,
    description: 'Voice verification audio sample processed',
  })
  @IsOptional()
  @IsBoolean()
  is_voice_verified?: boolean;

  @ApiPropertyOptional({
    example: true,
    description: 'Facial oval liveness detection passed',
  })
  @IsOptional()
  @IsBoolean()
  liveness_verified?: boolean;

  @ApiPropertyOptional({
    example: 'approved',
    enum: ['not_started', 'pending', 'approved', 'rejected', 'manual_review'],
  })
  @IsOptional()
  @IsIn(['not_started', 'pending', 'approved', 'rejected', 'manual_review'])
  verification_status?: string;

  @ApiPropertyOptional({
    example: 'avatar_custom_3d_bitmoji',
    description: 'Generated avatar object key',
  })
  @IsOptional()
  @IsString()
  avatar_object_key?: string;

  @ApiPropertyOptional({
    description: 'Bitmoji / 3D facial avatar generator parameters and config',
  })
  @IsOptional()
  bitmoji_data?: Record<string, any>;

  @ApiPropertyOptional({
    example: 'https://storage.younme.app/audio/voice-sample-123.m4a',
  })
  @IsOptional()
  @IsString()
  voice_sample_url?: string;

  @ApiPropertyOptional({
    example: 0.98,
    description: 'Confidence score (0.0 - 1.0) for biometric liveness',
  })
  @IsOptional()
  @IsNumber()
  @Min(0)
  @Max(1)
  liveness_score?: number;
}

