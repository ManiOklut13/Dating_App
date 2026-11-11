import { Controller, Get, InternalServerErrorException } from '@nestjs/common';
import { DatabaseService } from './modules/database/database.service.js';
import { RedisService } from './modules/redis/redis.service.js';
import { SupabaseService } from './supabase/supabase.service.js';

@Controller('v1/health')
export class HealthController {
  constructor(
    private readonly databaseService: DatabaseService,
    private readonly redisService: RedisService,
    private readonly supabaseService: SupabaseService,
  ) {}

  @Get()
  async getFullHealth() {
    const dbConnected = this.databaseService.isConnected;
    let dbPing = false;
    let tablesCount = 0;

    try {
      const res = await this.databaseService.query(
        "SELECT count(*) as count FROM information_schema.tables WHERE table_schema = 'public'",
      );
      tablesCount = parseInt(res.rows[0]?.count || '0', 10);
      dbPing = true;
    } catch {}

    const redisStatus = await this.redisService.getHealthStatus();
    const supabaseClient = this.supabaseService.getClient();

    return {
      status: dbPing && redisStatus.connected ? 'healthy' : 'degraded',
      service: 'YoUnMe Core API Gateway (NestJS)',
      timestamp: new Date().toISOString(),
      connections: {
        database: {
          engine: 'Supabase PostgreSQL (AWS ap-northeast-2 pooler)',
          pool_connected: dbConnected,
          live_query: dbPing,
          public_tables: tablesCount,
        },
        redis: {
          engine: redisStatus.engine,
          connected: redisStatus.connected,
          ping: redisStatus.ping,
          host: redisStatus.host,
        },
        supabase_auth: {
          initialized: !!supabaseClient,
          mode: 'REST & JWT HS256/ES256 Verification',
        },
      },
    };
  }

  @Get('db-check')
  async checkDatabaseConnection() {
    try {
      const start = Date.now();
      const res = await this.databaseService.query(
        'SELECT now() as current_time, current_database() as database, version() as pg_version',
      );
      const latencyMs = Date.now() - start;

      return {
        status: 'online',
        connectedToSupabase: true,
        latency_ms: latencyMs,
        details: res.rows[0],
        message: 'Successfully verified live connection to Supabase PostgreSQL!',
        timestamp: new Date().toISOString(),
      };
    } catch (error: any) {
      throw new InternalServerErrorException({
        status: 'offline',
        connectedToSupabase: false,
        error: error.message,
      });
    }
  }

  @Get('redis-check')
  async checkRedisConnection() {
    try {
      const start = Date.now();
      const ping = await this.redisService.ping();
      const testKey = `health_check_${Date.now()}`;
      await this.redisService.set(testKey, { ok: true }, 30);
      const readBack = await this.redisService.get(testKey);
      await this.redisService.del(testKey);
      const latencyMs = Date.now() - start;

      return {
        status: 'online',
        connectedToRedis: ping === 'PONG',
        latency_ms: latencyMs,
        read_write_verified: readBack?.ok === true,
        ping,
        engine: 'Upstash Redis Cloud (Mumbai)',
        timestamp: new Date().toISOString(),
      };
    } catch (error: any) {
      throw new InternalServerErrorException({
        status: 'offline',
        connectedToRedis: false,
        error: error.message,
      });
    }
  }
}