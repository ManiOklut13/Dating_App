import { IsString, IsNotEmpty, IsOptional, IsIn } from 'class-validator';

export class RecordSwipeDto {
  @IsOptional()
  @IsString()
  actor_id?: string;

  @IsString()
  @IsNotEmpty()
  target_id: string;

  @IsString()
  @IsNotEmpty()
  @IsIn(['like', 'dislike', 'spark', 'snooze'], {
    message: 'action must be one of: like, dislike, spark, snooze',
  })
  action: string;
}
