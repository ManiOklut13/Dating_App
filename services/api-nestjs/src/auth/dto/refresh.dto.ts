import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString } from 'class-validator';

export class RefreshTokenDto {
  @ApiProperty({
    example: 'refresh-token-string-here',
    description: 'Supabase JWT refresh token',
  })
  @IsString()
  @IsNotEmpty()
  refresh_token: string;
}
