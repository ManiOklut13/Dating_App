/**
 * YoUnMe Dating App — Plan Date DTO
 * Aligned with 22-table schema v3.2 (meets, dates, wallets, coin transactions).
 */

import { IsUUID, IsString, IsOptional, IsInt, Min, IsBoolean, IsEnum, IsDate, IsNotEmpty } from 'class-validator';
import { Type } from 'class-transformer';

export enum DateStatus {
  pending = 'pending',
  accepted = 'accepted',
  rejected = 'rejected',
  cancelled = 'cancelled',
  completed = 'completed',
}

export enum DateType {
  virtual = 'virtual',
  offline = 'offline',
}

export interface DatePlanRecord {
  id: string;
  proposer_user_id: string;
  target_user_id: string;
  date_type: DateType;
  start_time: string;
  end_time: string;
  location?: string;
  activity?: string;
  status: DateStatus;
  coins_required?: number;
  coins_deducted?: number;
  free_date_pass_used: boolean;
  created_at: string;
  updated_at?: string;
  accepted_at?: string;
  rejected_at?: string;
  refunded_coins?: number;
  cancelled_at?: string;
}

export class PlanDateDto {
  @IsUUID()
  @IsNotEmpty({ message: 'proposer_user_id cannot be empty' })
  proposer_user_id!: string;

  @IsUUID()
  @IsNotEmpty({ message: 'target_user_id cannot be empty' })
  target_user_id!: string;

  @IsEnum(DateType, {
    message: `date_type must be one of: ${Object.values(DateType).join(', ')}`,
  })
  @IsNotEmpty({ message: 'date_type cannot be empty' })
  date_type!: DateType;

  @IsDate()
  @IsNotEmpty({ message: 'start_time cannot be empty' })
  start_time!: Date;

  @IsDate()
  @IsNotEmpty({ message: 'end_time cannot be empty' })
  end_time!: Date;

  @IsString()
  @IsOptional()
  location?: string;

  @IsString()
  @IsOptional()
  activity?: string;

  @IsInt()
  @Min(0)
  @IsOptional()
  coins_required?: number;

  @IsBoolean()
  @IsOptional()
  use_free_date_pass?: boolean;
}