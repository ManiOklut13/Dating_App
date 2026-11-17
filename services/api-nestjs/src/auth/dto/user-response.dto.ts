/**
 * YoUnMe Dating App — Current User Response DTO
 * Returned by GET /v1/auth/me for the currently authenticated Supabase user.
 */
import { ApiProperty } from '@nestjs/swagger';

export class CurrentUserDto {
  @ApiProperty({ example: '11111111-1111-1111-1111-111111111111', description: 'Internal PostgreSQL UUID / Supabase UID' })
  uid: string;

  @ApiProperty({ example: 'user@example.com', nullable: true, description: 'Verified email claim' })
  email?: string;
}

export class CurrentUserResponseDto {
  @ApiProperty({ example: true })
  success: boolean;

  @ApiProperty({ type: CurrentUserDto })
  user: CurrentUserDto;
}
