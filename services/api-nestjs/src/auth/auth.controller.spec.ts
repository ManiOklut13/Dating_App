import { Test, TestingModule } from '@nestjs/testing';
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
    email: 'dinesh@younme.app',
    phone: '+919820011111',
    role: 'authenticated',
  };

  const mockAuthService = {
    signIn: jest.fn().mockReturnValue({
      success: true,
      message: 'Sign in successful',
      user: {
        id: mockUser.id,
        email: mockUser.email,
        phone: mockUser.phone,
      },
    }),
    getCurrentUser: jest.fn().mockReturnValue({
      success: true,
      user: {
        id: mockUser.id,
        email: mockUser.email,
        phone: mockUser.phone,
      },
    }),
  };

  const mockSupabaseService = {
    verifyAccessToken: jest.fn(),
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
    it('should return sign in response from service', async () => {
      const response = await controller.signIn(mockUser);
      expect(response).toEqual({
        success: true,
        message: 'Sign in successful',
        user: {
          id: '11111111-1111-1111-1111-111111111111',
          email: 'dinesh@younme.app',
          phone: '+919820011111',
        },
      });
      expect(authService.signIn).toHaveBeenCalledWith(mockUser);
    });
  });

  describe('getCurrentUser', () => {
    it('should return current user response from service', async () => {
      const response = await controller.getCurrentUser(mockUser);
      expect(response).toEqual({
        success: true,
        user: {
          id: '11111111-1111-1111-1111-111111111111',
          email: 'dinesh@younme.app',
          phone: '+919820011111',
        },
      });
      expect(authService.getCurrentUser).toHaveBeenCalledWith(mockUser);
    });
  });
});
