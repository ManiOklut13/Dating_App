import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:younme_mobile/models/chat_profile_models.dart';
import 'package:younme_mobile/services/network_service.dart';
import 'package:younme_mobile/services/profile_dto.dart';

class DiscoveryService {
  final NetworkService _network = NetworkService();

  /// GET /v1/discovery/feed - Tinder-style 5-button swipe deck
  Future<DiscoveryDeckResponse> getDiscoveryDeck({
    required String userId,
    double? radiusKm,
    int? minAge,
    int? maxAge,
  }) async {
    final response = await _network.dio.get(
      '/v1/discovery/feed',
      queryParameters: {
        'user_id': userId,
        if (radiusKm != null) 'radius_km': radiusKm,
        if (minAge != null) 'min_age': minAge,
        if (maxAge != null) 'max_age': maxAge,
      },
    );
    return DiscoveryDeckResponse.fromJson(response.data);
  }

  /// POST /v1/discovery/action - Record swipe (like/dislike/spark/snooze)
  Future<SwipeActionResponse> recordSwipe({
    required String userId,
    required String targetUserId,
    required String action, // 'like', 'dislike', 'spark', 'snooze'
    bool? isSuper,
  }) async {
    final response = await _network.dio.post(
      '/v1/discovery/action',
      data: {
        'user_id': userId,
        'target_id': targetUserId,
        'action': action,
        if (isSuper != null) 'is_super': isSuper,
      },
    );
    return SwipeActionResponse.fromJson(response.data);
  }

  /// POST /v1/swipes/revert - Revert last swipe
  Future<RevertSwipeResponse> revertSwipe({
    required String userId,
    String? userIdToRevert,
  }) async {
    final response = await _network.dio.post(
      '/v1/swipes/revert',
      data: {
        'user_id': userId,
        if (userIdToRevert != null) 'target_id': userIdToRevert,
      },
    );
    return RevertSwipeResponse.fromJson(response.data);
  }

  /// POST /v1/discovery/snooze - Snooze limit (max 3)
  Future<SnoozeResponse> snoozeUser({
    required String userId,
    required String targetUserId,
  }) async {
    final response = await _network.dio.post(
      '/v1/discovery/snooze',
      data: {
        'user_id': userId,
        'target_id': targetUserId,
      },
    );
    return SnoozeResponse.fromJson(response.data);
  }

  /// Filter bar integration - GET /v1/discovery/filters
  Future<DiscoveryFiltersResponse> getDiscoveryFilters({
    required String userId,
  }) async {
    final response = await _network.dio.get(
      '/v1/discovery/filters',
      queryParameters: {'user_id': userId},
    );
    return DiscoveryFiltersResponse.fromJson(response.data);
  }

  /// PUT /v1/discovery/filters - Filter management
  Future<DiscoveryFiltersResponse> updateDiscoveryFilters({
    required String userId,
    required List<String>? genderFilters,
    required List<int>? ageRange,
    required double? radiusKm,
  }) async {
    final response = await _network.dio.put(
      '/v1/discovery/filters',
      data: {
        'user_id': userId,
        if (genderFilters != null) 'gender_filters': genderFilters,
        if (ageRange != null) 'age_range': ageRange,
        if (radiusKm != null) 'radius_km': radiusKm,
      },
    );
    return DiscoveryFiltersResponse.fromJson(response.data);
  }
}