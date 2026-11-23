/**
 * YoUnMe Dating App — Update Profile DTO
 * Validates updates to user profile bio, profession, education, preferences, and settings.
 */

import {
  IsArray,
  IsBoolean,
  IsIn,
  IsInt,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
} from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class UpdateProfileDto {
  @ApiPropertyOptional({ example: 'Building cool things & exploring Mumbai ☕' })
  @IsOptional()
  @IsString()
  @MaxLength(500, { message: 'bio cannot exceed 500 characters' })
  bio?: string;

  @ApiPropertyOptional({ example: 'Software Architect' })
  @IsOptional()
  @IsString()
  @MaxLength(120, { message: 'profession cannot exceed 120 characters' })
  profession?: string;

  @ApiPropertyOptional({
    example: 'Software Architect',
    description: 'Alias for profession',
  })
  @IsOptional()
  @IsString()
  @MaxLength(120)
  job?: string;

  @ApiPropertyOptional({ example: 'B.Tech Computer Science' })
  @IsOptional()
  @IsString()
  @MaxLength(160)
  education?: string;

  @ApiPropertyOptional({ example: 'Mumbai' })
  @IsOptional()
  @IsString()
  @MaxLength(120)
  city?: string;

  @ApiPropertyOptional({ example: 'IN' })
  @IsOptional()
  @IsString()
  @MaxLength(2)
  country_code?: string;

  @ApiPropertyOptional({ example: ['tech', 'coffee', 'running'], type: [String] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  interests?: string[];

  @ApiPropertyOptional({ example: ['English', 'Hindi'], type: [String] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  languages?: string[];

  @ApiPropertyOptional({ example: ['relationship'], type: [String] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  looking_for?: string[];

  @ApiPropertyOptional({ example: ['straight'], type: [String] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  sexual_orientations?: string[];

  @ApiPropertyOptional({ example: 21 })
  @IsOptional()
  @IsInt()
  @Min(18)
  @Max(100)
  min_age?: number;

  @ApiPropertyOptional({ example: 35 })
  @IsOptional()
  @IsInt()
  @Min(18)
  @Max(100)
  max_age?: number;

  @ApiPropertyOptional({ example: 50 })
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(500)
  max_distance_km?: number;

  @ApiPropertyOptional({ example: 'everyone', enum: ['everyone', 'limited', 'hidden'] })
  @IsOptional()
  @IsIn(['everyone', 'limited', 'hidden'])
  profile_visibility?: 'everyone' | 'limited' | 'hidden';

  @ApiPropertyOptional({ example: 'everyone', enum: ['everyone', 'matches', 'nobody'] })
  @IsOptional()
  @IsIn(['everyone', 'matches', 'nobody'])
  who_can_message?: 'everyone' | 'matches' | 'nobody';

  @ApiPropertyOptional({ example: 'everyone', enum: ['everyone', 'matches', 'nobody'] })
  @IsOptional()
  @IsIn(['everyone', 'matches', 'nobody'])
  who_can_message_request?: 'everyone' | 'matches' | 'nobody';

  @ApiPropertyOptional({ example: true })
  @IsOptional()
  @IsBoolean()
  show_online_status?: boolean;

  @ApiPropertyOptional({ example: true })
  @IsOptional()
  @IsBoolean()
  read_receipts_status?: boolean;

  @ApiPropertyOptional({ example: 'en' })
  @IsOptional()
  @IsString()
  app_language?: string;

  @ApiPropertyOptional({ example: 'dark' })
  @IsOptional()
  @IsString()
  app_theme?: string;

  @ApiPropertyOptional({ example: true })
  @IsOptional()
  @IsBoolean()
  push_notifications_enabled?: boolean;

  @ApiPropertyOptional({ example: true })
  @IsOptional()
  @IsBoolean()
  email_notifications_enabled?: boolean;
}

