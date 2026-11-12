export interface ProfilePhoto {
  id: string;
  url: string;
  isPrimary: boolean;
  caption?: string;
}

export interface DatingPreferences {
  lookingFor: 'Dating' | 'Friendship' | 'New Friends' | 'Both Dating and Friendship';
  interestedIn: 'Men' | 'Women' | 'Non-binary people' | 'Everyone';
  ageRange: [number, number]; // e.g. [21, 32]
  distanceRangeKm: number; // e.g. 30
  preferredLanguages: string[];
  activities: string[];
}

export interface VerificationData {
  status: 'verified' | 'not_verified' | 'in_progress' | 'requires_review';
  verifiedAt?: string;
  faceVerified: boolean;
  voiceVerified: boolean;
  livenessScore?: number;
}

export interface BlockedUser {
  id: string;
  name: string;
  avatar: string;
  blockedAt: string;
}

export interface RestrictedUser {
  id: string;
  name: string;
  avatar: string;
  restrictedAt: string;
}

export interface HiddenWordsSettings {
  /** Filter offensive words from comments and captions. */
  filterOffensive: boolean;
  /** Filter offensive words inside direct message requests. */
  filterMessages: boolean;
  /** Custom words / phrases the member wants hidden. */
  words: string[];
}

export interface PrivacySettings {
  visibility: 'everyone' | 'limited' | 'hidden';
  /** Private account — only approved followers can see posts. */
  privateAccount: boolean;
  showOnlineStatus: boolean;
  /** Show when you and someone you follow are active at the same time. */
  showActiveTogether: boolean;
  /** Whether others can see when you have read their messages. */
  readReceipts: boolean;
  whoCanMessageMe: 'everyone' | 'matches' | 'nobody';
  /** How incoming message requests are handled. */
  messageRequests: 'deliver' | 'filter' | 'nobody';
  /** Who can add this member to group conversations. */
  groupMessages: 'everyone' | 'following' | 'followers' | 'nobody';
  hiddenWords: HiddenWordsSettings;
  contactSharingUnlocked: boolean;
  blockedUsers: BlockedUser[];
  restrictedUsers: RestrictedUser[];
}

export interface ActiveSession {
  id: string;
  device: string;
  location: string;
  lastActive: string;
  isCurrent: boolean;
}

export interface NotificationPrefs {
  push: boolean;
  email: boolean;
  matches: boolean;
  messages: boolean;
  promotions: boolean;
  /** Pause everything at once (overrides the individual switches). */
  pauseAll: boolean;
  likes: boolean;
  comments: boolean;
  calls: boolean;
  mentions: boolean;
  live: boolean;
  sms: boolean;
}

export interface SecuritySettings {
  twoFactorEnabled: boolean;
  activeSessions: ActiveSession[];
  /** Keep this device signed in between sessions. */
  savedLoginInfo: boolean;
  /** Email / push alerts when the account is used on a new device. */
  securityAlerts: boolean;
}

export interface AccountSettingsData {
  email: string;
  phone: string;
  notifications: NotificationPrefs;
  security: SecuritySettings;
  appTheme: 'dark' | 'light';
  language: string;
}

export interface UserNotification {
  id: string;
  title: string;
  description: string;
  timestamp: string;
  type: 'match' | 'like' | 'date' | 'reward';
  unread: boolean;
}

export interface UserProfileData {
  id: string;
  nickname: string;
  dateOfBirth: string; // YYYY-MM-DD
  gender: 'Man' | 'Woman' | 'Non-binary' | 'Prefer not to say' | string;
  sexualOrientation: 'Straight' | 'Gay' | 'Lesbian' | 'Bisexual' | 'Queer' | string;
  location: string;
  neighborhood: string;
  distanceKm: number;
  bio: string;
  profession: string;
  company?: string;
  education: string;
  languages: string[];
  personalPrompt: {
    question: string;
    answer: string;
  };
  photos: ProfilePhoto[];
  interests: string[];
  customInterests: string[];
  preferences: DatingPreferences;
  verification: VerificationData;
  privacy: PrivacySettings;
  settings: AccountSettingsData;
  isDeactivated: boolean;
  coinsBalance: number;
  notifications: UserNotification[];
}
