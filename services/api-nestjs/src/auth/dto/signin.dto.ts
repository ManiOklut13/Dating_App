import { IsEmail, IsOptional, IsString, MinLength } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class SignInDto {
  @ApiPropertyOptional({
    example: 'user@example.com',
    description: 'User registered email',
  })
  @IsOptional()
  @IsEmail({}, { message: 'Must provide a valid email address' })
  email?: string;

  @ApiPropertyOptional({
    example: 'Secr3tP@ss!',
    description: 'User password (min 6 characters)',
  })
  @IsOptional()
  @IsString()
  @MinLength(6, { message: 'Password must be at least 6 characters long' })
  password?: string;
}

