/**
 * YoUnMe Dating App — Profile Controller
 * Exposes RESTful endpoints for profile updates, multipart photo uploads,
 * and biometric/Bitmoji verification.
 */

import {
  Controller,
  Put,
  Post,
  Body,
  UploadedFiles,
  UseInterceptors,
  UseGuards,
  HttpCode,
  HttpStatus,
  ValidationPipe,
  UsePipes,
  BadRequestException,
} from '@nestjs/common';
import { FilesInterceptor } from '@nestjs/platform-express';
import {
  ApiBearerAuth,
  ApiConsumes,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { ProfileService, UploadedFileItem } from './profile.service.js';
import { UpdateProfileDto } from './dto/update-profile.dto.js';
import { VerifyBiometricsDto } from './dto/verify-biometrics.dto.js';
import { SupabaseAuthGuard } from '../../auth/guards/supabase-auth.guard.js';
import { CurrentUser } from '../../auth/decorators/current-user.decorator.js';
import { AuthenticatedUser } from '../../auth/interfaces/authenticated-user.interface.js';

@ApiTags('Profile')
@ApiBearerAuth('supabase-auth')
@Controller('v1/profile')
@UseGuards(SupabaseAuthGuard)
export class ProfileController {
  constructor(private readonly profileService: ProfileService) {}

  /**
   * PUT /v1/profile/me
   * Updates personal bio, job, education, preferences, and discovery settings.
   */
  @Put('me')
  @HttpCode(HttpStatus.OK)
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  @ApiOperation({
    summary: 'Update Logged-in User Profile',
    description: 'Updates personal bio, job/profession, and preferences in Supabase PostgreSQL.',
  })
  @ApiResponse({
    status: 200,
    description: 'Profile updated successfully',
  })
  async updateProfile(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: UpdateProfileDto,
  ) {
    const userId = user?.id || user?.uid;
    return this.profileService.updateProfile(userId, dto);
  }

  /**
   * POST /v1/profile/photos
   * Handles multipart image uploads (2-6 images), saves to storage, and dispatches job
   * to worker-bullmq for SafeSearch and face-embedding analysis.
   */
  @Post('photos')
  @HttpCode(HttpStatus.OK)
  @UseInterceptors(
    FilesInterceptor('photos', 6, {
      limits: {
        fileSize: 10 * 1024 * 1024, // 10MB limit per image
        files: 6,
      },
    }),
  )
  @ApiConsumes('multipart/form-data')
  @ApiOperation({
    summary: 'Upload User Profile Photos',
    description:
      'Uploads 2 to 6 multipart image files to Supabase Storage and dispatches vision moderation jobs to worker-bullmq.',
  })
  @ApiResponse({
    status: 200,
    description: 'Photos uploaded and queued for vision scan',
  })
  @ApiResponse({
    status: 400,
    description: 'Must provide between 2 and 6 image files',
  })
  async uploadPhotos(
    @CurrentUser() user: AuthenticatedUser,
    @UploadedFiles() files: UploadedFileItem[],
  ) {
    const userId = user?.id || user?.uid;
    if (!files || files.length < 2 || files.length > 6) {
      throw new BadRequestException('Photos upload requires between 2 and 6 images');
    }
    return this.profileService.uploadPhotos(userId, files);
  }

  /**
   * POST /v1/profile/verify-biometrics
   * Handles voice/liveness verification flags and Bitmoji generation data.
   */
  @Post('verify-biometrics')
  @HttpCode(HttpStatus.OK)
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  @ApiOperation({
    summary: 'Verify Biometrics & Bitmoji Generation Data',
    description:
      'Records voice and facial liveness verification status, updates Bitmoji avatar, and awards verified badge if eligible.',
  })
  @ApiResponse({
    status: 200,
    description: 'Biometrics and avatar verified successfully',
  })
  async verifyBiometrics(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: VerifyBiometricsDto,
  ) {
    const userId = user?.id || user?.uid;
    return this.profileService.verifyBiometrics(userId, dto);
  }
}

