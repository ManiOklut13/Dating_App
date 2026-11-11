/**
 * Backward-compatibility type aliases for the server.ts import shim.
 * These mirror the original VisionScanJob and PushNotificationJob shapes.
 */

export type VisionScanJob = {
  asset_id: string;
  user_id: string;
  image_url: string;
  type: 'profile_photo' | 'chat_media' | 'video_call_preview';
};

/**
 * @deprecated No push provider has been selected.
 * The `channel` field cannot be acted upon until FCM or APNs is configured.
 * See notification.processor.ts for the current implementation.
 */
export type PushNotificationJob = {
  recipient_id: string;
  title: string;
  body: string;
  data: Record<string, unknown>;
  channel: 'fcm' | 'apns';
};
