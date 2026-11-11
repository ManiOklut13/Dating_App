import { IsString, IsOptional } from 'class-validator';

export class RevertSwipeDto {
  @IsOptional()
  @IsString()
  user_id?: string;
}
