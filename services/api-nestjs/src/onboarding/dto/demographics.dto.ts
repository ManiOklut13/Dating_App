/**
 * YoUnMe Dating App — Demographics Step DTO
 * Validates step 1 demographics during user onboarding.
 */

import {
  IsArray,
  IsIn,
  IsISO8601,
  IsNotEmpty,
  IsOptional,
  IsString,
  MaxLength,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class DemographicsDto {
  @ApiProperty({ example: 'Aditya', description: 'User nickname (public handle)' })
  @IsNotEmpty({ message: 'nickname is required' })
  @IsString()
  @MaxLength(40, { message: 'nickname cannot exceed 40 characters' })
  nickname: string;

  @ApiPropertyOptional({ example: 'Aditya Mehta', description: 'Legal / full first name' })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  first_name?: string;

  @ApiPropertyOptional({ example: 'Aditya Mehta', description: 'Alternative name field' })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  name?: string;

  @ApiProperty({
    example: '2000-05-14',
    description: 'Date of birth in ISO-8601 format (YYYY-MM-DD). Must be >18 years old.',
  })
  @IsNotEmpty({ message: 'date_of_birth is required' })
  @IsISO8601({}, { message: 'date_of_birth must be a valid ISO-8601 date (YYYY-MM-DD)' })
  date_of_birth: string;

  @ApiPropertyOptional({ example: '2000-05-14', description: 'Alias for date_of_birth' })
  @IsOptional()
  @IsISO8601()
  dob?: string;

  @ApiProperty({
    example: 'male',
    enum: ['male', 'female', 'non_binary', 'other'],
    description: 'User gender identity',
  })
  @IsNotEmpty({ message: 'gender is required' })
  @IsIn(['male', 'female', 'non_binary', 'other'], {
    message: 'gender must be male, female, non_binary, or other',
  })
  gender: string;

  @ApiProperty({
    example: ['straight'],
    type: [String],
    description: 'User sexual orientations',
  })
  @IsArray({ message: 'sexual_orientations must be an array of strings' })
  @IsString({ each: true })
  sexual_orientations: string[];

  @ApiPropertyOptional({
    example: 'straight',
    description: 'Alias for single orientation',
  })
  @IsOptional()
  orientation?: string | string[];

  @ApiProperty({
    example: ['coffee', 'techno', 'running'],
    type: [String],
    description: 'User interests and lifestyle tags',
  })
  @IsArray({ message: 'interests must be an array of strings' })
  @IsString({ each: true })
  interests: string[];
}

