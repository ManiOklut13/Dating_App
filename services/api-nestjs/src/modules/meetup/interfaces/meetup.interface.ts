/**
 * YoUnMe Dating App — Meetup & Date Memories Interfaces
 * Aligned strictly with PostgreSQL schema tables "meetup" and "date_memories".
 */

export type MeetupStatus =
  | 'pending'
  | 'scheduled'
  | 'completed'
  | 'cancelled'
  | 'declined'
  | 'missed'
  | 'reported';

export type DateMode = 'online' | 'offline';

export interface SplitBillConfig {
  mode: '50_50' | 'proposer_pays' | 'partner_pays' | 'custom';
  estimated_cost_inr?: number;
  proposer_share_inr?: number;
  partner_share_inr?: number;
  status?: 'proposed' | 'agreed' | 'declined';
}

export interface TodoItem {
  id: string;
  text: string;
  assigned_to?: string;
  is_completed: boolean;
  created_at: string;
}

export interface CoinsJsonTracking {
  free_date_used?: boolean;
  coins_debited?: number;
  debit_tx_id?: string;
  refunded?: boolean;
  refund_status?: string;
  refund_tx_id?: string;
  refund_amount?: number;
  cancellation_fee?: number;
  reschedule_penalties?: Array<{
    user_id: string;
    penalty_coins: number;
    tx_id: string;
    timestamp: string;
  }>;
}

export interface MeetupItem {
  id: string;
  match_id: string;
  proposer_user_id: string;
  partner_user_id: string;
  date_mode: DateMode;
  date_type: string;
  scheduled_start_at: string;
  scheduled_end_at?: string;
  date_started_at?: string;
  date_ended_at?: string;
  reminder_at?: string;
  status: MeetupStatus;
  theme_id?: string;
  split_bill_config: SplitBillConfig;
  dress_code?: string;
  todo_list: TodoItem[];
  proposer_custom_notes?: string;
  partner_custom_notes?: string;
  venue_name?: string;
  osm_place_id?: string;
  latitude?: number;
  longitude?: number;
  coins_json: CoinsJsonTracking;
  proposer_ratings_json?: Record<string, any>;
  partner_ratings_json?: Record<string, any>;
  proposer_overall_rating?: number;
  partner_overall_rating?: number;
  proposer_feedback?: string;
  partner_feedback?: string;
  created_at: string;
  updated_at: string;
  memories?: DateMemory[];
}

export interface DateMemory {
  id: string;
  date_id: string;
  uploaded_by_user_id: string;
  photo_uri: string;
  generated_sticker_uri?: string;
  bitmoji_pack_json?: any[];
  custom_gift_note?: string;
  created_at: string;
}

export interface DateModerationTicket {
  id: string;
  meetup_id: string;
  actor_user_id: string;
  target_user_id: string;
  action_type: 'report';
  action_location: 'online_date' | 'offline_date';
  reason_category: string;
  description: string;
  status: 'open' | 'actioned' | 'dismissed';
  created_at: string;
}
