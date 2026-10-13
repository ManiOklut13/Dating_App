import { Injectable, UnauthorizedException } from '@nestjs/common';
import { AuthenticatedUser } from './interfaces/authenticated-user.interface.js';
import { SignInResponseDto } from './dto/signin-response.dto.js';
import { CurrentUserResponseDto } from './dto/user-response.dto.js';

@Injectable()
export class AuthService {
  /**
   * Generates the verified sign-in response.
   * Only trusted claims verified from the Firebase Admin SDK token are returned.
   */
  signIn(user: AuthenticatedUser): SignInResponseDto {
    if (!user || !user.uid) {
      throw new UnauthorizedException('Authentication credentials could not be verified');
    }

    return {
      success: true,
      message: 'Sign in successful',
      user: {
        uid: user.uid,
        email: user.email,
      },
    };
  }

  /**
   * Returns current authenticated user information.
   */
  getCurrentUser(user: AuthenticatedUser): CurrentUserResponseDto {
    if (!user || !user.uid) {
      throw new UnauthorizedException('Authentication credentials could not be verified');
    }

    return {
      success: true,
      user: {
        uid: user.uid,
        email: user.email,
      },
    };
  }
}
