/**
 * YoUnMe Dating App — Record Message Request DTO
 * Aligned with 22-table schema v3.2 (swipes_interactions → is_message_request / message_request_id).
 */

import { IsIn, IsNotEmpty, IsOptional, IsUUID, IsString } from 'class-validator';
import { Type } from 'class-transformer';

export class RecordMessageRequestDto {
  @IsUUID()
  @IsNotEmpty({ message: 'request_id cannot be empty' })
  request_id!: string;

  @IsIn(['crush', 'like', 'dislike'])
  @IsNotEmpty({ message: 'action cannot be empty' })
  action!: 'crush' | 'like' | 'dislike';

  @IsString()
  @IsOptional()
  notes?: string;
}