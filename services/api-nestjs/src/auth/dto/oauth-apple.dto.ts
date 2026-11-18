import { IsNotEmpty, IsOptional, IsString } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class OAuthAppleDto {
  @ApiProperty({
    example: 'eyJraWQiOi...',
    description: 'Apple Identity Token',
  })
  @IsOptional()
  @IsString()
  id_token?: string;

  @ApiPropertyOptional({
    example: 'nonce-12345',
    description: 'Cryptographic nonce for verification',
  })
  @IsOptional()
  @IsString()
  nonce?: string;

  @ApiPropertyOptional({
    example: 'eyJraWQiOi...',
    description: 'CamelCase alias for id_token',
  })
  @IsOptional()
  @IsString()
  idToken?: string;
}

