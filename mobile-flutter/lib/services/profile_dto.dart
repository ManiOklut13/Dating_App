// ignore_for_file: prefer_const_constructors, unused_import

/// Current user response DTO mapping to GET /v1/auth/me
class CurrentUserResponseDto {
  final bool success;
  final CurrentUserDto user;
  final ProfileDto? profile;
  final WalletDto? wallet;
  final SettingsDto? settings;
  final List<PhotoDto>? photos;

  CurrentUserResponseDto({
    required this.success,
    required this.user,
    this.profile,
    this.wallet,
    this.settings,
    this.photos,
  });

  factory CurrentUserResponseDto.fromJson(Map<String, dynamic> json) {
    return CurrentUserResponseDto(
      success: json['success'] as bool,
      user: CurrentUserDto.fromJson(json['user'] as Map<String, dynamic>),
      profile: json['profile'] != null
          ? ProfileDto.fromJson(json['profile'] as Map<String, dynamic>)
          : null,
      wallet: json['wallet'] != null
          ? WalletDto.fromJson(json['wallet'] as Map<String, dynamic>)
          : null,
      settings: json['settings'] != null
          ? SettingsDto.fromJson(json['settings'] as Map<String, dynamic>)
          : null,
      photos: (json['photos'] as List?)
          ?.map((photo) => PhotoDto.fromJson(photo as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Current user DTO
class CurrentUserDto {
  final String uid;
  final String id;
  final String email;
  final String phone;
  final String role;
  final String accountStatus;

  CurrentUserDto({
    required this.uid,
    required this.id,
    required this.email,
    required this.phone,
    required this.role,
    required this.accountStatus,
  });

  factory CurrentUserDto.fromJson(Map<String, dynamic> json) {
    return CurrentUserDto(
      uid: json['uid'] as String,
      id: json['id'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      role: json['role'] as String,
      accountStatus: json['account_status'] as String,
    );
  }
}

/// Profile DTO from /v1/auth/me
class ProfileDto {
  final String nickname;
  final String? firstName;
  final DateTime? dateOfBirth;
  final String? gender;
  final List<String> sexualOrientations;
  final List<String> lookingFor;
  final List<String> languages;
  final List<String> interests;
  final String? bio;
  final String? profession;
  final String? education;
  final String? city;
  final String? countryCode;
  final bool isVerified;
  final String verificationStatus;
  final bool isVoiceVerified;
  final bool livenessVerified;
  final num profileProgress;
  final String? avatarObjectKey;
  final String? location;

  ProfileDto({
    required this.nickname,
    this.firstName,
    this.dateOfBirth,
    this.gender,
    required this.sexualOrientations,
    required this.lookingFor,
    required this.languages,
    required this.interests,
    this.bio,
    this.profession,
    this.education,
    this.city,
    this.countryCode,
    required this.isVerified,
    required this.verificationStatus,
    required this.isVoiceVerified,
    required this.livenessVerified,
    required this.profileProgress,
    this.avatarObjectKey,
    this.location,
  });

  factory ProfileDto.fromJson(Map<String, dynamic> json) {
    return ProfileDto(
      nickname: json['nickname'] as String,
      firstName: json['first_name'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      gender: json['gender'] as String?,
      sexualOrientations: (json['sexual_orientations'] as List?)
          .map((e) => e as String)
          .toList(),
      lookingFor: (json['looking_for'] as List?)
          .map((e) => e as String)
          .toList(),
      languages: (json['languages'] as List?)
          .map((e) => e as String)
          .toList(),
      interests: (json['interests'] as List?)
          .map((e) => e as String)
          .toList(),
      bio: json['bio'] as String?,
      profession: json['profession'] as String?,
      education: json['education'] as String?,
      city: json['city'] as String?,
      countryCode: json['country_code'] as String?,
      isVerified: json['is_verified'] as bool,
      verificationStatus: json['verification_status'] as String,
      isVoiceVerified: json['is_voice_verified'] as bool,
      livenessVerified: json['liveness_verified'] as bool,
      profileProgress: (json['profile_progress'] as num).toDouble(),
      avatarObjectKey: json['avatar_object_key'] as String?,
      location: json['location'] as String?,
    );
  }
}

/// Wallet DTO from /v1/auth/me
class WalletDto {
  final int coinBalance;
  final int lockedCoins;
  final int lifetimeEarnedCoins;
  final int lifetimeSpentCoins;
  final int currentStreakDays;
  final int longestStreakDays;
  final DateTime? lastClaimedDate;

  WalletDto({
    required this.coinBalance,
    required this.lockedCoins,
    required this.lifetimeEarnedCoins,
    required this.lifetimeSpentCoins,
    required this.currentStreakDays,
    required this.longestStreakDays,
    this.lastClaimedDate,
  });

  factory WalletDto.fromJson(Map<String, dynamic> json) {
    return WalletDto(
      coinBalance: (json['coin_balance'] as num).toInt(),
      lockedCoins: (json['locked_coins'] as num).toInt(),
      lifetimeEarnedCoins: (json['lifetime_earned_coins'] as num).toInt(),
      lifetimeSpentCoins: (json['lifetime_spent_coins'] as num).toInt(),
      currentStreakDays: (json['current_streak_days'] as num).toInt(),
      longestStreakDays: (json['longest_streak_days'] as num).toInt(),
      lastClaimedDate: json['last_claimed_date'] != null
          ? DateTime.parse(json['last_claimed_date'] as String)
          : null,
    );
  }
}

/// Settings DTO from /v1/auth/me
class SettingsDto {
  final String appLanguage;
  final String appTheme;
  final bool readReceiptsStatus;
  final String profileVisibility;
  final bool showOnlineStatus;
  final String whoCanMessage;
  final String whoCanMessageRequest;
  final bool pushNotificationsEnabled;
  final Map<String, dynamic>? pushNotifications;
  final bool emailNotificationsEnabled;
  final Map<String, dynamic>? emailNotifications;
  final int minAge;
  final int maxAge;
  final int maxDistanceKm;

  SettingsDto({
    required this.appLanguage,
    required this.appTheme,
    required this.readReceiptsStatus,
    required this.profileVisibility,
    required this.showOnlineStatus,
    required this.whoCanMessage,
    required this.whoCanMessageRequest,
    required this.pushNotificationsEnabled,
    this.pushNotifications,
    required this.emailNotificationsEnabled,
    this.emailNotifications,
    required this.minAge,
    required this.maxAge,
    required this.maxDistanceKm,
  });

  factory SettingsDto.fromJson(Map<String, dynamic> json) {
    return SettingsDto(
      appLanguage: json['app_language'] as String,
      appTheme: json['app_theme'] as String,
      readReceiptsStatus: json['read_receipts_status'] as bool,
      profileVisibility: json['profile_visibility'] as String,
      showOnlineStatus: json['show_online_status'] as bool,
      whoCanMessage: json['who_can_message'] as String,
      whoCanMessageRequest: json['who_can_message_request'] as String,
      pushNotificationsEnabled: json['push_notifications_enabled'] as bool,
      pushNotifications:
          json['push_notifications'] as Map<String, dynamic>?,
      emailNotificationsEnabled: json['email_notifications_enabled'] as bool,
      emailNotifications:
          json['email_notifications'] as Map<String, dynamic>?,
      minAge: (json['min_age'] as num).toInt(),
      maxAge: (json['max_age'] as num).toInt(),
      maxDistanceKm: (json['max_distance_km'] as num).toInt(),
    );
  }
}

/// Photo DTO from user profile
class PhotoDto {
  final String id;
  final String photoUri;
  final int displayOrder;
  final bool isPrimary;
  final bool isFaceVerified;
  final String moderationStatus;
  final Map<String, dynamic>? commentsJson;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PhotoDto({
    required this.id,
    required this.photoUri,
    required this.displayOrder,
    required this.isPrimary,
    required this.isFaceVerified,
    required this.moderationStatus,
    this.commentsJson,
    required this.createdAt,
    this.updatedAt,
  });

  factory PhotoDto.fromJson(Map<String, dynamic> json) {
    return PhotoDto(
      id: json['id'] as String,
      photoUri: json['photo_uri'] as String,
      displayOrder: (json['display_order'] as num).toInt(),
      isPrimary: json['is_primary'] as bool,
      isFaceVerified: json['is_face_verified'] as bool,
      moderationStatus: json['moderation_status'] as String,
      commentsJson:
          json['comments_json'] != null
              ? Map<String, dynamic>.from(json['comments_json'] as Map<String, dynamic>)
              : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}

/// Profile update response DTO
class ProfileUpdateResponse {
  final bool success;
  final String message;
  final ProfileDto profile;
  final int profileProgress;

  ProfileUpdateResponse({
    required this.success,
    required this.message,
    required this.profile,
    required this.profileProgress,
  });

  factory ProfileUpdateResponse.fromJson(Map<String, dynamic> json) {
    return ProfileUpdateResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      profile: ProfileDto.fromJson(json['profile'] as Map<String, dynamic>),
      profileProgress: (json['profile_progress'] as num).toInt(),
    );
  }
}

/// Biometrics verify response DTO
class BiometricsVerifyResponse {
  final bool success;
  final String message;
  final VerificationSummaryDto verification;
  final ProfileDto updatedProfile;

  BiometricsVerifyResponse({
    required this.success,
    required this.message,
    required this.verification,
    required this.updatedProfile,
  });

  factory BiometricsVerifyResponse.fromJson(Map<String, dynamic> json) {
    return BiometricsVerifyResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      verification: VerificationSummaryDto.fromJson(
          json['verification'] as Map<String, dynamic>),
      updatedProfile: ProfileDto.fromJson(
          json['updated_profile'] as Map<String, dynamic>),
    );
  }
}

/// Verification summary DTO
class VerificationSummaryDto {
  final bool isVerified;
  final bool isVoiceVerified;
  final bool livenessVerified;
  final String verificationStatus;
  final bool blueTickAwarded;
  final num profileProgress;

  VerificationSummaryDto({
    required this.isVerified,
    required this.isVoiceVerified,
    required this.livenessVerified,
    required this.verificationStatus,
    required this.blueTickAwarded,
    required this.profileProgress,
  });

  factory VerificationSummaryDto.fromJson(Map<String, dynamic> json) {
    return VerificationSummaryDto(
      isVerified: json['is_verified'] as bool,
      isVoiceVerified: json['is_voice_verified'] as bool,
      livenessVerified: json['liveness_verified'] as bool,
      verificationStatus: json['verification_status'] as String,
      blueTickAwarded: json['blue_tick_awarded'] as bool,
      profileProgress: (json['profile_progress'] as num).toDouble(),
    );
  }
}

/// Public user profile response DTO from GET /v1/users/:targetUserId
class PublicUserProfileResponse {
  final bool success;
  final PublicUserProfileDto profile;
  final bool isMatched;
  final String visibility;

  PublicUserProfileResponse({
    required this.success,
    required this.profile,
    required this.isMatched,
    required this.visibility,
  });

  factory PublicUserProfileResponse.fromJson(Map<String, dynamic> json) {
    return PublicUserProfileResponse(
      success: json['success'] as bool,
      profile: PublicUserProfileDto.fromJson(json['profile'] as Map<String, dynamic>),
      isMatched: json['is_matched'] as bool,
      visibility: json['visibility'] as String,
    );
  }
}

/// Public user profile DTO with visibility masking
class PublicUserProfileDto {
  final String userId;
  final String nickname;
  final String? firstName;
  final int? age;
  final String? gender;
  final String? bio;
  final String? profession;
  final String? education;
  final String? city;
  final String? countryCode;
  final List<String> interests;
  final List<String> languages;
  final List<String> lookingFor;
  final List<String> sexualOrientations;
  final bool isVerified;
  final String verificationStatus;
  final bool isVoiceVerified;
  final bool livenessVerified;
  final num profileProgress;
  final List<PublicPhotoDto> photos;
  final bool isMatched;
  final String visibility;

  PublicUserProfileDto({
    required this.userId,
    required this.nickname,
    this.firstName,
    this.age,
    this.gender,
    this.bio,
    this.profession,
    this.education,
    this.city,
    this.countryCode,
    required this.interests,
    required this.languages,
    required this.lookingFor,
    required this.sexualOrientations,
    required this.isVerified,
    required this.verificationStatus,
    required this.isVoiceVerified,
    required this.livenessVerified,
    required this.profileProgress,
    required this.photos,
    required this.isMatched,
    required this.visibility,
  });

  factory PublicUserProfileDto.fromJson(Map<String, dynamic> json) {
    final photosJson = (json['photos'] as List?)
        ?.map((p) => PublicPhotoDto.fromJson(p as Map<String, dynamic>))
        .toList() ?? [];

    return PublicUserProfileDto(
      userId: json['user_id'] as String,
      nickname: json['nickname'] as String,
      firstName: json['first_name'] as String?,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      bio: json['bio'] as String?,
      profession: json['profession'] as String?,
      education: json['education'] as String?,
      city: json['city'] as String?,
      countryCode: json['country_code'] as String?,
      interests: (json['interests'] as List?)
          .map((e) => e as String)
          .toList(),
      languages: (json['languages'] as List?)
          .map((e) => e as String)
          .toList(),
      lookingFor: (json['looking_for'] as List?)
          .map((e) => e as String)
          .toList(),
      sexualOrientations: (json['sexual_orientations'] as List?)
          .map((e) => e as String)
          .toList(),
      isVerified: json['is_verified'] as bool,
      verificationStatus: json['verification_status'] as String,
      isVoiceVerified: json['is_voice_verified'] as bool,
      livenessVerified: json['liveness_verified'] as bool,
      profileProgress: (json['profile_progress'] as num).toDouble(),
      photos: photosJson,
      isMatched: json['is_matched'] as bool,
      visibility: json['visibility'] as String,
    );
  }
}

/// Public photo DTO (visibility-masked)
class PublicPhotoDto {
  final String id;
  final String photoUri;
  final int displayOrder;
  final bool isPrimary;
  final bool isFaceVerified;
  final String moderationStatus;

  PublicPhotoDto({
    required this.id,
    required this.photoUri,
    required this.displayOrder,
    required this.isPrimary,
    required this.isFaceVerified,
    required this.moderationStatus,
  });

  factory PublicPhotoDto.fromJson(Map<String, dynamic> json) {
    return PublicPhotoDto(
      id: json['id'] as String,
      photoUri: json['photo_uri'] as String,
      displayOrder: (json['display_order'] as num).toInt(),
      isPrimary: json['is_primary'] as bool,
      isFaceVerified: json['is_face_verified'] as bool,
      moderationStatus: json['moderation_status'] as String,
    );
  }
}