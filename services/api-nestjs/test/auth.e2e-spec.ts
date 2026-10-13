import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from '../src/app.module.js';
import { FirebaseService } from '../src/firebase/firebase.service.js';

describe('Auth Endpoints (e2e)', () => {
  let app: INestApplication;

  const mockFirebaseService = {
    verifyIdToken: jest.fn(),
  };

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    })
      .overrideProvider(FirebaseService)
      .useValue(mockFirebaseService)
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

    it('4. should return 401 when Firebase ID token is invalid', async () => {
      mockFirebaseService.verifyIdToken.mockRejectedValueOnce(new Error('TOKEN_INVALID'));

      const response = await request(app.getHttpServer())
        .post('/v1/auth/signin')
        .set('Authorization', 'Bearer invalid.mock.token')
        .expect(401);

      expect(response.body).toMatchObject({
        statusCode: 401,
        message: 'Invalid Firebase ID token',
        error: 'Unauthorized',
      });
    });

    it('5. should return 401 when Firebase ID token is expired', async () => {
      mockFirebaseService.verifyIdToken.mockRejectedValueOnce(new Error('TOKEN_EXPIRED'));

      const response = await request(app.getHttpServer())
        .post('/v1/auth/signin')
        .set('Authorization', 'Bearer expired.mock.token')
        .expect(401);

      expect(response.body).toMatchObject({
        statusCode: 401,
        message: 'Firebase ID token has expired',
        error: 'Unauthorized',
      });
    });

    it('6. should return 200 with verified user info when Firebase token is valid', async () => {
      mockFirebaseService.verifyIdToken.mockResolvedValueOnce({
        uid: 'firebase_user_777',
        email: 'dinesh@younme.app',
        email_verified: true,
      });

      const response = await request(app.getHttpServer())
        .post('/v1/auth/signin')
        .set('Authorization', 'Bearer valid.jwt.token')
        .expect(200);

      expect(response.body).toEqual({
        success: true,
        message: 'Sign in successful',
        user: {
          uid: 'firebase_user_777',
          email: 'dinesh@younme.app',
        },
      });
    });
  });

  describe('GET /v1/auth/me', () => {
    it('7. should return 401 when unauthenticated', async () => {
      const response = await request(app.getHttpServer())
        .get('/v1/auth/me')
        .expect(401);

      expect(response.body).toMatchObject({
        statusCode: 401,
        message: 'Authorization header is missing',
        error: 'Unauthorized',
      });
    });

    it('8. should return 200 with current user data when authenticated', async () => {
      mockFirebaseService.verifyIdToken.mockResolvedValueOnce({
        uid: 'firebase_user_777',
        email: 'dinesh@younme.app',
        email_verified: true,
      });

      const response = await request(app.getHttpServer())
        .get('/v1/auth/me')
        .set('Authorization', 'Bearer valid.jwt.token')
        .expect(200);

      expect(response.body).toEqual({
        success: true,
        user: {
          uid: 'firebase_user_777',
          email: 'dinesh@younme.app',
        },
      });
    });
  });
});
