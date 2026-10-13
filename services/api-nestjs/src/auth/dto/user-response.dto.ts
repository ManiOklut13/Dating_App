import { ApiProperty } from '@nestjs/swagger';

export class UserDto {
  @ApiProperty({ example: 'verified-firebase-uid', description: 'Verified Firebase UID' })
  uid: string;

  @ApiProperty({ example: 'user@example.com', description: 'Verified user email', required: false })
  email?: string;
}

export class CurrentUserResponseDto {
  @ApiProperty({ example: true, description: 'Operation status' })
  success: boolean;

  @ApiProperty({ type: UserDto, description: 'Authenticated user profile' })
  user: UserDto;
}
