import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as jwt from 'jsonwebtoken';
import { createClient, SupabaseClient } from '@supabase/supabase-js';

export interface VerifiedSupabaseUser {
  /** Supabase auth.users.id (UUID). Replaces the Firebase `uid`. */
  id: string;
  email?: string;
  phone?: string;
  role: string;
  session_id?: string;
}

export type SupabaseTokenErrorCode =
  | 'MISSING_TOKEN'
  | 'TOKEN_EXPIRED'
  | 'TOKEN_INVALID'
  | 'INVALID_ROLE'
  | 'SUPABASE_NOT_CONFIGURED';

/**
 * Typed failure so the guard can map codes to HTTP responses without
 * string-matching on messages or leaking internal stack traces.
 */
export class SupabaseTokenError extends Error {
  constructor(public readonly code: SupabaseTokenErrorCode) {
    super(code);
    this.name = 'SupabaseTokenError';
  }
}

/**
 * Supabase Auth replacement for the Firebase Admin SDK.
 *
 * Supabase (GoTrue) issues access tokens signed with HS256 using the
 * project's JWT secret. Verification is done locally — no network round trip
 * per request — which is the direct analogue of Firebase's local
 * `verifyIdToken`.
 */
@Injectable()
export class SupabaseService implements OnModuleInit {
  private readonly logger = new Logger(SupabaseService.name);

  private jwtSecret: string | null = null;
  private projectRef: string | null = null;
  private requiredRole = 'authenticated';
  private adminClient: SupabaseClient | null = null;

  constructor(private readonly configService: ConfigService) {}

  onModuleInit(): void {
    const secret = this.configService.get<string>('SUPABASE_JWT_SECRET');
    const url = this.configService.get<string>('SUPABASE_URL');
    const serviceRoleKey = this.configService.get<string>('SUPABASE_SERVICE_ROLE_KEY');

    this.projectRef = this.extractProjectRef(url);
    this.requiredRole = this.configService.get<string>('SUPABASE_REQUIRED_ROLE') || 'authenticated';

    if (secret && secret.trim().length > 0) {
      this.jwtSecret = secret.trim();
      this.logger.log(
        `Supabase access-token verifier initialized for project ${this.projectRef ?? 'unknown'}.`,
      );
    } else {
      this.logger.warn(
        'SUPABASE_JWT_SECRET is not set — every authenticated request will be rejected (401).',
      );
    }

    if (url && serviceRoleKey && serviceRoleKey.trim().length > 0) {
      try {
        this.adminClient = createClient(url, serviceRoleKey.trim(), {
          auth: { persistSession: false, autoRefreshToken: false },
        });
        this.logger.log('Supabase admin client initialized (service_role).');
      } catch (err) {
        this.logger.error(
          `Failed to initialize Supabase admin client: ${(err as Error).message}`,
        );
      }
    } else {
      this.logger.warn(
        'SUPABASE_SERVICE_ROLE_KEY is not set — admin operations (user management) are unavailable.',
      );
    }
  }

  private extractProjectRef(url?: string): string | null {
    if (!url) return null;
    const match = url.match(/https:\/\/([a-z0-9]+)\.supabase\.co/);
    return match ? match[1] : null;
  }

  /**
   * Verifies a Supabase access token and returns the authenticated identity.
   * Never logs raw tokens.
   */
  verifyAccessToken(accessToken: string): VerifiedSupabaseUser {
    if (!accessToken || typeof accessToken !== 'string' || accessToken.trim().length === 0) {
      throw new SupabaseTokenError('MISSING_TOKEN');
    }

    if (!this.jwtSecret) {
      throw new SupabaseTokenError('SUPABASE_NOT_CONFIGURED');
    }

    let payload: jwt.JwtPayload;
    try {
      payload = jwt.verify(accessToken.trim(), this.jwtSecret, {
        // Pin the algorithm: prevents "alg: none" and RS256/HS256 confusion.
        algorithms: ['HS256'],
      }) as jwt.JwtPayload;
    } catch (err) {
      if (err instanceof jwt.TokenExpiredError) {
        throw new SupabaseTokenError('TOKEN_EXPIRED');
      }
      throw new SupabaseTokenError('TOKEN_INVALID');
    }

    const role = typeof payload.role === 'string' ? payload.role : '';

    // CRITICAL SECURITY CONTROL.
    // The `anon` and `service_role` API keys are HS256 JWTs signed with the
    // SAME secret as user access tokens. A signature-only check would happily
    // accept the public anon key as a Bearer token, letting anyone impersonate
    // a signed-in user. Only `authenticated` role tokens are user sessions.
    if (this.requiredRole && role !== this.requiredRole) {
      throw new SupabaseTokenError('INVALID_ROLE');
    }

    // A token minted by a different Supabase project must not be accepted.
    if (this.projectRef && typeof payload.ref === 'string' && payload.ref !== this.projectRef) {
      throw new SupabaseTokenError('TOKEN_INVALID');
    }

    if (!payload.sub || typeof payload.sub !== 'string') {
      throw new SupabaseTokenError('TOKEN_INVALID');
    }

    return {
      id: payload.sub,
      email: typeof payload.email === 'string' ? payload.email : undefined,
      phone: typeof payload.phone === 'string' ? payload.phone : undefined,
      role,
      session_id: typeof payload.session_id === 'string' ? payload.session_id : undefined,
    };
  }

  /** Server-side Supabase client (service_role). Null when not configured. */
  getAdminClient(): SupabaseClient | null {
    return this.adminClient;
  }

  /** Throws when the admin client is unavailable, so callers fail loudly. */
  requireAdminClient(): SupabaseClient {
    if (!this.adminClient) {
      throw new Error(
        'SUPABASE_ADMIN_UNAVAILABLE: SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must both be set.',
      );
    }
    return this.adminClient;
  }
}
