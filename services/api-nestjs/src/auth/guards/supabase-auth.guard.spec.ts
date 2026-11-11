import { ExecutionContext, UnauthorizedException } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { SupabaseAuthGuard } from './supabase-auth.guard.js';
import { SupabaseService, SupabaseTokenError } from '../../supabase/supabase.service.js';

describe('SupabaseAuthGuard', () => {
  let guard: SupabaseAuthGuard;
  let supabaseService: SupabaseService;

  const mockSupabaseService = {
    verifyAccessToken: jest.fn(),
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
        SupabaseAuthGuard,
        {
          provide: SupabaseService,
          useValue: mockSupabaseService,
        },
      ],
    }).compile();

    guard = module.get<SupabaseAuthGuard>(SupabaseAuthGuard);
    supabaseService = module.get<SupabaseService>(SupabaseService);
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

  it('4. should throw UnauthorizedException when Supabase access token is invalid', async () => {
    mockSupabaseService.verifyAccessToken.mockImplementationOnce(() => {
      throw new SupabaseTokenError('TOKEN_INVALID');
    });
    const context = createMockContext('Bearer invalid.fake.token');

    await expect(guard.canActivate(context)).rejects.toThrow(
      new UnauthorizedException('Invalid Supabase access token'),
    );
    expect(mockSupabaseService.verifyAccessToken).toHaveBeenCalledWith('invalid.fake.token');
  });

  it('5. should throw UnauthorizedException when Supabase access token is expired', async () => {
    mockSupabaseService.verifyAccessToken.mockImplementationOnce(() => {
      throw new SupabaseTokenError('TOKEN_EXPIRED');
    });
    const context = createMockContext('Bearer expired.token.value');

    await expect(guard.canActivate(context)).rejects.toThrow(
      new UnauthorizedException('Supabase access token has expired'),
    );
    expect(mockSupabaseService.verifyAccessToken).toHaveBeenCalledWith('expired.token.value');
  });

  it('6. should reject a non-authenticated role token (anon / service_role API keys)', async () => {
    mockSupabaseService.verifyAccessToken.mockImplementationOnce(() => {
      throw new SupabaseTokenError('INVALID_ROLE');
    });
    const context = createMockContext('Bearer anon.api.key');

    await expect(guard.canActivate(context)).rejects.toThrow(
      new UnauthorizedException('Token is not an authenticated user token'),
    );
  });

  it('7. should attach user to request and return true for a valid access token', async () => {
    const mockDecodedUser = {
      id: '11111111-1111-1111-1111-111111111111',
      email: 'test@younme.app',
      phone: '+919820011111',
      role: 'authenticated',
      session_id: 'session-abc',
    };
    mockSupabaseService.verifyAccessToken.mockReturnValueOnce(mockDecodedUser);

    const context = createMockContext('Bearer valid.jwt.token');
    const result = await guard.canActivate(context);

    expect(result).toBe(true);
    const request = context.switchToHttp().getRequest();
    expect(request.user).toEqual({
      id: '11111111-1111-1111-1111-111111111111',
      email: 'test@younme.app',
      phone: '+919820011111',
      role: 'authenticated',
      session_id: 'session-abc',
    });
  });
});
