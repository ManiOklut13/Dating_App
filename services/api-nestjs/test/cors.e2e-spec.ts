import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from '../src/app.module.js';

describe('CORS Endpoints (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();

    const allowedOrigins = [
      'http://localhost:5173',
      'http://localhost:3000',
      'http://localhost:8080',
      'http://127.0.0.1:5173',
      'http://127.0.0.1:3000',
    ];

    app.enableCors({
      origin: (requestOrigin, callback) => {
        if (!requestOrigin) return callback(null, true);
        if (
          process.env.NODE_ENV !== 'production' ||
          allowedOrigins.includes(requestOrigin) ||
          /^http:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/.test(requestOrigin)
        ) {
          return callback(null, true);
        }
        return callback(new Error(`CORS blocked for origin: ${requestOrigin}`), false);
      },
      methods: ['GET', 'HEAD', 'PUT', 'PATCH', 'POST', 'DELETE', 'OPTIONS'],
      allowedHeaders: [
        'Origin',
        'X-Requested-With',
        'Content-Type',
        'Accept',
        'Authorization',
        'apikey',
        'X-Client-Info',
        'prefer',
      ],
      exposedHeaders: ['Content-Range', 'X-Total-Count'],
      credentials: true,
      preflightContinue: false,
      optionsSuccessStatus: 204,
    });

    app.setGlobalPrefix('v1', {
      exclude: ['health', 'ws', 'docs', 'v1/docs', 'assets'],
    });

    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  it('1. should respond to OPTIONS preflight with correct CORS headers for localhost:5173', async () => {
    const res = await request(app.getHttpServer())
      .options('/v1/auth/signin')
      .set('Origin', 'http://localhost:5173')
      .set('Access-Control-Request-Method', 'POST')
      .set('Access-Control-Request-Headers', 'Content-Type, Authorization, apikey')
      .expect(204);

    expect(res.headers['access-control-allow-origin']).toBe('http://localhost:5173');
    expect(res.headers['access-control-allow-credentials']).toBe('true');
    expect(res.headers['access-control-allow-methods']).toContain('POST');
  });

  it('2. should respond with CORS headers on regular GET request from localhost:5173', async () => {
    const res = await request(app.getHttpServer())
      .get('/health')
      .set('Origin', 'http://localhost:5173');

    expect(res.headers['access-control-allow-origin']).toBe('http://localhost:5173');
    expect(res.headers['access-control-allow-credentials']).toBe('true');
  });
});
