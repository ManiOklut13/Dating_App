/**
 * YoUnMe Dating App — Upstash Redis Service
 * Provides centralized high-throughput key-value caching, session tracking,
 * rate limiting, and live connectivity health checks.
 */

import { Injectable, Logger, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Redis } from 'ioredis';

@Injectable()
export class RedisService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(RedisService.name);
  private client: Redis | null = null;
  public isConnected: boolean = false;

  constructor(private readonly configService: ConfigService) {}

  async onModuleInit() {
    const redisUrl =
      this.configService.get<string>('REDIS_URL') ||
      process.env.REDIS_URL;

    try {
      if (redisUrl) {
        this.client = new Redis(redisUrl, {
          connectTimeout: 5000,
          maxRetriesPerRequest: 3,
          lazyConnect: false,
        });
      } else {
        const host = this.configService.get<string>('REDIS_HOST') || '127.0.0.1';
        const port = Number(this.configService.get<number>('REDIS_PORT') || 6379);
        const password = this.configService.get<string>('REDIS_PASSWORD');
        const tls = this.configService.get<boolean>('REDIS_TLS') ? {} : undefined;

        this.client = new Redis({
          host,
          port,
          password,
          tls,
          connectTimeout: 5000,
          maxRetriesPerRequest: 3,
        });
      }

      this.client.on('connect', () => {
        this.isConnected = true;
        this.logger.log('Connected to Upstash Redis cache successfully.');
      });

      this.client.on('error', (err) => {
        this.isConnected = false;
        this.logger.warn(`Redis connection notice: ${err.message}`);
      });

      // Verification ping
      const pong = await this.client.ping();
      if (pong === 'PONG') {
        this.isConnected = true;
        this.logger.log('Redis health check: PONG received.');
      }
    } catch (err: any) {
      this.logger.warn(`Redis initialization notice: ${err.message}`);
    }
  }

  async onModuleDestroy() {
    if (this.client) {
      try {
        await this.client.quit();
      } catch {}
    }
  }

  getClient(): Redis | null {
    return this.client;
  }

  async ping(): Promise<string> {
    if (!this.client) return 'OFFLINE';
    try {
      return await this.client.ping();
    } catch {
      return 'OFFLINE';
    }
  }

  async get<T = any>(key: string): Promise<T | null> {
    if (!this.client || !this.isConnected) return null;
    try {
      const data = await this.client.get(key);
      if (!data) return null;
      try {
        return JSON.parse(data);
      } catch {
        return data as any;
      }
    } catch (err: any) {
      this.logger.warn(`Redis get error (${key}): ${err.message}`);
      return null;
    }
  }

  async set(key: string, value: any, ttlSeconds?: number): Promise<boolean> {
    if (!this.client || !this.isConnected) return false;
    try {
      const serialized = typeof value === 'string' ? value : JSON.stringify(value);
      if (ttlSeconds && ttlSeconds > 0) {
        await this.client.set(key, serialized, 'EX', ttlSeconds);
      } else {
        await this.client.set(key, serialized);
      }
      return true;
    } catch (err: any) {
      this.logger.warn(`Redis set error (${key}): ${err.message}`);
      return false;
    }
  }

  async del(key: string): Promise<boolean> {
    if (!this.client || !this.isConnected) return false;
    try {
      await this.client.del(key);
      return true;
    } catch {
      return false;
    }
  }

  async incr(key: string): Promise<number> {
    if (!this.client || !this.isConnected) return 1;
    try {
      return await this.client.incr(key);
    } catch {
      return 1;
    }
  }

  async expire(key: string, seconds: number): Promise<boolean> {
    if (!this.client || !this.isConnected) return false;
    try {
      await this.client.expire(key, seconds);
      return true;
    } catch {
      return false;
    }
  }

  async getHealthStatus(): Promise<{
    connected: boolean;
    ping: string;
    engine: string;
    host?: string;
  }> {
    const pingRes = await this.ping();
    return {
      connected: this.isConnected,
      ping: pingRes,
      engine: 'Upstash Redis Cloud (Mumbai)',
      host: this.configService.get<string>('REDIS_HOST') || 'Upstash',
    };
  }
}
