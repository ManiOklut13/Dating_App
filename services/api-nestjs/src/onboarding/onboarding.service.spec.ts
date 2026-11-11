import { jest } from '@jest/globals';
import { NotFoundException } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { OnboardingService } from './onboarding.service.js';
import { ONBOARDING_REPOSITORY_TOKEN } from './onboarding.repository.js';
import {
  IOnboardingRepository,
  IProfileState,
  IUserAttributes,
} from './interfaces/onboarding.interface.js';

const DEMO_USER_ID = '11111111-1111-1111-1111-111111111111';

describe('OnboardingService', () => {
  let service: OnboardingService;

  const user: IUserAttributes = {
    id: DEMO_USER_ID,
    authentication_uid: 'supabase_uid_arjun_111',
    email: 'arjun.mehta@younme.social',
    email_verified: true,
    phone_country_code: '+91',
    phone_number: '9820011111',
    phone_verified: true,
    account_status: 'active',
    role: 'user',
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
  };

  const buildProfile = (overrides: Partial<IProfileState> = {}): IProfileState => ({
    user_id: DEMO_USER_ID,
    nickname: 'Arjun',
    sexual_orientations: [],
    looking_for: [],
    languages: [],
    interests: [],
    app_language: 'en',
    app_theme: 'dark',
    read_receipts_status: true,
    profile_visibility: 'everyone',
    show_online_status: true,
    who_can_message: 'everyone',
    who_can_message_request: 'everyone',
    push_notifications_enabled: true,
    push_notifications: {},
    email_notifications_enabled: true,
    email_notifications: {},
    min_age: 18,
    max_age: 50,
    max_distance_km: 50,
    is_verified: false,
    verification_status: 'not_started',
    is_voice_verified: false,
    liveness_verified: false,
    profile_progress: 0,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    ...overrides,
  });

  let storedPhotos: string[] = [];

  const repository: IOnboardingRepository = {
    findUserById: jest.fn(async (userId: string) => (userId === DEMO_USER_ID ? user : null)),
    findProfileByUserId: jest.fn(async () => null),
    upsertProfile: jest.fn(async (userId: string, partial: Partial<IProfileState>) =>
      buildProfile({ ...partial, user_id: userId }),
    ),
    updateUser: jest.fn(async () => user),
    replacePhotos: jest.fn(async (_userId: string, photoUrls: string[]) => {
      storedPhotos = photoUrls;
    }),
    countPhotos: jest.fn(async () => storedPhotos.length),
  };

  const upsertProfileMock = repository.upsertProfile as jest.MockedFunction<
    IOnboardingRepository['upsertProfile']
  >;
  const findProfileMock = repository.findProfileByUserId as jest.MockedFunction<
    IOnboardingRepository['findProfileByUserId']
  >;

  beforeEach(async () => {
    jest.clearAllMocks();
    storedPhotos = [];

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        OnboardingService,
        {
          provide: ONBOARDING_REPOSITORY_TOKEN,
          useValue: repository,
        },
      ],
    }).compile();

    service = module.get<OnboardingService>(OnboardingService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('calculateProgress', () => {
    it('should award the full 100% when every wizard criterion is satisfied', () => {
      const { total, breakdown } = service.calculateProgress(
        buildProfile({
          date_of_birth: '1998-05-14',
          gender: 'male',
          bio: 'Coffee addict, indie vinyl records and sunset runs.',
          liveness_verified: true,
          avatar_object_key: 'avatar_neon_tiger',
          languages: ['English', 'Hindi'],
        }),
        3,
      );

      expect(total).toBe(100);
      expect(breakdown).toEqual({
        nickname: 10,
        date_of_birth: 10,
        gender: 10,
        bio: 20,
        photos: 25,
        liveness: 15,
        avatar: 5,
        languages: 5,
        total: 100,
      });
    });

    it('should score zero for an empty profile', () => {
      const { total, breakdown } = service.calculateProgress({});

      expect(total).toBe(0);
      expect(breakdown.total).toBe(0);
    });

    it('should not award bio points for a bio of ten characters or fewer', () => {
      const { breakdown } = service.calculateProgress(buildProfile({ bio: 'short bio' }));

      expect(breakdown.bio).toBe(0);
    });
  });

  describe('saveWizardStep', () => {
    it('should map the wizard payload onto the canonical profile fields', async () => {
      const result = await service.saveWizardStep({
        user_id: DEMO_USER_ID,
        step: 1,
        nickname: 'Aditya',
        dob: '1998-05-15',
        gender: 'male',
        bio: 'Coffee addict, indie music lover, and late-night talker from Mumbai.',
        city: 'Mumbai',
        languages: ['English', 'Hindi'],
        photo_urls: ['/a.jpg', '/b.jpg', '/c.jpg'],
        liveness_verified: true,
        avatar_object_key: 'avatar_neon_tiger',
      });

      expect(result.success).toBe(true);
      expect(result.step_saved).toBe(1);

      const persisted = upsertProfileMock.mock.calls[0][1];
      expect(persisted).toMatchObject({
        user_id: DEMO_USER_ID,
        nickname: 'Aditya',
        date_of_birth: '1998-05-15',
        gender: 'male',
        bio: expect.stringContaining('Coffee addict'),
        languages: ['English', 'Hindi'],
        avatar_object_key: 'avatar_neon_tiger',
      });
      expect(repository.replacePhotos).toHaveBeenCalledWith(DEMO_USER_ID, [
        '/a.jpg',
        '/b.jpg',
        '/c.jpg',
      ]);
    });

    it('should award the Blue Tick when progress reaches 70% and liveness passed', async () => {
      const result = await service.saveWizardStep({
        user_id: DEMO_USER_ID,
        step: 4,
        nickname: 'Aditya',
        dob: '1998-05-15',
        gender: 'male',
        bio: 'Coffee addict, indie music lover, and late-night talker from Mumbai.',
        photo_urls: ['/a.jpg', '/b.jpg', '/c.jpg'],
        liveness_verified: true,
      });

      expect(result.profile_progress).toBeGreaterThanOrEqual(70);
      expect(result.blue_tick_awarded).toBe(true);

      const persisted = upsertProfileMock.mock.calls[0][1];
      expect(persisted.is_verified).toBe(true);
      expect(persisted.verification_status).toBe('approved');
    });

    it('should not award the Blue Tick when liveness has not passed', async () => {
      const result = await service.saveWizardStep({
        user_id: DEMO_USER_ID,
        step: 4,
        nickname: 'Aditya',
        dob: '1998-05-15',
        gender: 'male',
        bio: 'Coffee addict, indie music lover, and late-night talker from Mumbai.',
        photo_urls: ['/a.jpg', '/b.jpg', '/c.jpg'],
        languages: ['English', 'Hindi'],
        liveness_verified: false,
      });

      expect(result.profile_progress).toBeGreaterThanOrEqual(70);
      expect(result.blue_tick_awarded).toBe(false);

      const persisted = upsertProfileMock.mock.calls[0][1];
      expect(persisted.is_verified).toBeUndefined();
    });
  });

  describe('getStatus', () => {
    it('should throw a NotFoundException when the profile does not exist', async () => {
      await expect(service.getStatus('unknown-user')).rejects.toBeInstanceOf(
        NotFoundException,
      );
    });

    it('should list the actionable missing items', async () => {
      findProfileMock.mockResolvedValueOnce(
        buildProfile({ nickname: 'Arjun' }),
      );

      const status = await service.getStatus(DEMO_USER_ID);

      expect(status.user_id).toBe(DEMO_USER_ID);
      expect(status.is_verified).toBe(false);
      expect(status.missing_items).toEqual(
        expect.arrayContaining([
          'Date of birth',
          'Gender',
          'Bio introduction (> 10 characters)',
          'Upload at least 3 photos (required for discovery deck)',
          'Blink SDK oval face liveness check',
          'Avatar preference',
          'Languages spoken',
        ]),
      );
    });
  });
});
