import {
  IsString,
  IsNotEmpty,
  IsIn,
  IsOptional,
  IsObject,
  IsArray,
  IsNumber,
  IsInt,
  Min,
  Max,
} from 'class-validator';
import { SplitBillConfig } from '../interfaces/meetup.interface.js';

export class CreateMeetupDto {
  @IsString()
  @IsNotEmpty()
  match_id: string;

  @IsString()
  @IsOptional()
  proposer_user_id?: string;

  @IsString()
  @IsNotEmpty()
  partner_user_id: string;

  @IsString()
  @IsIn(['online', 'offline'])
  date_mode: 'online' | 'offline';

  @IsString()
  @IsNotEmpty()
  date_type: string; // 'coffee', 'dinner', 'rooftop', 'movie', 'virtual_watch_party'

  @IsString()
  @IsNotEmpty()
  scheduled_start_at: string;

  @IsString()
  @IsOptional()
  scheduled_end_at?: string;

  @IsString()
  @IsOptional()
  theme_id?: string;

  @IsObject()
  @IsOptional()
  split_bill_config?: SplitBillConfig;

  @IsString()
  @IsOptional()
  venue_name?: string;

  @IsString()
  @IsOptional()
  osm_place_id?: string;

  @IsNumber()
  @IsOptional()
  @Min(-90)
  @Max(90)
  latitude?: number;

  @IsNumber()
  @IsOptional()
  @Min(-180)
  @Max(180)
  longitude?: number;

  @IsString()
  @IsOptional()
  dress_code?: string;

  @IsArray()
  @IsOptional()
  todo_list?: any[];

  @IsString()
  @IsOptional()
  proposer_custom_notes?: string;

  @IsString()
  @IsOptional()
  partner_custom_notes?: string;
}

export class UpdateMeetupDto {
  @IsString()
  @IsOptional()
  scheduled_start_at?: string;

  @IsString()
  @IsOptional()
  scheduled_end_at?: string;

  @IsString()
  @IsOptional()
  venue_name?: string;

  @IsString()
  @IsOptional()
  osm_place_id?: string;

  @IsNumber()
  @IsOptional()
  @Min(-90)
  @Max(90)
  latitude?: number;

  @IsNumber()
  @IsOptional()
  @Min(-180)
  @Max(180)
  longitude?: number;

  @IsString()
  @IsOptional()
  dress_code?: string;

  @IsString()
  @IsOptional()
  theme_id?: string;

  @IsString()
  @IsOptional()
  proposer_custom_notes?: string;

  @IsString()
  @IsOptional()
  partner_custom_notes?: string;

  @IsObject()
  @IsOptional()
  split_bill_config?: SplitBillConfig;
}

export class SubmitMeetupRatingDto {
  @IsInt()
  @Min(1)
  @Max(5)
  rating: number;

  @IsString()
  @IsOptional()
  feedback?: string;

  @IsString()
  @IsOptional()
  user_id?: string;

  @IsObject()
  @IsOptional()
  ratings_json?: Record<string, any>;
}
