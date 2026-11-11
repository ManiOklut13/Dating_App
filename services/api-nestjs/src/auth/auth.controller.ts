import {
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Post,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { AuthService } from './auth.service.js';
import { SupabaseAuthGuard } from './guards/supabase-auth.guard.js';
import { CurrentUser } from './decorators/current-user.decorator.js';
import { AuthenticatedUser } from './interfaces/authenticated-user.interface.js';
import { SignInResponseDto } from './dto/signin-response.dto.js';
import { CurrentUserResponseDto } from './dto/user-response.dto.js';

@ApiTags('Auth')
@ApiBearerAuth('supabase-auth')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  /**
   * POST /v1/auth/signin
   * Verifies a Supabase access token and returns the verified user identity.
   */
  @Post('signin')
  @HttpCode(HttpStatus.OK)
  @UseGuards(SupabaseAuthGuard)
  @ApiOperation({
    summary: 'Sign In via Supabase Access Token',
    description:
      'Verifies the client-provided Supabase access token (HS256, signed with SUPABASE_JWT_SECRET). Only tokens with role=authenticated are accepted — the anon and service_role API keys are rejected. Returns the verified user id and email.',
  })
  @ApiResponse({
    status: 200,
    description: 'Sign in successful',
    type: SignInResponseDto,
    schema: {
      example: {
        success: true,
        message: 'Sign in successful',
        user: {
          id: '11111111-1111-1111-1111-111111111111',
          email: 'user@example.com',
        },
      },
    },
  })
  @ApiResponse({
    status: 401,
    description: 'Unauthorized - Missing, malformed, invalid, or expired token',
    schema: {
      example: {
        statusCode: 401,
        message: 'Supabase access token has expired',
        error: 'Unauthorized',
      },
    },
  })
  async signIn(@CurrentUser() user: AuthenticatedUser): Promise<SignInResponseDto> {
    return this.authService.signIn(user);
  }

  /**
   * GET /v1/auth/me
   * Returns current authenticated user information from the verified token.
   */
  @Get('me')
  @HttpCode(HttpStatus.OK)
  @UseGuards(SupabaseAuthGuard)
  @ApiOperation({
    summary: 'Get Current Authenticated User',
    description:
      'Returns the verified identity information of the currently authenticated user.',
  })
  @ApiResponse({
    status: 200,
    description: 'Authenticated user information',
    type: CurrentUserResponseDto,
    schema: {
      example: {
        success: true,
        user: {
          id: '11111111-1111-1111-1111-111111111111',
          email: 'user@example.com',
        },
      },
    },
  })
  @ApiResponse({
    status: 401,
    description: 'Unauthorized - Missing or invalid token',
    schema: {
      example: {
        statusCode: 401,
        message: 'Authorization header is missing',
        error: 'Unauthorized',
      },
    },
  })
  async getCurrentUser(@CurrentUser() user: AuthenticatedUser): Promise<CurrentUserResponseDto> {
    return this.authService.getCurrentUser(user);
  }
}
