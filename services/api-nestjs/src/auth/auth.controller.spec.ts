import { Test, TestingModule } from '@nestjs/testing';
import { AuthController } from './auth.controller.js';
import { AuthService } from './auth.service.js';
import { FirebaseAuthGuard } from './guards/firebase-auth.guard.js';
import { FirebaseService } from '../firebase/firebase.service.js';
import { AuthenticatedUser } from './interfaces/authenticated-user.interface.js';

describe('AuthController', () => {
  let controller: AuthController;
  let authService: AuthService;

  const mockUser: AuthenticatedUser = {
    uid: 'firebase-user-abc',
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
    getCurrentUser: jest.fn().mockReturnValue({
      success: true,
      user: {
        uid: mockUser.uid,
        email: mockUser.email,
      },
    }),
  };

  const mockFirebaseService = {
    verifyIdToken: jest.fn(),
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
          provide: FirebaseService,
          useValue: mockFirebaseService,
        },
        FirebaseAuthGuard,
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
          uid: 'firebase-user-abc',
          email: 'dinesh@younme.app',
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
          uid: 'firebase-user-abc',
          email: 'dinesh@younme.app',
        },
      });
      expect(authService.getCurrentUser).toHaveBeenCalledWith(mockUser);
    });
  });
});
