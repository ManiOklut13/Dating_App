import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { FirebaseService } from '../../firebase/firebase.service.js';

@Injectable()
export class FirebaseAuthGuard implements CanActivate {
  constructor(private readonly firebaseService: FirebaseService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const authHeader = request.headers.authorization;

    if (!authHeader) {
      throw new UnauthorizedException('Authorization header is missing');
    }

    if (
      typeof authHeader !== 'string' ||
      !authHeader.startsWith('Bearer ') ||
      !authHeader.substring(7).trim()
    ) {
      throw new UnauthorizedException('Malformed authorization header. Expected "Bearer <token>"');
    }

    const token = authHeader.substring(7).trim();

    try {
      const verifiedUser = await this.firebaseService.verifyIdToken(token);
      request.user = {
        uid: verifiedUser.uid,
        email: verifiedUser.email,
        email_verified: verifiedUser.email_verified,
      };
      return true;
    } catch (error: any) {
      if (error.message === 'TOKEN_EXPIRED') {
        throw new UnauthorizedException('Firebase ID token has expired');
      }
      if (error.message === 'TOKEN_INVALID') {
        throw new UnauthorizedException('Invalid Firebase ID token');
      }
      throw new UnauthorizedException('Invalid or unverified Firebase ID token');
    }
  }
}
