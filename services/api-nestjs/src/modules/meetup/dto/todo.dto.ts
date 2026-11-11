import { IsString, IsNotEmpty, IsOptional, IsBoolean } from 'class-validator';

export class CreateTodoDto {
  @IsString()
  @IsNotEmpty()
  text: string;

  @IsString()
  @IsOptional()
  assigned_to?: string;
}

export class UpdateTodoDto {
  @IsString()
  @IsOptional()
  text?: string;

  @IsString()
  @IsOptional()
  assigned_to?: string;

  @IsBoolean()
  @IsOptional()
  is_completed?: boolean;
}
