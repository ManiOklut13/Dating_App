import { IsString, IsNotEmpty, IsOptional } from 'class-validator';

export class RescheduleMeetupDto {
  @IsString()
  @IsNotEmpty()
  new_start_at: string;

  @IsString()
  @IsOptional()
  new_end_at?: string;

  @IsString()
  @IsOptional()
  reason?: string;
}

export class CancelMeetupDto {
  @IsString()
  @IsOptional()
  reason?: string;
}
