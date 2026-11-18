/**
 * YoUnMe Dating App — Sign-In Response DTO
 * Returned by POST /v1/auth/signin after the Supabase Auth token is verified.
 */
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class SignInUserDto {
  @ApiProperty({
    example: '11111111-1111-1111-1111-111111111111',
    description: 'Internal PostgreSQL UUID / Supabase UID',
  })
  uid: string;

  @ApiPropertyOptional({
    example: '11111111-1111-1111-1111-111111111111',
    description: 'Internal PostgreSQL UUID',
  })
  id?: string;

  @ApiProperty({
    example: 'user@example.com',
    nullable: true,
    description: 'Verified email claim',
  })
  email?: string;

  @ApiPropertyOptional({ example: '+919820011111' })
  phone?: string;

  @ApiPropertyOptional({ example: 'user' })
  role?: string;
}

export class SignInResponseDto {
  @ApiProperty({ example: true })
  success: boolean;

  @ApiProperty({ example: 'Sign in successful' })
  message: string;

  @ApiProperty({ type: SignInUserDto })
  user: SignInUserDto;

  @ApiPropertyOptional({ description: 'Supabase JWT session data' })
  session?: any;
}
