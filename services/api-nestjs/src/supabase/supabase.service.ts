/**
 * YoUnMe Dating App — Supabase Service
 * Global Supabase integration using @supabase/supabase-js.
 * Handles client lifecycle and token verification via Supabase Auth.
 */

import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createClient, SupabaseClient, User } from '@supabase/supabase-js';

@Injectable()
export class SupabaseService implements OnModuleInit {
  private readonly logger = new Logger(SupabaseService.name);
  private client: SupabaseClient | null = null;
  private anonClient: SupabaseClient | null = null;
  private adminClient: SupabaseClient | null = null;
  private isInitialized = false;

  constructor(private readonly configService: ConfigService) {}

  onModuleInit() {
    this.initClient();
  }

  private initClient(): void {
    const supabaseUrl =
      this.configService.get<string>('SUPABASE_URL') ||
      process.env.SUPABASE_URL;
    const serviceRoleKey =
      this.configService.get<string>('SUPABASE_SERVICE_ROLE_KEY') ||
      process.env.SUPABASE_SERVICE_ROLE_KEY;
    const anonKey =
      this.configService.get<string>('SUPABASE_ANON_KEY') ||
      this.configService.get<string>('SUPABASE_PUBLISHABLE_KEY') ||
      this.configService.get<string>('SUPABASE_KEY') ||
      process.env.SUPABASE_ANON_KEY ||
      process.env.SUPABASE_PUBLISHABLE_KEY ||
      process.env.SUPABASE_KEY;

    if (supabaseUrl && (anonKey || serviceRoleKey)) {
      try {
        // Dedicated anon client for normal public user authentication (signUp, signInWithPassword)
        if (anonKey) {
          this.anonClient = createClient(supabaseUrl, anonKey, {
            auth: {
              persistSession: false,
              autoRefreshToken: false,
              detectSessionInUrl: false,
            },
          });
        }

        // Dedicated admin client exclusively for privileged backend operations
        if (serviceRoleKey) {
          this.adminClient = createClient(supabaseUrl, serviceRoleKey, {
            auth: {
              persistSession: false,
              autoRefreshToken: false,
              detectSessionInUrl: false,
            },
          });
        }

        this.client = this.adminClient || this.anonClient;
        this.isInitialized = true;
        this.logger.log(`✅ Supabase Clients initialized successfully for ${supabaseUrl} (anon: ${!!this.anonClient}, admin: ${!!this.adminClient})`);
      } catch (err: any) {
        this.logger.error(`Failed to initialize Supabase Client: ${err.message}`);
      }
    } else {
      this.logger.warn(
        'Supabase URL or Key not provided. Supabase service running in fallback/local mode.',
      );
    }
  }

  /**
   * Returns whether the Supabase client is actively initialized.
   */
  get hasClient(): boolean {
    return this.isInitialized && (this.anonClient !== null || this.adminClient !== null || this.client !== null);
  }

  /**
   * Returns the anon SupabaseClient instance (for user authentication).
   */
  getAnonClient(): SupabaseClient {
    if (!this.anonClient) {
      this.initClient();
    }
    return this.anonClient || this.getClient();
  }

  /**
   * Returns the privileged admin SupabaseClient instance (for admin operations).
   */
  getAdminClient(): SupabaseClient {
    if (!this.adminClient) {
      this.initClient();
    }
    return this.adminClient || this.getClient();
  }

  /**
   * Returns the default SupabaseClient instance.
   */
  getClient(): SupabaseClient {
    if (!this.client) {
      this.initClient();
    }
    if (!this.client) {
      throw new Error('SUPABASE_NOT_INITIALIZED');
    }
    return this.client;
  }

  /**
   * Authenticates a Bearer token by calling supabase.auth.getUser(token).
   * Returns the verified Supabase User or null if invalid.
   */
  async getUser(token: string): Promise<User | null> {
    if (!this.client) {
      this.initClient();
    }

    if (!this.client) {
      return null;
    }

    try {
      const { data, error } = await this.client.auth.getUser(token);
      if (error || !data.user) {
        if (error) {
          this.logger.debug(`Supabase auth verification failed: ${error.message}`);
        }
        return null;
      }
      return data.user;
    } catch (err: any) {
      this.logger.error(`Error during Supabase getUser: ${err.message}`);
      return null;
    }
  }

  /**
   * Authenticate with email & password via Supabase Auth.
   * Uses anon client to respect email confirmation requirements.
   */
  async signInWithPassword(email: string, password: string) {
    const client = this.getAnonClient();
    return client.auth.signInWithPassword({ email, password });
  }

  /**
   * Register a new user in Supabase Auth using the standard auth.signUp() method.
   * Uses anon client so normal email confirmation is triggered according to Supabase project settings.
   * Does NOT auto-confirm the user.
   */
  async signUp(params: {
    email: string;
    password?: string;
    phone?: string;
    metadata?: Record<string, any>;
    redirectTo?: string;
  }) {
    const client = this.getAnonClient();
    const redirectTo =
      params.redirectTo ||
      this.configService.get<string>('EMAIL_CONFIRM_REDIRECT_URL') ||
      process.env.EMAIL_CONFIRM_REDIRECT_URL ||
      'http://localhost:8080/v1/auth/confirm';

    return client.auth.signUp({
      email: params.email,
      password: params.password!,
      options: {
        data: params.metadata,
        emailRedirectTo: redirectTo,
      },
    });
  }

  /**
   * Refreshes an existing session using a refresh_token via anon client.
   */
  async refreshSession(refreshToken: string) {
    const client = this.getAnonClient();
    return client.auth.refreshSession({ refresh_token: refreshToken });
  }

  /**
   * Verify email OTP / token_hash for email confirmation.
   */
  async verifyEmailOtp(tokenHash: string, type: any = 'signup') {
    const client = this.getAnonClient();
    return client.auth.verifyOtp({
      token_hash: tokenHash,
      type: type,
    });
  }

  /**
   * Exchange PKCE authorization code for session.
   */
  async exchangeCodeForSession(code: string) {
    const client = this.getAnonClient();
    return client.auth.exchangeCodeForSession(code);
  }

  /**
   * Dispatch OTP via email or phone through Supabase Auth.
   */
  async sendOtp(type: 'email' | 'phone', identifier: string) {
    const client = this.getClient();
    if (type === 'email') {
      return client.auth.signInWithOtp({
        email: identifier,
        options: { shouldCreateUser: true },
      });
    } else {
      return client.auth.signInWithOtp({
        phone: identifier,
        options: { shouldCreateUser: true },
      });
    }
  }

  /**
   * Verify OTP token via Supabase Auth.
   */
  async verifyOtp(type: 'email' | 'phone', identifier: string, token: string) {
    const client = this.getClient();
    if (type === 'email') {
      return client.auth.verifyOtp({
        email: identifier,
        token,
        type: 'email',
      });
    } else {
      return client.auth.verifyOtp({
        phone: identifier,
        token,
        type: 'sms',
      });
    }
  }

  /**
   * Sign in with Google / Apple OAuth credential ID token.
   */
  async signInWithIdToken(params: {
    provider: 'google' | 'apple';
    token: string;
    nonce?: string;
    access_token?: string;
  }) {
    const client = this.getClient();
    return client.auth.signInWithIdToken(params);
  }

  /**
   * Triggers password reset email via Supabase Auth.
   */
  async resetPasswordForEmail(email: string, redirectTo?: string) {
    const client = this.getClient();
    return client.auth.resetPasswordForEmail(email, { redirectTo });
  }

  /**
   * Updates user password via Supabase admin or user client.
   */
  async updateUserPassword(userId: string, newPassword: string) {
    const client = this.getClient();
    try {
      if (client.auth.admin) {
        return await client.auth.admin.updateUserById(userId, {
          password: newPassword,
        });
      }
    } catch (err: any) {
      this.logger.warn(`Admin updateUserById unavailable: ${err.message}`);
    }
    return client.auth.updateUser({ password: newPassword });
  }

  /**
   * Uploads asset buffer to Supabase Storage and returns public URL.
   */
  async uploadPhoto(
    bucket: string,
    storagePath: string,
    fileBuffer: Buffer,
    contentType: string,
  ): Promise<{ publicUrl: string; error?: string }> {
    const client = this.getClient();
    try {
      const { data, error } = await client.storage
        .from(bucket)
        .upload(storagePath, fileBuffer, {
          contentType,
          upsert: true,
        });

      if (error) {
        return { publicUrl: '', error: error.message };
      }

      const { data: publicUrlData } = client.storage
        .from(bucket)
        .getPublicUrl(storagePath);

      return { publicUrl: publicUrlData.publicUrl };
    } catch (err: any) {
      return { publicUrl: '', error: err.message };
    }
  }
}
