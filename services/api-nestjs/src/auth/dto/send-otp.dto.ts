import { IsIn, IsNotEmpty, IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class SendOtpDto {
  @ApiProperty({
    example: 'email',
    enum: ['email', 'phone'],
    description: 'Channel type for OTP delivery',
  })
  @IsIn(['email', 'phone'], { message: 'type must be either email or phone' })
  type: 'email' | 'phone';

  @ApiProperty({
    example: 'user@example.com',
    description: 'Target email address or phone number (+919820011111)',
  })
  @IsNotEmpty({ message: 'identifier is required' })
  @IsString()
  identifier: string;
}

