import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:younme_mobile/models/chat_profile_models.dart';
import 'package:younme_mobile/services/network_service.dart';
import 'package:younme_mobile/services/auth_dto.dart';

class ProfileService {
  final NetworkService _network = NetworkService();

  /// GET /v1/auth/me - Fetch logged-in user's complete profile, wallet balance, and settings
  Future<CurrentUserResponseDto> getCurrentUser() async {
    final response = await _network.dio.get(
      '/v1/auth/me',
    );
    return CurrentUserResponseDto.fromJson(response.data);
  }

  /// PUT /v1/profile/me - Updates personal bio, job, and preferences
  Future<ProfileUpdateResponse> updateProfile(
      {required String bio,
      required String? profession,
      required String? job,
      required String? education,
      required String? city,
      required String? countryCode,
      required List<String>? interests,
      required List<String>? languages,
      required List<String>? lookingFor,
      required List<String>? sexualOrientations,
      required int? minAge,
      required int? maxAge,
      required int? maxDistanceKm,
      required String? profileVisibility,
      required String? whoCanMessage,
      required String? whoCanMessageRequest,
      required bool? showOnlineStatus,
      required bool? readReceiptsStatus,
      required String? appLanguage,
      required String? appTheme,
      required bool? pushNotificationsEnabled,
      required bool? emailNotificationsEnabled}) async {
    final response = await _network.dio.put(
      '/v1/profile/me',
      data: {
        'bio': bio,
        'profession': profession,
        'job': job,
        'education': education,
        'city': city,
        'country_code': countryCode,
        'interests': interests,
        'languages': languages,
        'looking_for': lookingFor,
        'sexual_orientations': sexualOrientations,
        'min_age': minAge,
        'max_age': maxAge,
        'max_distance_km': maxDistanceKm,
        'profile_visibility': profileVisibility,
        'who_can_message': whoCanMessage,
        'who_can_message_request': whoCanMessageRequest,
        'show_online_status': showOnlineStatus,
        'read_receipts_status': readReceiptsStatus,
        'app_language': appLanguage,
        'app_theme': appTheme,
        'push_notifications_enabled': pushNotificationsEnabled,
        'email_notifications_enabled': emailNotificationsEnabled,
      },
    );
    return ProfileUpdateResponse.fromJson(response.data);
  }

  /// POST /v1/profile/photos - Handles multipart image uploads (2-6 images)
  /// Note: Multipart form data requires special Dio handling
  Future<PhotoUploadResponse> uploadPhotos(List<int> files, String userId) async {
    final formData = FormData.fromMap({
      'photos': files.map((file) => MapEntry('file', file)).toList(),
    });

    final response = await _network.dio.post(
      '/v1/profile/photos',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return PhotoUploadResponse.fromJson(response.data);
  }

  /// POST /v1/profile/verify-biometrics - Handles voice/liveness verification flags and Bitmoji generation data
  Future<BiometricsVerifyResponse> verifyBiometrics({
    required String userId,
    required bool isVoiceVerified,
    required bool livenessVerified,
    required String verificationStatus,
    required String avatarObjectKey,
    required num livenessScore,
    required String? voiceSampleUrl,
    required Map<String, dynamic>? bitmojiData,
  }) async {
    final response = await _network.dio.post(
      '/v1/profile/verify-biometrics',
      data: {
        'user_id': userId,
        'is_voice_verified': isVoiceVerified,
        'liveness_verified': livenessVerified,
        'verification_status': verificationStatus,
        'avatar_object_key': avatarObjectKey,
        'liveness_score': livenessScore,
        'voice_sample_url': voiceSampleUrl,
        'bitmoji_data': bitmojiData,
      },
    );
    return BiometricsVerifyResponse.fromJson(response.data);
  }

  /// GET /v1/users/:targetUserId - Fetches another user's public profile with strict visibility masking
  Future<PublicUserProfileResponse> getPublicUserProfile(String targetUserId) async {
    final response = await _network.dio.get(
      '/v1/users/$targetUserId',
    );
    return PublicUserProfileResponse.fromJson(response.data);
  }

  /// PATCH /v1/profile/photos/:photoId - Update photo caption/metadata
  Future<PhotoMetadataUpdateResponse> updatePhotoMetadata({
    required String photoId,
    required String caption,
  }) async {
    final response = await _network.dio.patch(
      '/v1/profile/photos/$photoId',
      data: {
        'caption': caption,
      },
    );
    return PhotoMetadataUpdateResponse.fromJson(response.data);
  }

  /// DELETE /v1/profile/photos/:photoId - Delete a photo
  Future<PhotoDeleteResponse> deletePhoto(String photoId) async {
    final response = await _network.dio.delete(
      '/v1/profile/photos/$photoId',
    );
    return PhotoDeleteResponse.fromJson(response.data);
  }
}