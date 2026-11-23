/**
 * YoUnMe Dating App — Current User Response DTO
 * Returned by GET /v1/auth/me for the currently authenticated Supabase user.
 */
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CurrentUserDto {
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

  @ApiPropertyOptional({ example: 'active' })
  account_status?: string;
}

export class CurrentUserResponseDto {
  @ApiProperty({ example: true })
  success: boolean;

  @ApiProperty({ type: CurrentUserDto })
  user: CurrentUserDto;

  @ApiPropertyOptional({ description: 'Complete user profile attributes' })
  profile?: Record<string, any>;

  @ApiPropertyOptional({ description: 'User wallet balance and streak statistics' })
  wallet?: Record<string, any>;

  @ApiPropertyOptional({ description: 'User app and privacy settings' })
  settings?: Record<string, any>;

  @ApiPropertyOptional({ description: 'User uploaded photos' })
  photos?: any[];
}
