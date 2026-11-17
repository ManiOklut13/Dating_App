import { IsString, IsOptional } from 'class-validator';

export class PurchasePackageDto {
  @IsOptional()
  @IsString()
  user_id?: string;

  @IsOptional()
  @IsString()
  package_id?: string;

  @IsOptional()
  @IsString()
  pack_id?: string;

  @IsOptional()
  @IsString()
  razorpay_payment_id?: string;

  @IsOptional()
  @IsString()
  idempotency_key?: string;
}
