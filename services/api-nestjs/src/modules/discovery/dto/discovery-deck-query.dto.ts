import { IsOptional, IsString, IsNumberString } from 'class-validator';

export class DiscoveryDeckQueryDto {
  @IsOptional()
  @IsString()
  user_id?: string;

  @IsOptional()
  @IsNumberString()
  radius_km?: string;

  @IsOptional()
  @IsNumberString()
  min_age?: string;

  @IsOptional()
  @IsNumberString()
  max_age?: string;
}
