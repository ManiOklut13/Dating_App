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
import { FirebaseAuthGuard } from './guards/firebase-auth.guard.js';
import { CurrentUser } from './decorators/current-user.decorator.js';
import { AuthenticatedUser } from './interfaces/authenticated-user.interface.js';
import { SignInResponseDto } from './dto/signin-response.dto.js';
import { CurrentUserResponseDto } from './dto/user-response.dto.js';

@ApiTags('Auth')
@ApiBearerAuth('firebase-auth')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  /**
   * POST /v1/auth/signin
   * Verifies Firebase ID Token and returns verified user identity.
   */
  @Post('signin')
  @HttpCode(HttpStatus.OK)
  @UseGuards(FirebaseAuthGuard)
  @ApiOperation({
    summary: 'Sign In via Firebase ID Token',
    description:
      'Verifies the client-provided Firebase ID token via Firebase Admin SDK. Returns verified UID and email.',
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
          uid: 'verified-firebase-uid',
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
        message: 'Firebase ID token has expired',
        error: 'Unauthorized',
      },
    },
  })
  async signIn(@CurrentUser() user: AuthenticatedUser): Promise<SignInResponseDto> {
    return this.authService.signIn(user);
  }

  /**
   * GET /v1/auth/me
   * Returns current authenticated user information from verified token.
   */
  @Get('me')
  @HttpCode(HttpStatus.OK)
  @UseGuards(FirebaseAuthGuard)
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
          uid: 'verified-firebase-uid',
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
