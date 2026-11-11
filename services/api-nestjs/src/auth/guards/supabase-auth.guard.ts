import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { SupabaseService, SupabaseTokenError } from '../../supabase/supabase.service.js';

@Injectable()
export class SupabaseAuthGuard implements CanActivate {
  constructor(private readonly supabaseService: SupabaseService) {}

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
      const verifiedUser = this.supabaseService.verifyAccessToken(token);
      request.user = {
        id: verifiedUser.id,
        email: verifiedUser.email,
        phone: verifiedUser.phone,
        role: verifiedUser.role,
        session_id: verifiedUser.session_id,
      };
      return true;
    } catch (error: any) {
      if (error instanceof SupabaseTokenError) {
        switch (error.code) {
          case 'TOKEN_EXPIRED':
            throw new UnauthorizedException('Supabase access token has expired');
          case 'INVALID_ROLE':
            throw new UnauthorizedException('Token is not an authenticated user token');
          case 'SUPABASE_NOT_CONFIGURED':
            throw new UnauthorizedException('Authentication is not configured on the server');
          default:
            throw new UnauthorizedException('Invalid Supabase access token');
        }
      }
      throw new UnauthorizedException('Invalid or unverified Supabase access token');
    }
  }
}
