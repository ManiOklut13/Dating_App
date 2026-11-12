export type Route =
  | 'welcome'
  | 'login'
  | 'signup'
  | 'recover'
  | 'verify'
  | 'home'
  | `onboarding/${string}`
  | `/onboarding/${string}`;

export type SignupMethod = 'email' | 'mobile' | 'google';

export type PermState = 'not_requested' | 'allowed' | 'denied' | 'unavailable';

export type VisibilityOption = 'everyone' | 'limited' | 'hidden';
export type MessageOption = 'everyone' | 'matches' | 'nobody';
export type ThemeChoice = 'light' | 'dark' | 'system';

export interface PhotoItem {
  id: string;
  url: string;
  name: string;
}

export interface AvatarConfig {
  base: string;
  skin: string;
  outfit: string;
  accessory: string;
}

export interface NotificationPrefs {
  messages: boolean;
  likes: boolean;
  matches: boolean;
  requests: boolean;
  calls: boolean;
  rewards: boolean;
  email: boolean;
  push: boolean;
}

export interface OnboardingState {
  /* Account creation */
  method: SignupMethod;
  email: string;
  countryCode: string;
  phone: string;
  password: string;
  confirmPassword: string;
  acceptedTerms: boolean;
  destinationType: 'email' | 'mobile';
  destination: string;

  /* Basic profile */
  firstName: string;
  dob: string;
  gender: string;
  genderSelf: string;
  orientation: string;
  orientationSelf: string;

  /* Photo & avatar */
  photos: PhotoItem[];
  avatar: AvatarConfig | null;

  /* Discovery preferences */
  lookingFor: string[];
  interestedIn: string;
  ageMin: number;
  ageMax: number;
  distanceKm: number;
  languages: string[];

  /* Interests */
  interests: string[];
  customInterests: string[];

  /* Profile enrichment */
  bio: string;
  profession: string;
  education: string;
  city: string;

  /* Permissions */
  permissions: Record<'notifications' | 'contacts' | 'microphone' | 'camera', PermState>;

  /* Safety */
  visibility: VisibilityOption;
  showOnlineStatus: boolean;
  whoCanMessage: MessageOption;

  /* Notifications & theme */
  notifications: NotificationPrefs;
  theme: ThemeChoice;

  completed: boolean;
}

/* ---------- Configurable frontend constants ---------- */

export const MIN_AGE = 18;
export const MAX_PHOTOS = 5;
export const MIN_PHOTOS = 1;
export const MOCK_OTP = '123456';
export const OTP_RESEND_SECONDS = 30;

export const AGE_RANGE_MIN = 18;
export const AGE_RANGE_MAX = 60;
export const DISTANCE_MIN = 1;
export const DISTANCE_MAX = 100;

/** Mock credentials for the simulated login (frontend demo only). */
export const MOCK_CREDENTIALS = {
  email: 'alex.demo@younme.app',
  phone: '9876543210',
  password: 'Demo@1234',
};

export const PROFILE_COMPLETION_THRESHOLD = 70;

export interface StepMeta {
  id: string;
  route: string;
  label: string;
  optional?: boolean;
}

export const ONBOARDING_STEPS: StepMeta[] = [
  { id: 'basic-profile', route: '/onboarding/basic-profile', label: 'About you' },
  { id: 'photo-avatar', route: '/onboarding/photo-avatar', label: 'Photos & avatar' },
  { id: 'preferences', route: '/onboarding/preferences', label: 'Discovery preferences' },
  { id: 'interests', route: '/onboarding/interests', label: 'Interests', optional: true },
  { id: 'profile-details', route: '/onboarding/profile-details', label: 'Your profile' },
  { id: 'location', route: '/onboarding/location', label: 'Location' },
  { id: 'permissions', route: '/onboarding/permissions', label: 'Permissions', optional: true },
  { id: 'safety', route: '/onboarding/safety', label: 'Safety' },
  { id: 'chat-safety', route: '/onboarding/chat-safety', label: 'Safe chat preview' },
  { id: 'notifications', route: '/onboarding/notifications', label: 'Notifications & theme' },
  { id: 'complete', route: '/onboarding/complete', label: 'All set' },
];

export const KNOWN_ROUTES: string[] = [
  'welcome',
  'login',
  'signup',
  'recover',
  'verify',
  'home',
  ...ONBOARDING_STEPS.map((s) => s.route),
];
