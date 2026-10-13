import { Test, TestingModule } from '@nestjs/testing';
import { UnauthorizedException } from '@nestjs/common';
import { AuthService } from './auth.service.js';
import { AuthenticatedUser } from './interfaces/authenticated-user.interface.js';

describe('AuthService', () => {
  let authService: AuthService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [AuthService],
    }).compile();

    authService = module.get<AuthService>(AuthService);
  });

  describe('signIn', () => {
    it('should return valid user data when user object is provided', () => {
      const mockUser: AuthenticatedUser = {
        uid: 'firebase-user-123',
        email: 'dinesh@younme.app',
        email_verified: true,
      };

      const result = authService.signIn(mockUser);

      expect(result).toEqual({
        success: true,
        message: 'Sign in successful',
        user: {
          uid: 'firebase-user-123',
          email: 'dinesh@younme.app',
        },
      });
    });

    it('should throw UnauthorizedException if user is missing uid', () => {
      const invalidUser = { uid: '', email: 'dinesh@younme.app' } as AuthenticatedUser;
      expect(() => authService.signIn(invalidUser)).toThrow(UnauthorizedException);
    });
  });

  describe('getCurrentUser', () => {
    it('should return current user information', () => {
      const mockUser: AuthenticatedUser = {
        uid: 'firebase-user-123',
        email: 'dinesh@younme.app',
      };

      const result = authService.getCurrentUser(mockUser);

      expect(result).toEqual({
        success: true,
        user: {
          uid: 'firebase-user-123',
          email: 'dinesh@younme.app',
        },
      });
    });

    it('should throw UnauthorizedException if user is missing', () => {
      expect(() => authService.getCurrentUser(null as any)).toThrow(UnauthorizedException);
    });
  });
});
