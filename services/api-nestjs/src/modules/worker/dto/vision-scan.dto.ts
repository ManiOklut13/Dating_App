import { IsString, IsNotEmpty, IsIn } from 'class-validator';

export class VisionScanDto {
  @IsString()
  @IsNotEmpty()
  asset_id: string;

  @IsString()
  @IsNotEmpty()
  user_id: string;

  @IsString()
  @IsNotEmpty()
  image_url: string;

  @IsString()
  @IsIn(['profile_photo', 'chat_media', 'video_call_preview'])
  type: 'profile_photo' | 'chat_media' | 'video_call_preview';
}
