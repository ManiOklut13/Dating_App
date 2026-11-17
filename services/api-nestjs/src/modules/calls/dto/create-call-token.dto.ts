import { IsString, IsOptional, IsBoolean, IsIn } from 'class-validator';

export class CreateCallTokenDto {
  @IsOptional()
  @IsString()
  caller_id?: string;

  @IsOptional()
  @IsString()
  callee_id?: string;

  @IsOptional()
  @IsIn(['audio', 'video', 'random'])
  kind?: 'audio' | 'video' | 'random';

  @IsOptional()
  @IsBoolean()
  anonymous_avatar?: boolean;

  @IsOptional()
  @IsString()
  match_id?: string;
}
