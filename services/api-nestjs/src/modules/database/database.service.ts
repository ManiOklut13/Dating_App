/**
 * YoUnMe Dating App — Database Service
 * Managed PostgreSQL connection pooling for Supabase PostgreSQL with SSL.
 */

import { Injectable, OnModuleInit, OnModuleDestroy, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Pool, PoolConfig } from 'pg';

@Injectable()
export class DatabaseService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(DatabaseService.name);
  private connected = false;
  public pool: Pool;

  constructor(private readonly configService: ConfigService) {
    const connectionString =
      this.configService.get<string>('DATABASE_URL') ||
      process.env.DATABASE_URL;

    const isLocalhost =
      !connectionString ||
      connectionString.includes('localhost') ||
      connectionString.includes('127.0.0.1');

    const poolConfig: PoolConfig = {
      connectionString,
      connectionTimeoutMillis: 10000,
      idleTimeoutMillis: 30000,
      max: 20,
      // Supabase managed PostgreSQL requires SSL in production and connection pooling
      ssl: isLocalhost
        ? false
        : {
            rejectUnauthorized: false,
          },
    };

    this.pool = new Pool(poolConfig);

    this.pool.on('error', (error) => {
      this.connected = false;
      this.logger.error(`Supabase PostgreSQL pool error: ${error.message}`);
    });
  }

  /** True only once the initial handshake succeeded; feature services use this to pick the in-memory adapter. */
  get isConnected(): boolean {
    return this.connected;
  }

  async onModuleInit() {
    if (!this.configService.get<string>('DATABASE_URL') && !process.env.DATABASE_URL) {
      this.logger.warn(
        'DATABASE_URL not configured. Running database service in fallback/in-memory mode.',
      );
      this.connected = false;
      return;
    }

    try {
      const client = await this.pool.connect();
      try {
        const res = await client.query('SELECT NOW()');
        this.connected = true;
        this.logger.log(
          `✅ Connected to Supabase Managed PostgreSQL successfully! DB Time: ${res.rows[0].now}`,
        );
      } finally {
        client.release();
      }
    } catch (error: any) {
      this.connected = false;
      this.logger.error(`❌ Supabase PostgreSQL Connection Failed: ${error.message}`);
    }
  }

  async onModuleDestroy() {
    try {
      await this.pool.end();
      this.logger.log('PostgreSQL connection pool closed.');
    } catch (err: any) {
      this.logger.error(`Error closing PostgreSQL pool: ${err.message}`);
    }
  }

  // Convenient helper method for feature services to run queries
  async query(text: string, params?: any[]) {
    if (!this.connected) {
      throw new Error('Supabase PostgreSQL is not connected');
    }
    return this.pool.query(text, params);
  }
}