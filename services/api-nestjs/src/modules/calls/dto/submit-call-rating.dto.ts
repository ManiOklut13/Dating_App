import { IsNumber, IsOptional, IsString, IsBoolean } from 'class-validator';

export class SubmitCallRatingDto {
  @IsNumber()
  rating: number;

  @IsOptional()
  @IsString()
  feedback?: string;

  @IsOptional()
  @IsBoolean()
  is_caller?: boolean;
}
