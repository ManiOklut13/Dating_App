import { IsOptional, IsNumber, IsString } from 'class-validator';

export class EndCallDto {
  @IsOptional()
  @IsNumber()
  rating?: number;

  @IsOptional()
  @IsString()
  feedback?: string;

  @IsOptional()
  @IsString()
  reason?: string;
}
