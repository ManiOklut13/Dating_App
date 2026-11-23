import { IsOptional, IsString } from 'class-validator';

export class RandomMatchDto {
  @IsOptional()
  @IsString()
  user_id?: string;

  @IsOptional()
  @IsString()
  kind?: string;
}
