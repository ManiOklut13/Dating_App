import { IsIn, IsNotEmpty, IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class VerifyOtpDto {
  @ApiProperty({
    example: 'email',
    enum: ['email', 'phone'],
    description: 'Channel type for OTP',
  })
  @IsIn(['email', 'phone'], { message: 'type must be either email or phone' })
  type: 'email' | 'phone';

  @ApiProperty({
    example: 'user@example.com',
    description: 'Target email or phone number',
  })
  @IsNotEmpty({ message: 'identifier is required' })
  @IsString()
  identifier: string;

  @ApiProperty({
    example: '123456',
    description: '6-digit OTP token received by user',
  })
  @IsNotEmpty({ message: 'token is required' })
  @IsString()
  token: string;
}

