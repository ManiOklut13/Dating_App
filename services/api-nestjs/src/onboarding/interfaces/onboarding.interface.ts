/**
 * YoUnMe Dating App — Onboarding & Verification Domain Interfaces
 * Defines user entities, profile state, 8-step scoring, and repository contracts.
 * Updated to align with 24-table schema v3.2 (app_users + user_profiles).
 */

export type Gender = 'male' | 'female' | 'non_binary' | 'other';
export type AccountStatus = 'active' | 'deactivated' | 'restricted' | 'suspended' | 'deletion_pending' | 'deleted';

/**
 * Core User Account attributes (maps to PostgreSQL `app_users` table)
 * Account level only — demographic and verification attributes live on `user_profiles`.
 */
export interface IUserAttributes {
  id: string;
  authentication_uid: string;          // Supabase Auth UID
  email: string;
  email_verified: boolean;
  phone_country_code: string;
  phone_number: string;
  full_phone_number?: string;
  phone_verified: boolean;
  google_sso_id?: string;
  apple_sso_id?: string;
  password_hash?: string;
  account_status: AccountStatus;
  deactivation_reason?: string;
  deletion_reason?: string;
  deactivated_at?: string;
  deletion_scheduled_at?: string;
  reactivate_after?: string;
  role: 'user' | 'moderator' | 'admin';
  referral_code?: string;
  referred_by_user_id?: string;
  created_at: string;
  updated_at: string;
  deleted_at?: string;
}

/**
 * Detailed Profile attributes (maps to PostgreSQL `user_profiles` table + PostGIS GEOGRAPHY)
 */
export interface IProfileState {
  user_id: string;
  first_name?: string;
  nickname: string;
  date_of_birth?: string;
  gender?: Gender;
  sexual_orientations: string[];
  looking_for: string[];
  languages: string[];
  interests: string[];
  bio?: string;
  profession?: string;
  education?: string;
  city?: string;
  country_code?: string;
  avatar_object_key?: string;
  random_avatar_object_key?: string;
  app_language: string;
  app_theme: string;
  chat_lock_passcode_hash?: string;
  read_receipts_status: boolean;
  profile_visibility: 'everyone' | 'limited' | 'hidden';
  show_online_status: boolean;
  who_can_message: 'everyone' | 'matches' | 'nobody';
  who_can_message_request: 'everyone' | 'matches' | 'nobody';
  push_notifications_enabled: boolean;
  push_notifications: Record<string, any>;
  email_notifications_enabled: boolean;
  email_notifications: Record<string, any>;
  min_age?: number;
  max_age?: number;
  max_distance_km?: number;
  is_verified: boolean;
  verification_status: 'not_started' | 'pending' | 'approved' | 'rejected' | 'manual_review';
  is_voice_verified: boolean;
  liveness_verified: boolean;
  face_embedding_vector?: number[];
  profile_progress: number;
  // GEOGRAPHY(POINT,4326) represented as raw coordinates in-memory
  location?: { lat: number; lng: number };
  location_updated_at?: string;
  last_active_at?: string;
  created_at: string;
  updated_at: string;
}

/**
 * Breakdown of points scored across the 8 onboarding criteria
 */
export interface IProgressBreakdown {
  nickname: number;        // 10 pts
  date_of_birth: number;   // 10 pts
  gender: number;          // 10 pts
  bio: number;             // 20 pts (length > 10 chars)
  photos: number;          // 25 pts (min 1 photo, 3 recommended)
  liveness: number;        // 15 pts (Blink SDK oval facial scan)
  avatar: number;          // 5 pts
  languages: number;       // 5 pts
  total: number;           // Capped at 100%
}

/**
 * Payload response for GET /v1/onboarding/status/:userId
 */
export interface IOnboardingStatusResponse {
  user_id: string;
  progress: number;
  is_verified: boolean;
  missing_items: string[];
  breakdown: IProgressBreakdown;
}

/**
 * Payload response for POST /v1/onboarding/wizard
 */
export interface IWizardResponse {
  success: boolean;
  step_saved?: number | string;
  profile_progress: number;
  blue_tick_awarded: boolean;
  profile: IProfileState;
  user?: IUserAttributes;
  breakdown: IProgressBreakdown;
}

/**
 * Repository contract abstraction.
 * Enables zero-friction swapping between in-memory mock engine and live PostgreSQL / Supabase pool.
 */
export interface IOnboardingRepository {
  findUserById(userId: string): Promise<IUserAttributes | null>;
  findProfileByUserId(userId: string): Promise<IProfileState | null>;
  upsertProfile(userId: string, partial: Partial<IProfileState>): Promise<IProfileState>;
  updateUser(userId: string, partial: Partial<IUserAttributes>): Promise<IUserAttributes | null>;
  replacePhotos(userId: string, photoUrls: string[]): Promise<void>;
  countPhotos(userId: string): Promise<number>;
}
