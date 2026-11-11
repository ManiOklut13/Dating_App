import { IsString, IsNotEmpty, IsOptional } from 'class-validator';

export class ReportMeetupDto {
  @IsString()
  @IsNotEmpty()
  reason_category: string;

  @IsString()
  @IsNotEmpty()
  description: string;

  @IsString()
  @IsOptional()
  actor_user_id?: string;
}
