/**
 * YoUnMe Dating App — Chat Message DTO
 * Aligned with 22-table schema v3.2 (chat_messages.room_id / raw_content / message_type).
 */

import { IsIn, IsInt, IsNotEmpty, IsOptional, IsString, IsUUID, Min } from 'class-validator';
import { Type } from 'class-transformer';

export const MESSAGE_TYPES = [
  'text',
  'gif',
  'voice',
  'image',
  'sticker',
  'gift',
  'date_invite',
  'call_log',
  'memory_card',
] as const;

export type MessageType = (typeof MESSAGE_TYPES)[number];

export class SendMessageDto {
  @IsString({ message: 'room_id must be a string' })
  @IsNotEmpty({ message: 'room_id cannot be empty' })
  room_id!: string;

  @IsOptional()
  @IsString({ message: 'sender_id must be a string' })
  sender_id?: string;

  @IsOptional()
  @IsIn(MESSAGE_TYPES as unknown as string[], {
    message: `message_type must be one of: ${MESSAGE_TYPES.join(', ')}`,
  })
  message_type?: MessageType;

  @IsString()
  @IsNotEmpty({ message: 'raw_content cannot be empty' })
  raw_content!: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  vanish_seconds?: number;
}
