// ignore: unused_import
import 'dart:convert';

/// Discovery deck response DTO from GET /v1/discovery/feed
class DiscoveryDeckResponse {
  final bool success;
  final List<DiscoveryCardDto> cards;
  final int totalAvailable;
  final bool hasMore;
  final DiscoveryFilterInfo filterInfo;

  DiscoveryDeckResponse({
    required this.success,
    required this.cards,
    required this.totalAvailable,
    required this.hasMore,
    required this.filterInfo,
  });

  factory DiscoveryDeckResponse.fromJson(Map<String, dynamic> json) {
    return DiscoveryDeckResponse(
      success: json['success'] as bool,
      cards: (json['cards'] as List)
          .map((c) => DiscoveryCardDto.fromJson(c as Map<String, dynamic>))
          .toList(),
      totalAvailable: (json['total_available'] as num).toInt(),
      hasMore: json['has_more'] as bool,
      filterInfo: DiscoveryFilterInfo.fromJson(
          json['filter_info'] as Map<String, dynamic>),
    );
  }
}

/// Discovery card DTO - The swipe card data
class DiscoveryCardDto {
  final String userId;
  final String nickname;
  final String? firstName;
  final int age;
  final String gender;
  final String bio;
  final String profession;
  final String education;
  final String city;
  final String countryCode;
  final List<String> interests;
  final List<String> languages;
  final List<String> sexualOrientations;
  final List<String> lookingFor;
  final bool isVerified;
  final num profileProgress;
  final List<dynamic> photos;
  final String location;
  final bool isAvailable;
  final int snoozeCount;

  DiscoveryCardDto({
    required this.userId,
    required this.nickname,
    this.firstName,
    required this.age,
    required this.gender,
    required this.bio,
    required this.profession,
    required this.education,
    required this.city,
    required this.countryCode,
    required this.interests,
    required this.languages,
    required this.sexualOrientations,
    required this.lookingFor,
    required this.isVerified,
    required this.profileProgress,
    required this.photos,
    required this.location,
    required this.isAvailable,
    required this.snoozeCount,
  });

  factory DiscoveryCardDto.fromJson(Map<String, dynamic> json) {
    return DiscoveryCardDto(
      userId: json['user_id'] as String,
      nickname: json['nickname'] as String,
      firstName: json['first_name'] as String?,
      age: (json['age'] as num).toInt(),
      gender: json['gender'] as String,
      bio: json['bio'] as String,
      profession: json['profession'] as String,
      education: json['education'] as String,
      city: json['city'] as String,
      countryCode: json['country_code'] as String,
      interests: (json['interests'] as List?)
          .map((e) => e as String)
          .toList(),
      languages: (json['languages'] as List?)
          .map((e) => e as String)
          .toList(),
      sexualOrientations: (json['sexual_orientations'] as List?)
          .map((e) => e as String)
          .toList(),
      lookingFor: (json['looking_for'] as List?)
          .map((e) => e as String)
          .toList(),
      isVerified: json['is_verified'] as bool,
      profileProgress: (json['profile_progress'] as num).toDouble(),
      photos: (json['photos'] as List?)
          ?.map((p) => p as Map<String, dynamic>)
          .toList() ?? [],
      location: json['location'] as String,
      isAvailable: json['is_available'] as bool,
      snoozeCount: (json['snooze_count'] as num).toInt(),
    );
  }
}

/// Discovery filter info DTO
class DiscoveryFilterInfo {
  final double radiusKm;
  final int minAge;
  final int maxAge;
  final List<String> selectedGenders;
  final bool isPremiumRequired;

  DiscoveryFilterInfo({
    required this.radiusKm,
    required this.minAge,
    required this.maxAge,
    required this.selectedGenders,
    required this.isPremiumRequired,
  });

  factory DiscoveryFilterInfo.fromJson(Map<String, dynamic> json) {
    return DiscoveryFilterInfo(
      radiusKm: (json['radius_km'] as num).toDouble(),
      minAge: (json['min_age'] as num).toInt(),
      maxAge: (json['max_age'] as num).toInt(),
      selectedGenders: (json['selected_genders'] as List?)
          .map((e) => e as String)
          .toList(),
      isPremiumRequired: json['is_premium_required'] as bool,
    );
  }
}

/// Swipe action response DTO from POST /v1/discovery/action
class SwipeActionResponse {
  final bool success;
  final SwipeActionResult result;
  final String matchedUserId;
  final bool isNewMatch;
  final String? sparkToken;
  final String actionTaken;

  SwipeActionResponse({
    required this.success,
    required this.result,
    required this.matchedUserId,
    required this.isNewMatch,
    this.sparkToken,
    required this.actionTaken,
  });

  factory SwipeActionResponse.fromJson(Map<String, dynamic> json) {
    return SwipeActionResponse(
      success: json['success'] as bool,
      result: SwipeActionResult.fromJson(json['result'] as Map<String, dynamic>),
      matchedUserId: json['matched_user_id'] as String,
      isNewMatch: json['is_new_match'] as bool,
      sparkToken: json['spark_token'] as String?,
      actionTaken: json['action_taken'] as String,
    );
  }
}

/// Swipe action result DTO
class SwipeActionResult {
  final String action;
  final String targetUserId;
  final bool actionAccepted;
  final int newProfileProgress;

  SwipeActionResult({
    required this.action,
    required this.targetUserId,
    required this.actionAccepted,
    required this.newProfileProgress,
  });

  factory SwipeActionResult.fromJson(Map<String, dynamic> json) {
    return SwipeActionResult(
      action: json['action'] as String,
      targetUserId: json['target_user_id'] as String,
      actionAccepted: json['action_accepted'] as bool,
      newProfileProgress: (json['new_profile_progress'] as num).toInt(),
    );
  }
}

/// Snooze response DTO from POST /v1/discovery/snooze
class SnoozeResponse {
  final bool success;
  final String message;
  final int remainingSnoozes;
  final bool isPremiumFeature;

  SnoozeResponse({
    required this.success,
    required this.message,
    required this.remainingSnoozes,
    required this.isPremiumFeature,
  });

  factory SnoozeResponse.fromJson(Map<String, dynamic> json) {
    return SnoozeResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      remainingSnoozes: (json['remaining_snoozes'] as num).toInt(),
      isPremiumFeature: json['is_premium_feature'] as bool,
    );
  }
}

/// Discovery filters response DTO
class DiscoveryFiltersResponse {
  final bool success;
  final DiscoveryFiltersDto filters;

  DiscoveryFiltersResponse({
    required this.success,
    required this.filters,
  });

  factory DiscoveryFiltersResponse.fromJson(Map<String, dynamic> json) {
    return DiscoveryFiltersResponse(
      success: json['success'] as bool,
      filters: DiscoveryFiltersDto.fromJson(json['filters'] as Map<String, dynamic>),
    );
  }
}

/// Discovery filters DTO
class DiscoveryFiltersDto {
  final List<String> genderFilters;
  final int minAge;
  final int maxAge;
  final double radiusKm;
  final bool isPremiumRequired;

  DiscoveryFiltersDto({
    required this.genderFilters,
    required this.minAge,
    required this.maxAge,
    required this.radiusKm,
    required this.isPremiumRequired,
  });

  factory DiscoveryFiltersDto.fromJson(Map<String, dynamic> json) {
    return DiscoveryFiltersDto(
      genderFilters: (json['gender_filters'] as List?)
          .map((e) => e as String)
          .toList(),
      minAge: (json['min_age'] as num).toInt(),
      maxAge: (json['max_age'] as num).toInt(),
      radiusKm: (json['radius_km'] as num).toDouble(),
      isPremiumRequired: json['is_premium_required'] as bool,
    );
  }
}