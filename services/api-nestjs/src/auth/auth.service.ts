import { Injectable, UnauthorizedException } from '@nestjs/common';
import { AuthenticatedUser } from './interfaces/authenticated-user.interface.js';
import { SignInResponseDto } from './dto/signin-response.dto.js';
import { CurrentUserResponseDto } from './dto/user-response.dto.js';

@Injectable()
export class AuthService {
  /**
   * Generates the verified sign-in response.
   * Only trusted claims verified from the Supabase access token are returned.
   */
  signIn(user: AuthenticatedUser): SignInResponseDto {
    if (!user || !user.id) {
      throw new UnauthorizedException('Authentication credentials could not be verified');
    }

    return {
      success: true,
      message: 'Sign in successful',
      user: {
        id: user.id,
        email: user.email,
        phone: user.phone,
      },
    };
  }

  /**
   * Returns current authenticated user information.
   */
  getCurrentUser(user: AuthenticatedUser): CurrentUserResponseDto {
    if (!user || !user.id) {
      throw new UnauthorizedException('Authentication credentials could not be verified');
    }

    return {
      success: true,
      user: {
        id: user.id,
        email: user.email,
        phone: user.phone,
      },
    };
  }
}
