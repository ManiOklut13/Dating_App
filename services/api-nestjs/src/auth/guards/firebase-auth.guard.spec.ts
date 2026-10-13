import { ExecutionContext, UnauthorizedException } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { FirebaseAuthGuard } from './firebase-auth.guard.js';
import { FirebaseService } from '../../firebase/firebase.service.js';

describe('FirebaseAuthGuard', () => {
  let guard: FirebaseAuthGuard;
  let firebaseService: FirebaseService;

  const mockFirebaseService = {
    verifyIdToken: jest.fn(),
  };

  const createMockContext = (authHeader?: string): ExecutionContext => {
    const request = {
      headers: {
        authorization: authHeader,
      },
      user: null as any,
    };

    return {
      switchToHttp: () => ({
        getRequest: () => request,
        getResponse: () => ({}),
      }),
    } as unknown as ExecutionContext;
  };

  beforeEach(async () => {
    jest.clearAllMocks();

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        FirebaseAuthGuard,
        {
          provide: FirebaseService,
          useValue: mockFirebaseService,
        },
      ],
    }).compile();

    guard = module.get<FirebaseAuthGuard>(FirebaseAuthGuard);
    firebaseService = module.get<FirebaseService>(FirebaseService);
  });

  it('should be defined', () => {
    expect(guard).toBeDefined();
  });

  it('1. should throw UnauthorizedException when Authorization header is missing', async () => {
    const context = createMockContext(undefined);
    await expect(guard.canActivate(context)).rejects.toThrow(
      new UnauthorizedException('Authorization header is missing'),
    );
  });

  it('2. should throw UnauthorizedException when Authorization header does not start with Bearer', async () => {
    const context = createMockContext('Basic some-credentials');
    await expect(guard.canActivate(context)).rejects.toThrow(
      new UnauthorizedException('Malformed authorization header. Expected "Bearer <token>"'),
    );
  });

  it('3. should throw UnauthorizedException when Bearer token is empty', async () => {
    const context = createMockContext('Bearer ');
    await expect(guard.canActivate(context)).rejects.toThrow(
      new UnauthorizedException('Malformed authorization header. Expected "Bearer <token>"'),
    );
  });

  it('4. should throw UnauthorizedException when Firebase ID token is invalid', async () => {
    mockFirebaseService.verifyIdToken.mockRejectedValueOnce(new Error('TOKEN_INVALID'));
    const context = createMockContext('Bearer invalid.fake.token');

    await expect(guard.canActivate(context)).rejects.toThrow(
      new UnauthorizedException('Invalid Firebase ID token'),
    );
    expect(mockFirebaseService.verifyIdToken).toHaveBeenCalledWith('invalid.fake.token');
  });

  it('5. should throw UnauthorizedException when Firebase ID token is expired', async () => {
    mockFirebaseService.verifyIdToken.mockRejectedValueOnce(new Error('TOKEN_EXPIRED'));
    const context = createMockContext('Bearer expired.token.value');

    await expect(guard.canActivate(context)).rejects.toThrow(
      new UnauthorizedException('Firebase ID token has expired'),
    );
    expect(mockFirebaseService.verifyIdToken).toHaveBeenCalledWith('expired.token.value');
  });

  it('6. should attach user to request and return true for valid Firebase ID token', async () => {
    const mockDecodedUser = {
      uid: 'firebase_test_uid_999',
      email: 'test@younme.app',
      email_verified: true,
    };
    mockFirebaseService.verifyIdToken.mockResolvedValueOnce(mockDecodedUser);

    const context = createMockContext('Bearer valid.jwt.token');
    const result = await guard.canActivate(context);

    expect(result).toBe(true);
    const request = context.switchToHttp().getRequest();
    expect(request.user).toEqual({
      uid: 'firebase_test_uid_999',
      email: 'test@younme.app',
      email_verified: true,
    });
  });
});
