import { ApiProperty } from '@nestjs/swagger';
import { UserDto } from './user-response.dto.js';

export class SignInResponseDto {
  @ApiProperty({ example: true, description: 'Operation status' })
  success: boolean;

  @ApiProperty({ example: 'Sign in successful', description: 'Status message' })
  message: string;

  @ApiProperty({ type: UserDto, description: 'Authenticated user profile' })
  user: UserDto;
}
