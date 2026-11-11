/**
 * YoUnMe Dating App — Onboarding Wizard Data Transfer Objects
 * Uses class-validator and class-transformer for strong runtime payload validation.
 */

// Defensive imports: works in standard NestJS environments with class-validator
import {
  IsString,
  IsOptional,
  IsNumber,
  IsBoolean,
  IsArray,
  ArrayMinSize,
  ArrayMaxSize,
  MinLength,
  MaxLength,
  Min,
  Max,
  IsIn,
  IsDateString,
} from 'class-validator';
import { Transform, Type } from 'class-transformer';

/**
 * Canonical wizard step identifiers accepted by POST /v1/onboarding/wizard.
 * Clients may address a step either by its 1-based index or by its key.
 */
export const WIZARD_STEP_KEYS = [
  'basic_info',
  'date_of_birth',
  'gender',
  'bio',
  'photos',
  'liveness',
  'avatar',
  'languages',
] as const;

export type WizardStepKey = (typeof WIZARD_STEP_KEYS)[number];
export type WizardStep = number | WizardStepKey;

const WIZARD_STEP_VALUES: (number | WizardStepKey)[] = [
  1,
  2,
  3,
  4,
  5,
  6,
  7,
  8,
  ...WIZARD_STEP_KEYS,
];

/**
 * Normalizes the legacy hyphenated gender alias onto the schema value.
 */
const GENDER_ALIASES: Record<string, string> = {
  'non-binary': 'non_binary',
};

export class OnboardingWizardDto {
  @IsOptional()
  @IsString()
  user_id?: string;

  @IsOptional()
  @Transform(({ value }) => {
    if (typeof value === 'string') {
      const trimmed = value.trim();
      return /^\d+$/.test(trimmed) ? Number(trimmed) : trimmed;
    }
    return value;
  })
  @IsIn(WIZARD_STEP_VALUES as unknown as (number | string)[])
  step?: WizardStep;

  @IsOptional()
  @IsString()
  @MinLength(2, { message: 'Nickname must be at least 2 characters long' })
  @MaxLength(50, { message: 'Nickname cannot exceed 50 characters' })
  nickname?: string;

  @IsOptional()
  @IsDateString({}, { message: 'dob must be an ISO 8601 date (YYYY-MM-DD)' })
  dob?: string;

  @IsOptional()
  @Transform(({ value }) => {
    if (typeof value === 'string') {
      return GENDER_ALIASES[value.trim().toLowerCase()] ?? value;
    }
    return value;
  })
  @IsIn(['male', 'female', 'non_binary', 'other'], {
    message: 'Gender must be one of: male, female, non_binary, other',
  })
  gender?: string;

  @IsOptional()
  @IsString()
  @MaxLength(500, { message: 'Bio cannot exceed 500 characters' })
  bio?: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  city?: string;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  languages?: string[];

  /**
   * Photo URLs uploaded to Cloud Storage.
   * Enforces minimum 3 photos when photo step is submitted.
   */
  @IsOptional()
  @IsArray({ message: 'photo_urls must be an array of image URLs' })
  @ArrayMinSize(3, { message: 'At least 3 profile photos are required for safety and discovery verification' })
  @ArrayMaxSize(7, { message: 'A maximum of 7 profile photos is allowed' })
  @IsString({ each: true })
  photo_urls?: string[];

  @IsOptional()
  @IsBoolean()
  liveness_verified?: boolean;

  @IsOptional()
  @IsString()
  avatar_object_key?: string;

  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(-90, { message: 'Latitude must be between -90 and 90' })
  @Max(90, { message: 'Latitude must be between -90 and 90' })
  lat?: number;

  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(-180, { message: 'Longitude must be between -180 and 180' })
  @Max(180, { message: 'Longitude must be between -180 and 180' })
  lng?: number;
}

export class OnboardingStatusParamDto {
  @IsString()
  userId!: string;
}
