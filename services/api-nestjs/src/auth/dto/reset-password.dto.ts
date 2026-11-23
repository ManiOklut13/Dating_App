import { IsIn, IsNotEmpty, IsOptional, IsString, MinLength } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class ResetPasswordDto {
  @ApiProperty({
    example: 'NewStr0ngP@ss!',
    description: 'New password (min 6 characters)',
  })
  @IsNotEmpty({ message: 'new_password is required' })
  @IsString()
  @MinLength(6, { message: 'new_password must be at least 6 characters long' })
  new_password: string;

  @ApiPropertyOptional({
    example: 'reset-token-or-otp',
    description: 'Reset token or OTP',
  })
  @IsOptional()
  @IsString()
  token?: string;

  @ApiPropertyOptional({
    example: 'user@example.com',
    description: 'User email or phone',
  })
  @IsOptional()
  @IsString()
  identifier?: string;

  @ApiPropertyOptional({ example: 'email', enum: ['email', 'phone'] })
  @IsOptional()
  @IsIn(['email', 'phone'])
  type?: 'email' | 'phone';
}

