import { IsNotEmpty, IsOptional, IsString } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class OAuthGoogleDto {
  @ApiProperty({
    example: 'eyJhbGciOi...',
    description: 'Google ID Token from client authentication',
  })
  @IsOptional()
  @IsString()
  id_token?: string;

  @ApiPropertyOptional({
    example: 'ya29.a0AfH6...',
    description: 'Optional Google Access Token',
  })
  @IsOptional()
  @IsString()
  access_token?: string;

  @ApiPropertyOptional({
    example: 'eyJhbGciOi...',
    description: 'CamelCase alias for id_token',
  })
  @IsOptional()
  @IsString()
  idToken?: string;
}

