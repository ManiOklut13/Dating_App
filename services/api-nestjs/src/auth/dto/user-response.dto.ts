import { ApiProperty } from '@nestjs/swagger';

export class UserDto {
  @ApiProperty({
    example: '11111111-1111-1111-1111-111111111111',
    description: 'Supabase user id (auth.users.id)',
  })
  id: string;

  @ApiProperty({ example: 'user@example.com', description: 'Verified user email', required: false })
  email?: string;

  @ApiProperty({
    example: '+919820011111',
    description: 'Verified user phone number',
    required: false,
  })
  phone?: string;
}

export class CurrentUserResponseDto {
  @ApiProperty({ example: true, description: 'Operation status' })
  success: boolean;

  @ApiProperty({ type: UserDto, description: 'Authenticated user profile' })
  user: UserDto;
}
