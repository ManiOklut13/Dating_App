import { IsString, IsOptional, IsNumber } from 'class-validator';

export class RequestPayoutDto {
  @IsOptional()
  @IsString()
  user_id?: string;

  @IsOptional()
  coins_to_withdraw?: number | string;

  @IsOptional()
  @IsString()
  upi_id?: string;

  @IsOptional()
  @IsString()
  idempotency_key?: string;
}
