/**
 * YoUnMe Dating App — Supabase Auth Guard
 * Authenticates incoming requests using supabase.auth.getUser(token).
 * Maps Supabase identity to app_users.authentication_uid and app_users.id (PostgreSQL UUID).
 */

import {
  Injectable,
  CanActivate,
  ExecutionContext,
  UnauthorizedException,
  Logger,
  Optional,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as crypto from 'crypto';
import { SupabaseService } from '../../supabase/supabase.service.js';
import { DatabaseService } from '../../modules/database/database.service.js';
import { AuthenticatedUser } from '../../auth/interfaces/authenticated-user.interface.js';

@Injectable()
export class SupabaseAuthGuard implements CanActivate {
  private readonly logger = new Logger(SupabaseAuthGuard.name);

  constructor(
    private readonly supabaseService: SupabaseService,
    private readonly configService: ConfigService,
    @Optional() private readonly databaseService?: DatabaseService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const authHeader = request.headers?.authorization;

    if (!authHeader) {
      throw new UnauthorizedException('Authorization header is missing');
    }

    if (
      typeof authHeader !== 'string' ||
      !authHeader.startsWith('Bearer ') ||
      !authHeader.substring(7).trim()
    ) {
      throw new UnauthorizedException(
        'Malformed authorization header. Expected "Bearer <token>"',
      );
    }

    const token = authHeader.substring(7).trim();

    // 1. Primary: Verify token via Supabase Auth API
    let supabaseUser = await this.supabaseService.getUser(token);

    // 2. Secondary fallback: Stateless JWT verification (for offline testing or local development)
    if (!supabaseUser) {
      supabaseUser = this.verifyTokenStateless(token);
    }

    if (!supabaseUser || !supabaseUser.id) {
      throw new UnauthorizedException(
        'Invalid, expired, or unauthenticated Supabase token',
      );
    }

    const authUid = supabaseUser.id;
    let internalId = authUid;

    // 3. Match Supabase Auth UID to app_users.id PostgreSQL entity relation
    if (this.databaseService?.isConnected) {
      try {
        const res = await this.databaseService.query(
          'SELECT id, authentication_uid, email FROM app_users WHERE authentication_uid = $1 LIMIT 1',
          [authUid],
        );
        if (res.rows && res.rows.length > 0) {
          internalId = res.rows[0].id;
        }
      } catch (dbErr: any) {
        this.logger.debug(`Supabase user app_users lookup: ${dbErr.message}`);
      }
    }

    const authenticatedUser: AuthenticatedUser = {
      id: internalId,
      authentication_uid: authUid,
      uid: internalId,
      email: supabaseUser.email,
      email_verified:
        !!(supabaseUser as any).email_confirmed_at ||
        !!(supabaseUser as any).confirmed_at ||
        false,
      role: (supabaseUser as any).role || 'authenticated',
      aud: (supabaseUser as any).aud || 'authenticated',
      app_metadata: (supabaseUser as any).app_metadata || {},
      user_metadata: (supabaseUser as any).user_metadata || {},
    };

    request.user = authenticatedUser;
    return true;
  }

  /**
   * Stateless JWT verification supporting HS256 secret or local dev decoding.
   */
  private verifyTokenStateless(token: string): any {
    // Development convenience token
    if (
      (process.env.NODE_ENV === 'test' || process.env.NODE_ENV === 'development') &&
      (token === 'mock-valid-token' || token === 'mock-partner-token')
    ) {
      const isPartner = token === 'mock-partner-token';
      return {
        id: isPartner
          ? '22222222-2222-2222-2222-222222222222'
          : '11111111-1111-1111-1111-111111111111',
        email: isPartner ? 'partner@younme.app' : 'demo@younme.app',
        role: 'authenticated',
        aud: 'authenticated',
      };
    }

    const parts = token.split('.');
    if (parts.length !== 3) {
      return null;
    }

    const [headerB64, payloadB64, signatureB64] = parts;

    let header: any;
    let payload: any;
    try {
      header = JSON.parse(Buffer.from(headerB64, 'base64url').toString('utf8'));
      payload = JSON.parse(Buffer.from(payloadB64, 'base64url').toString('utf8'));
    } catch {
      return null;
    }

    if (payload.exp && typeof payload.exp === 'number') {
      const currentEpoch = Math.floor(Date.now() / 1000);
      if (currentEpoch > payload.exp) {
        throw new UnauthorizedException('Supabase authentication token has expired');
      }
    }

    const jwtSecret =
      this.configService.get<string>('SUPABASE_JWT_SECRET') ||
      this.configService.get<string>('JWT_SECRET');

    if (jwtSecret && header.alg === 'HS256') {
      const expectedSig = crypto
        .createHmac('sha256', jwtSecret)
        .update(`${headerB64}.${payloadB64}`)
        .digest('base64url');

      if (signatureB64 !== expectedSig) {
        throw new UnauthorizedException('Supabase JWT signature verification failed');
      }
    }

    if (!payload.sub) {
      return null;
    }

    return {
      id: payload.sub,
      email: payload.email,
      role: payload.role,
      aud: payload.aud,
      app_metadata: payload.app_metadata,
      user_metadata: payload.user_metadata,
    };
  }
}
