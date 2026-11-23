import { IsString, IsNotEmpty, IsOptional } from 'class-validator';

export class AddMemoryDto {
  @IsString()
  @IsNotEmpty()
  photo_uri: string;

  @IsString()
  @IsOptional()
  custom_gift_note?: string;

  @IsString()
  @IsOptional()
  user_id?: string;
}

export class GenerateStickersDto {
  @IsString()
  @IsOptional()
  memory_id?: string;

  @IsString()
  @IsOptional()
  prompt?: string;
}

export class ShareChatMemoryDto {
  @IsString()
  @IsNotEmpty()
  memory_id: string;

  @IsString()
  @IsOptional()
  custom_message?: string;
}
