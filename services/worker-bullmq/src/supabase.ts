/**
 * YoUnMe Worker — Supabase Client (Service-Role)
 *
 * This client uses the service-role key and must remain strictly server-side.
 * It is used only for persisting moderation outcomes and audit records.
 *
 * If Supabase credentials are not configured (dev/test without creds),
 * the client is null and processors fall back to logging-only mode.
 */

import { createClient, type SupabaseClient } from '@supabase/supabase-js';
import { env, supabaseConfigured } from './config.js';

let _supabase: SupabaseClient | null = null;

export function getSupabaseClient(): SupabaseClient | null {
  if (_supabase) return _supabase;

  if (!supabaseConfigured) {
    return null;
  }

  _supabase = createClient(env.SUPABASE_URL!, env.SUPABASE_SERVICE_ROLE_KEY!, {
    auth: {
      // Service-role clients must not use session-based auth
      persistSession: false,
      autoRefreshToken: false,
      detectSessionInUrl: false,
    },
  });

  return _supabase;
}
