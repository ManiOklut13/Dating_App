import { jest } from '@jest/globals';
import { Test, TestingModule } from '@nestjs/testing';
import { ConfigService } from '@nestjs/config';
import { AuthController } from './auth.controller.js';
import { AuthService } from './auth.service.js';
import { SupabaseAuthGuard } from './guards/supabase-auth.guard.js';
import { SupabaseService } from '../supabase/supabase.service.js';
import { AuthenticatedUser } from './interfaces/authenticated-user.interface.js';

describe('AuthController', () => {
  let controller: AuthController;
  let authService: AuthService;

  const mockUser: AuthenticatedUser = {
    id: '11111111-1111-1111-1111-111111111111',
    authentication_uid: 'supabase-user-abc',
    uid: '11111111-1111-1111-1111-111111111111',
    email: 'dinesh@younme.app',
    email_verified: true,
  };

  const mockAuthService = {
    signIn: jest.fn().mockReturnValue({
      success: true,
      message: 'Sign in successful',
      user: {
        uid: mockUser.uid,
        email: mockUser.email,
      },
    }),
    sendOtp: jest.fn().mockReturnValue({
      success: true,
      message: 'OTP dispatched successfully to user@example.com',
      type: 'email',
      identifier: 'user@example.com',
    }),
    verifyOtp: jest.fn().mockReturnValue({
      success: true,
      message: 'OTP verified successfully',
      user: { uid: mockUser.uid, email: mockUser.email },
      session: { access_token: 'mock-session-token' },
    }),
    signInWithGoogle: jest.fn().mockReturnValue({
      success: true,
      message: 'Google authentication successful',
      user: { uid: mockUser.uid, email: 'google@younme.app' },
      session: { access_token: 'google-session-token' },
    }),
    signInWithApple: jest.fn().mockReturnValue({
      success: true,
      message: 'Apple authentication successful',
      user: { uid: mockUser.uid, email: 'apple@younme.app' },
      session: { access_token: 'apple-session-token' },
    }),
    forgotPassword: jest.fn().mockReturnValue({
      success: true,
      message: 'Password reset link/OTP sent successfully',
    }),
    resetPassword: jest.fn().mockReturnValue({
      success: true,
      message: 'Password updated successfully',
    }),
    getCurrentUser: jest.fn().mockReturnValue({
      success: true,
      user: {
        uid: mockUser.uid,
        email: mockUser.email,
      },
    }),
  };

  const mockSupabaseService = {
    getUser: jest.fn(),
    getClient: jest.fn(),
  };

  const mockConfigService = {
    get: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [AuthController],
      providers: [
        {
          provide: AuthService,
          useValue: mockAuthService,
        },
        {
          provide: SupabaseService,
          useValue: mockSupabaseService,
        },
        {
          provide: ConfigService,
          useValue: mockConfigService,
        },
        SupabaseAuthGuard,
      ],
    }).compile();

    controller = module.get<AuthController>(AuthController);
    authService = module.get<AuthService>(AuthService);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('signIn', () => {
    it('should return sign in response from service with user context', async () => {
      const response = await controller.signIn(mockUser);
      expect(response).toEqual({
        success: true,
        message: 'Sign in successful',
        user: {
          uid: '11111111-1111-1111-1111-111111111111',
          email: 'dinesh@younme.app',
        },
      });
      expect(authService.signIn).toHaveBeenCalledWith(mockUser);
    });

    it('should call authService.signIn with dto when credentials provided', async () => {
      const creds = { email: 'test@example.com', password: 'password123' };
      await controller.signIn(undefined, creds);
      expect(authService.signIn).toHaveBeenCalledWith(undefined, creds);
    });
  });

  describe('OTP flow', () => {
    it('should dispatch OTP via sendOtp', async () => {
      const res = await controller.sendOtp({ type: 'email', identifier: 'user@example.com' });
      expect(res.success).toBe(true);
      expect(authService.sendOtp).toHaveBeenCalledWith({ type: 'email', identifier: 'user@example.com' });
    });

    it('should verify OTP via verifyOtp', async () => {
      const res = await controller.verifyOtp({ type: 'email', identifier: 'user@example.com', token: '123456' });
      expect(res.success).toBe(true);
      expect(authService.verifyOtp).toHaveBeenCalledWith({
        type: 'email',
        identifier: 'user@example.com',
        token: '123456',
      });
    });
  });

  describe('OAuth SSO', () => {
    it('should handle Google SSO token exchange', async () => {
      const res = await controller.signInWithGoogle({ id_token: 'google-token' });
      expect(res.success).toBe(true);
      expect(authService.signInWithGoogle).toHaveBeenCalledWith({ id_token: 'google-token' });
    });

    it('should handle Apple SSO token exchange', async () => {
      const res = await controller.signInWithApple({ id_token: 'apple-token' });
      expect(res.success).toBe(true);
      expect(authService.signInWithApple).toHaveBeenCalledWith({ id_token: 'apple-token' });
    });
  });

  describe('Password Recovery', () => {
    it('should handle forgotPassword dispatch', async () => {
      const res = await controller.forgotPassword({ identifier: 'user@example.com' });
      expect(res.success).toBe(true);
      expect(authService.forgotPassword).toHaveBeenCalledWith({ identifier: 'user@example.com' });
    });

    it('should handle resetPassword securely', async () => {
      const res = await controller.resetPassword({ new_password: 'NewPassword123!', token: 'reset-token' });
      expect(res.success).toBe(true);
      expect(authService.resetPassword).toHaveBeenCalledWith({
        new_password: 'NewPassword123!',
        token: 'reset-token',
      });
    });
  });

  describe('getCurrentUser', () => {
    it('should return current user response from service', async () => {
      const response = await controller.getCurrentUser(mockUser);
      expect(response).toEqual({
        success: true,
        user: {
          uid: '11111111-1111-1111-1111-111111111111',
          email: 'dinesh@younme.app',
        },
      });
      expect(authService.getCurrentUser).toHaveBeenCalledWith(mockUser);
    });
  });
});
