/**
 * YoUnMe Dating App — Users Controller
 * Exposes user discovery and public profile viewing with strict visibility masking.
 */

import {
  Controller,
  Get,
  Param,
  HttpCode,
  HttpStatus,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiParam,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { ProfileService } from './profile.service.js';
import { SupabaseAuthGuard } from '../../auth/guards/supabase-auth.guard.js';
import { CurrentUser } from '../../auth/decorators/current-user.decorator.js';
import { AuthenticatedUser } from '../../auth/interfaces/authenticated-user.interface.js';

@ApiTags('Users')
@ApiBearerAuth('supabase-auth')
@Controller('v1/users')
@UseGuards(SupabaseAuthGuard)
export class UsersController {
  constructor(private readonly profileService: ProfileService) {}

  /**
   * GET /v1/users/:targetUserId
   * Fetches another user's public profile with strict visibility masking (respecting matches/blocks).
   */
  @Get(':targetUserId')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Get Public User Profile',
    description:
      'Fetches another user public profile with strict visibility masking (respecting matches, blocks, and privacy settings).',
  })
  @ApiParam({
    name: 'targetUserId',
    description: 'UUID of the user profile to fetch',
    example: '22222222-2222-2222-2222-222222222222',
  })
  @ApiResponse({
    status: 200,
    description: 'Public profile returned with visibility rules applied',
  })
  @ApiResponse({
    status: 403,
    description: 'Forbidden - User is blocked or unavailable',
  })
  @ApiResponse({
    status: 404,
    description: 'Not Found - User not found or profile is hidden',
  })
  async getPublicUserProfile(
    @CurrentUser() user: AuthenticatedUser,
    @Param('targetUserId') targetUserId: string,
  ) {
    const requesterId = user?.id || user?.uid;
    return this.profileService.getPublicUserProfile(requesterId, targetUserId);
  }
}

