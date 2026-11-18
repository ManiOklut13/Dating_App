import {
  Controller,
  Get,
  Post,
  Body,
  HttpCode,
  HttpStatus,
  UseGuards,
  ValidationPipe,
  UsePipes,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { AuthService } from './auth.service.js';
import { SupabaseAuthGuard, OptionalAuth } from './guards/supabase-auth.guard.js';
import { CurrentUser } from './decorators/current-user.decorator.js';
import { AuthenticatedUser } from './interfaces/authenticated-user.interface.js';
import { SignInResponseDto } from './dto/signin-response.dto.js';
import { CurrentUserResponseDto } from './dto/user-response.dto.js';
import { SignInDto } from './dto/signin.dto.js';
import { SendOtpDto } from './dto/send-otp.dto.js';
import { VerifyOtpDto } from './dto/verify-otp.dto.js';
import { OAuthGoogleDto } from './dto/oauth-google.dto.js';
import { OAuthAppleDto } from './dto/oauth-apple.dto.js';
import { ForgotPasswordDto } from './dto/forgot-password.dto.js';
import { ResetPasswordDto } from './dto/reset-password.dto.js';

@ApiTags('Auth')
@Controller('v1/auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  /**
   * POST /v1/auth/signin
   * Validates email/password and returns a Supabase JWT session,
   * or verifies an incoming Supabase Bearer token for SSO session hydration.
   */
  @Post('signin')
  @HttpCode(HttpStatus.OK)
  @UseGuards(SupabaseAuthGuard)
  @OptionalAuth()
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  @ApiOperation({
    summary: 'Sign In via Email/Password or Supabase Auth Token',
    description:
      'Validates email/password credentials and provisions a Supabase JWT session, or exchanges an existing Bearer token.',
  })
  @ApiResponse({
    status: 200,
    description: 'Sign in successful',
    type: SignInResponseDto,
  })
  @ApiResponse({
    status: 401,
    description: 'Unauthorized - Invalid credentials or expired token',
  })
  async signIn(
    @CurrentUser() user?: AuthenticatedUser,
    @Body() dto?: SignInDto,
  ): Promise<SignInResponseDto> {
    if (dto && (dto.email || dto.password)) {
      return this.authService.signIn(user, dto);
    }
    return this.authService.signIn(user);
  }

  /**
   * POST /v1/auth/otp/send
   * Accepts { type: 'email' | 'phone', identifier } and triggers Supabase/Twilio OTP dispatch.
   */
  @Post('otp/send')
  @HttpCode(HttpStatus.OK)
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  @ApiOperation({
    summary: 'Dispatch One-Time Password (OTP)',
    description:
      'Sends an OTP to the given email address or phone number via Supabase Auth / Twilio.',
  })
  @ApiResponse({
    status: 200,
    description: 'OTP dispatched successfully',
  })
  async sendOtp(@Body() dto: SendOtpDto) {
    return this.authService.sendOtp(dto);
  }

  /**
   * POST /v1/auth/otp/verify
   * Validates the OTP token and provisions the user session.
   */
  @Post('otp/verify')
  @HttpCode(HttpStatus.OK)
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  @ApiOperation({
    summary: 'Verify OTP Token',
    description:
      'Verifies the 6-digit OTP token and returns an active Supabase JWT session.',
  })
  @ApiResponse({
    status: 200,
    description: 'OTP verified successfully and session provisioned',
  })
  @ApiResponse({
    status: 401,
    description: 'Invalid or expired OTP token',
  })
  async verifyOtp(@Body() dto: VerifyOtpDto) {
    return this.authService.verifyOtp(dto);
  }

  /**
   * POST /v1/auth/google
   * Handles Google OAuth credential token exchanges.
   */
  @Post('google')
  @HttpCode(HttpStatus.OK)
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  @ApiOperation({
    summary: 'Exchange Google OAuth Credential Token',
    description:
      'Exchanges Google ID Token with Supabase Auth and provisions user account.',
  })
  @ApiResponse({
    status: 200,
    description: 'Google authentication successful',
  })
  async signInWithGoogle(@Body() dto: OAuthGoogleDto) {
    return this.authService.signInWithGoogle(dto);
  }

  /**
   * POST /v1/auth/apple
   * Handles Apple OAuth credential token exchanges.
   */
  @Post('apple')
  @HttpCode(HttpStatus.OK)
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  @ApiOperation({
    summary: 'Exchange Apple OAuth Credential Token',
    description:
      'Exchanges Apple ID Token with Supabase Auth and provisions user account.',
  })
  @ApiResponse({
    status: 200,
    description: 'Apple authentication successful',
  })
  async signInWithApple(@Body() dto: OAuthAppleDto) {
    return this.authService.signInWithApple(dto);
  }

  /**
   * POST /v1/auth/forgot-password
   * Sends a password reset OTP/link to email or phone number.
   */
  @Post('forgot-password')
  @HttpCode(HttpStatus.OK)
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  @ApiOperation({
    summary: 'Request Password Reset',
    description:
      'Dispatches password reset instructions/OTP to user email or phone.',
  })
  @ApiResponse({
    status: 200,
    description: 'Password reset link/OTP sent successfully',
  })
  async forgotPassword(@Body() dto: ForgotPasswordDto) {
    return this.authService.forgotPassword(dto);
  }

  /**
   * POST /v1/auth/reset-password
   * Validates reset token and updates the user's password securely.
   */
  @Post('reset-password')
  @HttpCode(HttpStatus.OK)
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  @ApiOperation({
    summary: 'Reset Password',
    description:
      'Validates reset token and securely updates user password.',
  })
  @ApiResponse({
    status: 200,
    description: 'Password updated successfully',
  })
  async resetPassword(@Body() dto: ResetPasswordDto) {
    return this.authService.resetPassword(dto);
  }

  /**
   * GET /v1/auth/me
   * Fetches the logged-in user's complete profile, wallet balance, and settings.
   */
  @Get('me')
  @HttpCode(HttpStatus.OK)
  @UseGuards(SupabaseAuthGuard)
  @ApiBearerAuth('supabase-auth')
  @ApiOperation({
    summary: 'Get Current Authenticated User Complete Profile',
    description:
      'Fetches the logged-in user complete profile, wallet balance, and settings from Supabase/PostgreSQL.',
  })
  @ApiResponse({
    status: 200,
    description: 'Complete user profile, wallet balance, and app settings',
    type: CurrentUserResponseDto,
  })
  @ApiResponse({
    status: 401,
    description: 'Unauthorized - Missing or invalid token',
  })
  async getCurrentUser(@CurrentUser() user: AuthenticatedUser): Promise<CurrentUserResponseDto> {
    return this.authService.getCurrentUser(user);
  }
}
