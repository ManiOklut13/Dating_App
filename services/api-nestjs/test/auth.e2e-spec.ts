import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from '../src/app.module.js';
import { SupabaseService, SupabaseTokenError } from '../src/supabase/supabase.service.js';

describe('Auth Endpoints (e2e)', () => {
  let app: INestApplication;

  const mockSupabaseService = {
    verifyAccessToken: jest.fn(),
  };

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    })
      .overrideProvider(SupabaseService)
      .useValue(mockSupabaseService)
      .compile();

    app = moduleFixture.createNestApplication();
    app.setGlobalPrefix('v1', {
      exclude: ['health', 'ws', 'docs', 'v1/docs', 'assets'],
    });

    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('POST /v1/auth/signin', () => {
    it('1. should return 401 when Authorization header is missing', async () => {
      const response = await request(app.getHttpServer())
        .post('/v1/auth/signin')
        .expect(401);

      expect(response.body).toMatchObject({
        statusCode: 401,
        message: 'Authorization header is missing',
        error: 'Unauthorized',
      });
    });

    it('2. should return 401 when Authorization header is malformed (not Bearer)', async () => {
      const response = await request(app.getHttpServer())
        .post('/v1/auth/signin')
        .set('Authorization', 'Basic token123')
        .expect(401);

      expect(response.body).toMatchObject({
        statusCode: 401,
        message: 'Malformed authorization header. Expected "Bearer <token>"',
        error: 'Unauthorized',
      });
    });

    it('3. should return 401 when Bearer token is empty', async () => {
      const response = await request(app.getHttpServer())
        .post('/v1/auth/signin')
        .set('Authorization', 'Bearer')
        .expect(401);

      expect(response.body).toMatchObject({
        statusCode: 401,
        message: 'Malformed authorization header. Expected "Bearer <token>"',
        error: 'Unauthorized',
      });
    });

    it('4. should return 401 when Supabase access token is invalid', async () => {
      mockSupabaseService.verifyAccessToken.mockImplementationOnce(() => {
        throw new SupabaseTokenError('TOKEN_INVALID');
      });

      const response = await request(app.getHttpServer())
        .post('/v1/auth/signin')
        .set('Authorization', 'Bearer invalid.mock.token')
        .expect(401);

      expect(response.body).toMatchObject({
        statusCode: 401,
        message: 'Invalid Supabase access token',
        error: 'Unauthorized',
      });
    });

    it('5. should return 401 when Supabase access token is expired', async () => {
      mockSupabaseService.verifyAccessToken.mockImplementationOnce(() => {
        throw new SupabaseTokenError('TOKEN_EXPIRED');
      });

      const response = await request(app.getHttpServer())
        .post('/v1/auth/signin')
        .set('Authorization', 'Bearer expired.mock.token')
        .expect(401);

      expect(response.body).toMatchObject({
        statusCode: 401,
        message: 'Supabase access token has expired',
        error: 'Unauthorized',
      });
    });

    it('6. should return 401 when the token is not an authenticated user token (anon / service_role API keys)', async () => {
      mockSupabaseService.verifyAccessToken.mockImplementationOnce(() => {
        throw new SupabaseTokenError('INVALID_ROLE');
      });

      const response = await request(app.getHttpServer())
        .post('/v1/auth/signin')
        .set('Authorization', 'Bearer anon.api.key.token')
        .expect(401);

      expect(response.body).toMatchObject({
        statusCode: 401,
        message: 'Token is not an authenticated user token',
        error: 'Unauthorized',
      });
    });

    it('7. should return 200 with verified user info when Supabase token is valid', async () => {
      mockSupabaseService.verifyAccessToken.mockReturnValueOnce({
        id: '11111111-1111-1111-1111-111111111111',
        email: 'dinesh@younme.app',
        phone: '+919820011111',
        role: 'authenticated',
      });

      const response = await request(app.getHttpServer())
        .post('/v1/auth/signin')
        .set('Authorization', 'Bearer valid.jwt.token')
        .expect(200);

      expect(response.body).toEqual({
        success: true,
        message: 'Sign in successful',
        user: {
          id: '11111111-1111-1111-1111-111111111111',
          email: 'dinesh@younme.app',
          phone: '+919820011111',
        },
      });
    });
  });

  describe('GET /v1/auth/me', () => {
    it('8. should return 401 when unauthenticated', async () => {
      const response = await request(app.getHttpServer())
        .get('/v1/auth/me')
        .expect(401);

      expect(response.body).toMatchObject({
        statusCode: 401,
        message: 'Authorization header is missing',
        error: 'Unauthorized',
      });
    });

    it('9. should return 200 with current user data when authenticated', async () => {
      mockSupabaseService.verifyAccessToken.mockReturnValueOnce({
        id: '11111111-1111-1111-1111-111111111111',
        email: 'dinesh@younme.app',
        phone: '+919820011111',
        role: 'authenticated',
      });

      const response = await request(app.getHttpServer())
        .get('/v1/auth/me')
        .set('Authorization', 'Bearer valid.jwt.token')
        .expect(200);

      expect(response.body).toEqual({
        success: true,
        user: {
          id: '11111111-1111-1111-1111-111111111111',
          email: 'dinesh@younme.app',
          phone: '+919820011111',
        },
      });
    });
  });
});
