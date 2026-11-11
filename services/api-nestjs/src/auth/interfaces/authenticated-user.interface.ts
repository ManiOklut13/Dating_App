export interface AuthenticatedUser {
  /** Supabase auth.users.id (UUID). Replaces the Firebase `uid`. */
  id: string;
  email?: string;
  phone?: string;
  role?: string;
  session_id?: string;
}
