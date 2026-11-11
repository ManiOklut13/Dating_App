/**
 * YoUnMe Dating App — Authenticated User Identity
 * Shape of the verified identity attached to the request by SupabaseAuthGuard.
 * Maps Supabase Auth UID and claims directly to app_users PostgreSQL entity.
 */

export interface AuthenticatedUser {
  /** Internal PostgreSQL UUID (app_users.id). */
  id: string;
  /** Supabase Auth UID (app_users.authentication_uid). */
  authentication_uid: string;
  /** Legacy alias for id / authentication_uid for backward compatibility. */
  uid: string;
  /** Verified email claim. */
  email?: string;
  /** Whether email is verified. */
  email_verified?: boolean;
  /** Supabase Auth role (e.g. authenticated, service_role). */
  role?: string;
  /** Supabase Auth audience. */
  aud?: string;
  /** Optional metadata claims from Supabase Auth. */
  app_metadata?: Record<string, any>;
  user_metadata?: Record<string, any>;
}
