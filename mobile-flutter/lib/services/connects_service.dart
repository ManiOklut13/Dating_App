import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:younme_mobile/models/chat_profile_models.dart';
import 'package:younme_mobile/services/network_service.dart';
import 'package:younme_mobile/services/profile_dto.dart';
import 'package:younme_mobile/services/home_dto.dart';
import 'package:younme_mobile/services/connects_dto.dart';

class ConnectsService {
  final NetworkService _network = NetworkService();

  /// Random Calls tab endpoints

  /// GET /v1/random-calls/icebreakers - Daily icebreaker questions
  Future<IcebreakersResponse> getIcebreakers() async {
    final response = await _network.dio.get(
      '/v1/random-calls/icebreakers',
    );
    return IcebreakersResponse.fromJson(response.data);
  }

  /// POST /v1/random-calls/icebreakers/answer - Submit icebreaker answer
  Future<IcebreakerAnswerResponse> answerIcebreaker({
    required String icebreakerId,
    required String answer,
  }) async {
    final response = await _network.dio.post(
      '/v1/random-calls/icebreakers/answer',
      data: {
        'icebreaker_id': icebreakerId,
        'answer': answer,
      },
    );
    return IcebreakerAnswerResponse.fromJson(response.data);
  }

  /// GET /v1/random-calls/filters - Filter management
  Future<RandomCallFiltersResponse> getRandomCallFilters({
    required String userId,
  }) async {
    final response = await _network.dio.get(
      '/v1/random-calls/filters',
      queryParameters: {'user_id': userId},
    );
    return RandomCallFiltersResponse.fromJson(response.data);
  }

  /// PUT /v1/random-calls/filters - Filter management update
  Future<RandomCallFiltersResponse> updateRandomCallFilters({
    required String userId,
    required String? preferredGender,
    required int? minAge,
    required int? maxAge,
    required double? maxDistance,
  }) async {
    final response = await _network.dio.put(
      '/v1/random-calls/filters',
      data: {
        'user_id': userId,
        if (preferredGender != null) 'preferred_gender': preferredGender,
        if (minAge != null) 'min_age': minAge,
        if (maxAge != null) 'max_age': maxAge,
        if (maxDistance != null) 'max_distance': maxDistance,
      },
    );
    return RandomCallFiltersResponse.fromJson(response.data);
  }

  /// GET /v1/random-calls/profile - Random profile editor
  Future<RandomCallProfileResponse> getRandomCallProfile({
    required String userId,
  }) async {
    final response = await _network.dio.get(
      '/v1/random-calls/profile',
      queryParameters: {'user_id': userId},
    );
    return RandomCallProfileResponse.fromJson(response.data);
  }

  /// PUT /v1/random-calls/profile - Update random call profile
  Future<RandomCallProfileResponse> updateRandomCallProfile({
    required String userId,
    required String? bio,
    required List<String>? interests,
    required String? profilePictureKey,
  }) async {
    final response = await _network.dio.put(
      '/v1/random-calls/profile',
      data: {
        'user_id': userId,
        if (bio != null) 'bio': bio,
        if (interests != null) 'interests': interests,
        if (profilePictureKey != null) 'profile_picture_key': profilePictureKey,
      },
    );
    return RandomCallProfileResponse.fromJson(response.data);
  }

  /// POST /v1/random-calls/join - Call queueing
  Future<JoinCallQueueResponse> joinCallQueue() async {
    final response = await _network.dio.post(
      '/v1/random-calls/join',
    );
    return JoinCallQueueResponse.fromJson(response.data);
  }

  /// GET /v1/random-calls/history - Call history
  Future<CallHistoryResponse> getCallHistory({
    required String userId,
    int? limit,
  }) async {
    final response = await _network.dio.get(
      '/v1/random-calls/history',
      queryParameters: {
        'user_id': userId,
        if (limit != null) 'limit': limit,
      },
    );
    return CallHistoryResponse.fromJson(response.data);
  }

  /// POST /v1/random-calls/history/:callId/callback - Call back
  Future<CallCallbackResponse> initiateCallback({
    required String callId,
    required String userId,
  }) async {
    final response = await _network.dio.post(
      '/v1/random-calls/history/$callId/callback',
      data: {
        'user_id': userId,
      },
    );
    return CallCallbackResponse.fromJson(response.data);
  }

  /// Likes tab endpoints

  /// GET /v1/connects/incoming-sparks - Incoming sparks/likes listing
  Future<IncomingSparksResponse> getIncomingSparks({
    required String userId,
    int? limit,
  }) async {
    final response = await _network.dio.get(
      '/v1/connects/incoming-sparks',
      queryParameters: {
        'user_id': userId,
        if (limit != null) 'limit': limit,
      },
    );
    return IncomingSparksResponse.fromJson(response.data);
  }

  /// POST /v1/connects/incoming-sparks/:id/action - Spark/like action handler
  Future<SparkActionResponse> handleSparkAction({
    required String sparkId,
    required String userId,
    required String action, // 'like', 'pass', 'report'
  }) async {
    final response = await _network.dio.post(
      '/v1/connects/incoming-sparks/$sparkId/action',
      data: {
        'user_id': userId,
        'action': action,
      },
    );
    return SparkActionResponse.fromJson(response.data);
  }

  /// GET /v1/connects/incoming-likes - Incoming likes
  Future<IncomingLikesResponse> getIncomingLikes({
    required String userId,
    int? limit,
  }) async {
    final response = await _network.dio.get(
      '/v1/connects/incoming-likes',
      queryParameters: {
        'user_id': userId,
        if (limit != null) 'limit': limit,
      },
    );
    return IncomingLikesResponse.fromJson(response.data);
  }

  /// POST /v1/connects/incoming-likes/:id/action - Like action handler
  Future<LikeActionResponse> handleLikeAction({
    required String likeId,
    required String userId,
    required String action, // 'match', 'pass', 'report'
  }) async {
    final response = await _network.dio.post(
      '/v1/connects/incoming-likes/$likeId/action',
      data: {
        'user_id': userId,
        'action': action,
      },
    );
    return LikeActionResponse.fromJson(response.data);
  }

  /// GET /v1/connects/outgoing-history - Outgoing history top 15
  Future<OutgoingHistoryResponse> getOutgoingHistory({
    required String userId,
    int? limit,
  }) async {
    final response = await _network.dio.get(
      '/v1/connects/outgoing-history',
      queryParameters: {
        'user_id': userId,
        if (limit != null) 'limit': limit,
      },
    );
    return OutgoingHistoryResponse.fromJson(response.data);
  }

  /// GET /v1/connects/metrics - Past week metrics
  Future<ConnectsMetricsResponse> getConnectsMetrics({
    required String userId,
  }) async {
    final response = await _network.dio.get(
      '/v1/connects/metrics',
      queryParameters: {'user_id': userId},
    );
    return ConnectsMetricsResponse.fromJson(response.data);
  }

  /// GET /v1/connects/recommendations - Recommendations
  Future<ConnectsRecommendationsResponse> getConnectsRecommendations({
    required String userId,
    int? limit,
  }) async {
    final response = await _network.dio.get(
      '/v1/connects/recommendations',
      queryParameters: {
        'user_id': userId,
        if (limit != null) 'limit': limit,
      },
    );
    return ConnectsRecommendationsResponse.fromJson(response.data);
  }

  /// POST /v1/connects/recommendations/:id/action - Recommendation action
  Future<RecommendationActionResponse> handleRecommendationAction({
    required String recId,
    required String userId,
    required String action, // 'like', 'pass', 'super_like'
  }) async {
    final response = await _network.dio.post(
      '/v1/connects/recommendations/$recId/action',
      data: {
        'user_id': userId,
        'action': action,
      },
    );
    return RecommendationActionResponse.fromJson(response.data);
  }

  /// Matches tab endpoints

  /// GET /v1/connects/scoreboard - Gamified 2-1-3 scoreboard podium
  Future<ScoreboardResponse> getScoreboard({
    required String userId,
  }) async {
    final response = await _network.dio.get(
      '/v1/connects/scoreboard',
      queryParameters: {'user_id': userId},
    );
    return ScoreboardResponse.fromJson(response.data);
  }

  /// GET /v1/connects/recent-matches - Recent matches storyline
  Future<RecentMatchesResponse> getRecentMatches({
    required String userId,
    int? limit,
  }) async {
    final response = await _network.dio.get(
      '/v1/connects/recent-matches',
      queryParameters: {
        'user_id': userId,
        if (limit != null) 'limit': limit,
      },
    );
    return RecentMatchesResponse.fromJson(response.data);
  }

  /// GET /v1/connects/make-first-move - Make first move
  Future<MakeFirstMoveResponse> getMakeFirstMove({
    required String userId,
    required String matchId,
  }) async {
    final response = await _network.dio.get(
      '/v1/connects/make-first-move',
      queryParameters: {
        'user_id': userId,
        'match_id': matchId,
      },
    );
    return MakeFirstMoveResponse.fromJson(response.data);
  }

  /// POST /v1/connects/make-first-move/:matchId/send-icebreaker - Send icebreaker
  Future<SendIcebreakerResponse> sendIcebreaker({
    required String matchId,
    required String icebreakerId,
    required String userId,
  }) async {
    final response = await _network.dio.post(
      '/v1/connects/make-first-move/$matchId/send-icebreaker',
      data: {
        'match_id': matchId,
        'icebreaker_id': icebreakerId,
        'user_id': userId,
      },
    );
    return SendIcebreakerResponse.fromJson(response.data);
  }

  /// GET /v1/connects/match-history - Full match history
  Future<MatchHistoryResponse> getMatchHistory({
    required String userId,
    int? limit,
  }) async {
    final response = await _network.dio.get(
      '/v1/connects/match-history',
      queryParameters: {
        'user_id': userId,
        if (limit != null) 'limit': limit,
      },
    );
    return MatchHistoryResponse.fromJson(response.data);
  }

  /// POST /v1/connects/boost - Profile boost
  Future<BoostResponse> applyBoost({
    required String userId,
    required int durationMinutes,
  }) async {
    final response = await _network.dio.post(
      '/v1/connects/boost',
      data: {
        'user_id': userId,
        'duration_minutes': durationMinutes,
      },
    );
    return BoostResponse.fromJson(response.data);
  }

  /// Profile Actions Sheet endpoints

  /// GET /v1/users/:targetUserId - Full profile fetch (already in profile_service)
  // Covered by ProfileService.getPublicUserProfile()

  /// POST /v1/users/:targetUserId/report - Report user
  Future<ReportUserResponse> reportUser({
    required String targetUserId,
    required String reporterUserId,
    required String reason,
    required String reportType, // 'harassment', 'fake_profile', 'spam', 'other'
  }) async {
    final response = await _network.dio.post(
      '/v1/users/$targetUserId/report',
      data: {
        'reporter_user_id': reporterUserId,
        'reason': reason,
        'report_type': reportType,
      },
    );
    return ReportUserResponse.fromJson(response.data);
  }

  /// POST /v1/users/:targetUserId/block - Block user
  Future<BlockUserResponse> blockUser({
    required String targetUserId,
    required String blockerUserId,
  }) async {
    final response = await _network.dio.post(
      '/v1/users/$targetUserId/block',
      data: {
        'blocker_user_id': blockerUserId,
      },
    );
    return BlockUserResponse.fromJson(response.data);
  }

  /// POST /v1/users/:targetUserId/restrict - Restrict user
  Future<RestrictUserResponse> restrictUser({
    required String targetUserId,
    required String moderatorUserId,
  }) async {
    final response = await _network.dio.post(
      '/v1/users/$targetUserId/restrict',
      data: {
        'moderator_user_id': moderatorUserId,
      },
    );
    return RestrictUserResponse.fromJson(response.data);
  }

  /// POST /v1/users/:targetUserId/unmatch - Unmatch
  Future<UnmatchResponse> unmatchUser({
    required String userId,
    required String matchId,
  }) async {
    final response = await _network.dio.post(
      '/v1/users/$matchId/unmatch',
      data: {
        'user_id': userId,
      },
    );
    return UnmatchResponse.fromJson(response.data);
  }

  /// POST /v1/users/:targetUserId/interact - Profile interaction options
  Future<InteractUserResponse> interactWithUser({
    required String targetUserId,
    required String callerUserId,
    required String interactionType, // 'chat', 'call', 'date', 'collectible'
    dynamic interactionData,
  }) async {
    final response = await _network.dio.post(
      '/v1/users/$targetUserId/interact',
      data: {
        'caller_user_id': callerUserId,
        'interaction_type': interactionType,
        if (interactionData != null) 'interaction_data': interactionData,
      },
    );
    return InteractUserResponse.fromJson(response.data);
  }
}