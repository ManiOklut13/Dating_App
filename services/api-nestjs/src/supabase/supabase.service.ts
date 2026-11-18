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
  private isInitialized = false;

  constructor(private readonly configService: ConfigService) {}

  onModuleInit() {
    this.initClient();
  }

  private initClient(): void {
    const supabaseUrl =
      this.configService.get<string>('SUPABASE_URL') ||
      process.env.SUPABASE_URL;
    const supabaseKey =
      this.configService.get<string>('SUPABASE_SERVICE_ROLE_KEY') ||
      this.configService.get<string>('SUPABASE_ANON_KEY') ||
      this.configService.get<string>('SUPABASE_KEY') ||
      process.env.SUPABASE_SERVICE_ROLE_KEY ||
      process.env.SUPABASE_ANON_KEY ||
      process.env.SUPABASE_KEY;

    if (supabaseUrl && supabaseKey) {
      try {
        this.client = createClient(supabaseUrl, supabaseKey, {
          auth: {
            persistSession: false,
            autoRefreshToken: false,
            detectSessionInUrl: false,
          },
        });
        this.isInitialized = true;
        this.logger.log(`✅ Supabase Client initialized successfully for ${supabaseUrl}`);
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
    return this.isInitialized && this.client !== null;
  }

  /**
   * Returns the underlying SupabaseClient instance.
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
   */
  async signInWithPassword(email: string, password: string) {
    const client = this.getClient();
    return client.auth.signInWithPassword({ email, password });
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
