import { IsIn, IsNotEmpty, IsOptional, IsString } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class ForgotPasswordDto {
  @ApiPropertyOptional({
    example: 'email',
    enum: ['email', 'phone'],
    description: 'Channel type',
  })
  @IsOptional()
  @IsIn(['email', 'phone'])
  type?: 'email' | 'phone';

  @ApiProperty({
    example: 'user@example.com',
    description: 'User registered email or phone',
  })
  @IsNotEmpty({ message: 'identifier is required' })
  @IsString()
  identifier: string;
}

