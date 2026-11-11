import { IsString, IsNotEmpty, IsOptional } from 'class-validator';

export class AddMemoryDto {
  @IsString()
  @IsOptional()
  user_id?: string;

  @IsString()
  @IsNotEmpty()
  photo_uri: string;

  @IsString()
  @IsOptional()
  custom_note?: string;
}
