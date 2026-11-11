import { IsString, IsOptional } from 'class-validator';

export class SpinWheelDto {
  @IsOptional()
  @IsString()
  user_id?: string;
}
