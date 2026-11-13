import 'dart:convert';

/// Icebreaker question DTO from GET /v1/random-calls/icebreakers
class IcebreakerDto {
  final String icebreakerId;
  final String question;
  final String category;
  final DateTime createdAt;
  final bool isDaily;

  IcebreakerDto({
    required this.icebreakerId,
    required this.question,
    required this.category,
    required this.createdAt,
    this.isDaily = false,
  });

  factory IcebreakerDto.fromJson(Map<String, dynamic> json) {
    return IcebreakerDto(
      icebreakerId: json['icebreaker_id'] as String,
      question: json['question'] as String,
      category: json['category'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      isDaily: json['is_daily'] as bool,
    );
  }
}

/// Icebreaker answer response DTO (for icebreaker submission)
class IcebreakerAnswerResponse {
  final bool success;
  final String answerId;
  final String feedback;
  final bool isMatch;
  final int coinsEarned;

  IcebreakerAnswerResponse({
    required this.success,
    required this.answerId,
    required this.feedback,
    this.isMatch = false,
    this.coinsEarned = 0,
  });

  factory IcebreakerAnswerResponse.fromJson(Map<String, dynamic> json) {
    return IcebreakerAnswerResponse(
      success: json['success'] as bool,
      answerId: json['answer_id'] as String,
      feedback: json['feedback'] as String,
      isMatch: json['is_match'] as bool,
      coinsEarned: (json['coins_earned'] as num).toInt(),
    );
  }
}

/// Random call filters DTO
class RandomCallFiltersDto {
  final String? preferredGender;
  final int? minAge;
  final int? maxAge;
  final double? maxDistance;
  final bool isPremiumRequired;

  RandomCallFiltersDto({
    this.preferredGender,
    this.minAge,
    this.maxAge,
    this.maxDistance,
    this.isPremiumRequired = false,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (preferredGender != null) map['preferred_gender'] = preferredGender;
    if (minAge != null) map['min_age'] = minAge;
    if (maxAge != null) map['max_age'] = maxAge;
    if (maxDistance != null) map['max_distance'] = maxDistance;
    map['is_premium_required'] = isPremiumRequired;
    return map;
  }

  factory RandomCallFiltersDto.fromJson(Map<String, dynamic> json) {
    return RandomCallFiltersDto(
      preferredGender: json['preferred_gender'] as String?,
      minAge: json['min_age'] as int?,
      maxAge: json['max_age'] as int?,
      maxDistance: json['max_distance'] as double?,
      isPremiumRequired: json['is_premium_required'] as bool,
    );
  }
}

/// Random call filters response DTO
class RandomCallFiltersResponse {
  final bool success;
  final RandomCallFiltersDto filters;

  RandomCallFiltersResponse({
    required this.success,
    required this.filters,
  });

  factory RandomCallFiltersResponse.fromJson(Map<String, dynamic> json) {
    return RandomCallFiltersResponse(
      success: json['success'] as bool,
      filters: RandomCallFiltersDto.fromJson(json as Map<String, dynamic>),
    );
  }
}

/// Icebreaker response DTO
class IcebreakersResponse {
  final bool success;
  final List<IcebreakerDto> icebreakers;
  final String dailyQuestionId;
  final int spinsUsed;

  IcebreakersResponse({
    required this.success,
    required this.icebreakers,
    required this.dailyQuestionId,
    required this.spinsUsed,
  });

  factory IcebreakersResponse.fromJson(Map<String, dynamic> json) {
    return IcebreakersResponse(
      success: json['success'] as bool,
      icebreakers: (json['icebreakers'] as List)
          .map((i) => IcebreakerDto.fromJson(i as Map<String, dynamic>))
          .toList(),
      dailyQuestionId: json['daily_question_id'] as String,
      spinsUsed: (json['spins_used'] as num).toInt(),
    );
  }
}

/// Spark action response DTO
class SparkActionResponse {
  final bool success;
  final SparkActionResult result;

  SparkActionResponse({
    required this.success,
    required this.result,
  });

  factory SparkActionResponse.fromJson(Map<String, dynamic> json) {
    return SparkActionResponse(
      success: json['success'] as bool,
      result: SparkActionResult.fromJson(json['result'] as Map<String, dynamic>),
    );
  }
}

/// Spark action result DTO
class SparkActionResult {
  final String action;
  final String targetUserId;
  final bool mutualLike;
  final String? matchId;
  final String actionTaken;

  SparkActionResult({
    required this.action,
    required this.targetUserId,
    this.mutualLike = false,
    this.matchId,
    required this.actionTaken,
  });

  factory SparkActionResult.fromJson(Map<String, dynamic> json) {
    return SparkActionResult(
      action: json['action'] as String,
      targetUserId: json['target_user_id'] as String,
      mutualLike: json['mutual_like'] as bool,
      matchId: json['match_id'] as String?,
      actionTaken: json['action_taken'] as String,
    );
  }
}

/// Incoming sparks response DTO
class IncomingSparksResponse {
  final bool success;
  final List<IncomingSparkDto> sparks;
  final int totalCount;
  final bool hasMore;

  IncomingSparksResponse({
    required this.success,
    required this.sparks,
    required this.totalCount,
    required this.hasMore,
  });

  factory IncomingSparksResponse.fromJson(Map<String, dynamic> json) {
    return IncomingSparksResponse(
      success: json['success'] as bool,
      sparks: (json['sparks'] as List)
          .map((s) => IncomingSparkDto.fromJson(s as Map<String, dynamic>))
          .toList(),
      totalCount: (json['total_count'] as num).toInt(),
      hasMore: json['has_more'] as bool,
    );
  }
}

/// Incoming spark DTO
class IncomingSparkDto {
  final String sparkId;
  final String senderUserId;
  final String senderNickname;
  final String? senderAvatarUrl;
  final String timestamp;
  final String icebreakerId;
  final String icebreakerQuestion;
  final int coinsValue;
  final bool isMutual;

  IncomingSparkDto({
    required this.sparkId,
    required this.senderUserId,
    required this.senderNickname,
    this.senderAvatarUrl,
    required this.timestamp,
    required this.icebreakerId,
    required this.icebreakerQuestion,
    required this.coinsValue,
    this.isMutual = false,
  });

  factory IncomingSparkDto.fromJson(Map<String, dynamic> json) {
    return IncomingSparkDto(
      sparkId: json['spark_id'] as String,
      senderUserId: json['sender_user_id'] as String,
      senderNickname: json['sender_nickname'] as String,
      senderAvatarUrl: json['sender_avatar_url'] as String?,
      timestamp: json['timestamp'] as String,
      icebreakerId: json['icebreaker_id'] as String,
      icebreakerQuestion: json['icebreaker_question'] as String,
      coinsValue: (json['coins_value'] as num).toInt(),
      isMutual: json['is_mutual'] as bool,
    );
  }
}

/// Incoming likes response DTO
class IncomingLikesResponse {
  final bool success;
  final List<IncomingLikeDto> likes;
  final int totalCount;
  final bool hasMore;

  IncomingLikesResponse({
    required this.success,
    required this.likes,
    required this.totalCount,
    required this.hasMore,
  });

  factory IncomingLikesResponse.fromJson(Map<String, dynamic> json) {
    return IncomingLikesResponse(
      success: json['success'] as bool,
      likes: (json['likes'] as List)
          .map((l) => IncomingLikeDto.fromJson(l as Map<String, dynamic>))
          .toList(),
      totalCount: (json['total_count'] as num).toInt(),
      hasMore: json['has_more'] as bool,
    );
  }
}

/// Incoming like DTO
class IncomingLikeDto {
  final String likeId;
  final String senderUserId;
  final String senderNickname;
  final String? senderAvatarUrl;
  final String timestamp;
  final String bioLine;
  final bool isMutual;
  final int rankScore;

  IncomingLikeDto({
    required this.likeId,
    required this.senderUserId,
    required this.senderNickname,
    this.senderAvatarUrl,
    required this.timestamp,
    required this.bioLine,
    this.isMutual = false,
    required this.rankScore,
  });

  factory IncomingLikeDto.fromJson(Map<String, dynamic> json) {
    return IncomingLikeDto(
      likeId: json['like_id'] as String,
      senderUserId: json['sender_user_id'] as String,
      senderNickname: json['sender_nickname'] as String,
      senderAvatarUrl: json['sender_avatar_url'] as String?,
      timestamp: json['timestamp'] as String,
      bioLine: json['bio_line'] as String,
      isMutual: json['is_mutual'] as bool,
      rankScore: (json['rank_score'] as num).toInt(),
    );
  }
}

/// Like action response DTO
class LikeActionResponse {
  final bool success;
  final LikeActionResult result;

  LikeActionResponse({
    required this.success,
    required this.result,
  });

  factory LikeActionResponse.fromJson(Map<String, dynamic> json) {
    return LikeActionResponse(
      success: json['success'] as bool,
      result: LikeActionResult.fromJson(json['result'] as Map<String, dynamic>),
    );
  }
}

/// Like action result DTO
class LikeActionResult {
  final String action;
  final String targetUserId;
  final bool mutualMatch;
  final String matchId;
  final String actionTaken;

  LikeActionResult({
    required this.action,
    required this.targetUserId,
    required this.mutualMatch,
    required this.matchId,
    required this.actionTaken,
  });

  factory LikeActionResult.fromJson(Map<String, dynamic> json) {
    return LikeActionResult(
      action: json['action'] as String,
      targetUserId: json['target_user_id'] as String,
      mutualMatch: json['mutual_match'] as bool,
      matchId: json['match_id'] as String,
      actionTaken: json['action_taken'] as String,
    );
  }
}

/// Outgoing history DTO
class OutgoingHistoryDto {
  final String matchId;
  final String targetUserId;
  final String targetNickname;
  final String? targetAvatarUrl;
  final DateTime sentAt;
  final String interactionType;
  final String? responseStatus;

  OutgoingHistoryDto({
    required this.matchId,
    required this.targetUserId,
    required this.targetNickname,
    this.targetAvatarUrl,
    required this.sentAt,
    required this.interactionType,
    this.responseStatus,
  });

  factory OutgoingHistoryDto.fromJson(Map<String, dynamic> json) {
    return OutgoingHistoryDto(
      matchId: json['match_id'] as String,
      targetUserId: json['target_user_id'] as String,
      targetNickname: json['target_nickname'] as String,
      targetAvatarUrl: json['target_avatar_url'] as String?,
      sentAt: json['sent_at'] != null
          ? DateTime.parse(json['sent_at'] as String)
          : DateTime.now(),
      interactionType: json['interaction_type'] as String,
      responseStatus: json['response_status'] as String?,
    );
  }
}

/// Outgoing history response DTO
class OutgoingHistoryResponse {
  final bool success;
  final List<OutgoingHistoryDto> history;
  final int totalCount;

  OutgoingHistoryResponse({
    required this.success,
    required this.history,
    required this.totalCount,
  });

  factory OutgoingHistoryResponse.fromJson(Map<String, dynamic> json) {
    return OutgoingHistoryResponse(
      success: json['success'] as bool,
      history: (json['history'] as List)
          .map((h) => OutgoingHistoryDto.fromJson(h as Map<String, dynamic>))
          .toList(),
      totalCount: (json['total_count'] as num).toInt(),
    );
  }
}

/// Connects metrics DTO
class ConnectsMetricsDto {
  final int totalLikesThisWeek;
  final int totalMatchesThisWeek;
  final int totalSparksThisWeek;
  final int profileViewsThisWeek;
  final int newConnectionsThisWeek;
  final double activityScore;

  ConnectsMetricsDto({
    required this.totalLikesThisWeek,
    required this.totalMatchesThisWeek,
    required this.totalSparksThisWeek,
    required this.profileViewsThisWeek,
    required this.newConnectionsThisWeek,
    required this.activityScore,
  });

  factory ConnectsMetricsDto.fromJson(Map<String, dynamic> json) {
    return ConnectsMetricsDto(
      totalLikesThisWeek: (json['total_likes_this_week'] as num).toInt(),
      totalMatchesThisWeek: (json['total_matches_this_week'] as num).toInt(),
      totalSparksThisWeek: (json['total_sparks_this_week'] as num).toInt(),
      profileViewsThisWeek: (json['profile_views_this_week'] as num).toInt(),
      newConnectionsThisWeek: (json['new_connections_this_week'] as num).toInt(),
      activityScore: (json['activity_score'] as num).toDouble(),
    );
  }
}

/// Connects metrics response DTO
class ConnectsMetricsResponse {
  final bool success;
  final ConnectsMetricsDto metrics;

  ConnectsMetricsResponse({
    required this.success,
    required this.metrics,
  });

  factory ConnectsMetricsResponse.fromJson(Map<String, dynamic> json) {
    return ConnectsMetricsResponse(
      success: json['success'] as bool,
      metrics: ConnectsMetricsDto.fromJson(json['metrics'] as Map<String, dynamic>),
    );
  }
}

/// Connects recommendation DTO
class ConnectsRecommendationDto {
  final String recId;
  final String userId;
  final String nickname;
  final String? avatarUrl;
  final int rankScore;
  final String reason;

  ConnectsRecommendationDto({
    required this.recId,
    required this.userId,
    required this.nickname,
    this.avatarUrl,
    required this.rankScore,
    required this.reason,
  });

  factory ConnectsRecommendationDto.fromJson(Map<String, dynamic> json) {
    return ConnectsRecommendationDto(
      recId: json['rec_id'] as String,
      userId: json['user_id'] as String,
      nickname: json['nickname'] as String,
      avatarUrl: json['avatar_url'] as String?,
      rankScore: (json['rank_score'] as num).toInt(),
      reason: json['reason'] as String,
    );
  }
}

/// Connects recommendations response DTO
class ConnectsRecommendationsResponse {
  final bool success;
  final List<ConnectsRecommendationDto> recommendations;
  final int totalCount;
  final bool hasMore;

  ConnectsRecommendationsResponse({
    required this.success,
    required this.recommendations,
    required this.totalCount,
    required this.hasMore,
  });

  factory ConnectsRecommendationsResponse.fromJson(Map<String, dynamic> json) {
    return ConnectsRecommendationsResponse(
      success: json['success'] as bool,
      recommendations: (json['recommendations'] as List)
          .map((r) => ConnectsRecommendationDto.fromJson(r as Map<String, dynamic>))
          .toList(),
      totalCount: (json['total_count'] as num).toInt(),
      hasMore: json['has_more'] as bool,
    );
  }
}

/// Recommendation action response DTO
class RecommendationActionResponse {
  final bool success;
  final RecommendationActionResult result;

  RecommendationActionResponse({
    required this.success,
    required this.result,
  });

  factory RecommendationActionResponse.fromJson(Map<String, dynamic> json) {
    return RecommendationActionResponse(
      success: json['success'] as bool,
      result: RecommendationActionResult.fromJson(json['result'] as Map<String, dynamic>),
    );
  }
}

/// Recommendation action result DTO
class RecommendationActionResult {
  final String action;
  final String targetUserId;
  final bool mutualMatch;
  final String matchId;
  final String actionTaken;

  RecommendationActionResult({
    required this.action,
    required this.targetUserId,
    required this.mutualMatch,
    required this.matchId,
    required this.actionTaken,
  });

  factory RecommendationActionResult.fromJson(Map<String, dynamic> json) {
    return RecommendationActionResult(
      action: json['action'] as String,
      targetUserId: json['target_user_id'] as String,
      mutualMatch: json['mutual_match'] as bool,
      matchId: json['match_id'] as String,
      actionTaken: json['action_taken'] as String,
    );
  }
}

/// Scoreboard DTO
class ScoreboardDto {
  final int rank;
  final String nickname;
  final String? profilePictureUrl;
  final int points;
  final int streakDays;
  final String medal;

  ScoreboardDto({
    required this.rank,
    required this.nickname,
    this.profilePictureUrl,
    required this.points,
    required this.streakDays,
    this.medal = 'none',
  });

  factory ScoreboardDto.fromJson(Map<String, dynamic> json) {
    return ScoreboardDto(
      rank: (json['rank'] as num).toInt(),
      nickname: json['nickname'] as String,
      profilePictureUrl: json['profile_picture_url'] as String?,
      points: (json['points'] as num).toInt(),
      streakDays: (json['streak_days'] as num).toInt(),
      medal: json['medal'] as String?,
    );
  }
}

/// Scoreboard response DTO
class ScoreboardResponse {
  final bool success;
  final List<ScoreboardDto> podium;
  final List<ScoreboardDto> rankedList;
  final int userRank;
  final int userPoints;
  final String userMedal;

  ScoreboardResponse({
    required this.success,
    required this.podium,
    required this.rankedList,
    required this.userRank,
    required this.userPoints,
    required this.userMedal,
  });

  factory ScoreboardResponse.fromJson(Map<String, dynamic> json) {
    return ScoreboardResponse(
      success: json['success'] as bool,
      podium: (json['podium'] as List)
          .map((p) => ScoreboardDto.fromJson(p as Map<String, dynamic>))
          .toList(),
      rankedList: (json['ranked_list'] as List)
          .map((r) => ScoreboardDto.fromJson(r as Map<String, dynamic>))
          .toList(),
      userRank: (json['user_rank'] as num).toInt(),
      userPoints: (json['user_points'] as num).toInt(),
      userMedal: json['user_medal'] as String,
    );
  }
}

/// Recent match DTO
class RecentMatchDto {
  final String matchId;
  final String partnerUserId;
  final String partnerNickname;
  final String? partnerAvatarUrl;
  final DateTime matchDate;
  final String firstIcebreaker;
  final bool dateCompleted;
  final int matchPoints;

  RecentMatchDto({
    required this.matchId,
    required this.partnerUserId,
    required this.partnerNickname,
    this.partnerAvatarUrl,
    required this.matchDate,
    required this.firstIcebreaker,
    this.dateCompleted = false,
    this.matchPoints = 0,
  });

  factory RecentMatchDto.fromJson(Map<String, dynamic> json) {
    return RecentMatchDto(
      matchId: json['match_id'] as String,
      partnerUserId: json['partner_user_id'] as String,
      partnerNickname: json['partner_nickname'] as String,
      partnerAvatarUrl: json['partner_avatar_url'] as String?,
      matchDate: json['match_date'] != null
          ? DateTime.parse(json['match_date'] as String)
          : DateTime.now(),
      firstIcebreaker: json['first_icebreaker'] as String,
      dateCompleted: json['date_completed'] as bool,
      matchPoints: (json['match_points'] as num).toInt(),
    );
  }
}

/// Recent matches response DTO
class RecentMatchesResponse {
  final bool success;
  final List<RecentMatchDto> matches;
  final int totalCount;

  RecentMatchesResponse({
    required this.success,
    required this.matches,
    required this.totalCount,
  });

  factory RecentMatchesResponse.fromJson(Map<String, dynamic> json) {
    return RecentMatchesResponse(
      success: json['success'] as bool,
      matches: (json['matches'] as List)
          .map((m) => RecentMatchDto.fromJson(m as Map<String, dynamic>))
          .toList(),
      totalCount: (json['total_count'] as num).toInt(),
    );
  }
}

/// Make first move DTO
class MakeFirstMoveDto {
  final String matchId;
  final bool canMakeFirstMove;
  final String icebreakerQuestion;
  final String? selectedIcebreakerId;
  final List<String> availableIcebreakers;

  MakeFirstMoveDto({
    required this.matchId,
    required this.canMakeFirstMove,
    required this.icebreakerQuestion,
    this.selectedIcebreakerId,
    this.availableIcebreakers = const [],
  });

  factory MakeFirstMoveDto.fromJson(Map<String, dynamic> json) {
    final available = (json['available_icebreakers'] as List?)
        ?.map((a) => a as String)
        .toList() ??
        [];
    return MakeFirstMoveDto(
      matchId: json['match_id'] as String,
      canMakeFirstMove: json['can_make_first_move'] as bool,
      icebreakerQuestion: json['icebreaker_question'] as String,
      selectedIcebreakerId: json['selected_icebreaker_id'] as String?,
      availableIcebreakers: available,
    );
  }
}

/// Make first move response DTO
class MakeFirstMoveResponse {
  final bool success;
  final MakeFirstMoveDto firstMoveInfo;

  MakeFirstMoveResponse({
    required this.success,
    required this.firstMoveInfo,
  });

  factory MakeFirstMoveResponse.fromJson(Map<String, dynamic> json) {
    return MakeFirstMoveResponse(
      success: json['success'] as bool,
      firstMoveInfo: MakeFirstMoveDto.fromJson(json as Map<String, dynamic>),
    );
  }
}

/// Send icebreaker response DTO
class SendIcebreakerResponse {
  final bool success;
  final String icebreakerId;
  final String sentAt;
  final bool delivered;
  final String status;

  SendIcebreakerResponse({
    required this.success,
    required this.icebreakerId,
    required this.sentAt,
    this.delivered = false,
    this.status = 'sent',
  });

  factory SendIcebreakerResponse.fromJson(Map<String, dynamic> json) {
    return SendIcebreakerResponse(
      success: json['success'] as bool,
      icebreakerId: json['icebreaker_id'] as String,
      sentAt: json['sent_at'] as String,
      delivered: json['delivered'] as bool,
      status: json['status'] as String,
    );
  }
}

/// Match history DTO
class MatchHistoryDto {
  final String matchId;
  final String partnerUserId;
  final String partnerNickname;
  final String? partnerAvatarUrl;
  final DateTime matchedAt;
  final String firstIcebreakerUsed;
  final DateTime? firstDateScheduled;
  final String? dateStatus;
  final int totalIcebreakersSent;
  final int totalDates;
  final bool isActive;

  MatchHistoryDto({
    required this.matchId,
    required this.partnerUserId,
    required this.partnerNickname,
    this.partnerAvatarUrl,
    required this.matchedAt,
    required this.firstIcebreakerUsed,
    this.firstDateScheduled,
    this.dateStatus,
    required this.totalIcebreakersSent,
    required this.totalDates,
    this.isActive = true,
  });

  factory MatchHistoryDto.fromJson(Map<String, dynamic> json) {
    return MatchHistoryDto(
      matchId: json['match_id'] as String,
      partnerUserId: json['partner_user_id'] as String,
      partnerNickname: json['partner_nickname'] as String,
      partnerAvatarUrl: json['partner_avatar_url'] as String?,
      matchedAt: json['matched_at'] != null
          ? DateTime.parse(json['matched_at'] as String)
          : DateTime.now(),
      firstIcebreakerUsed: json['first_icebreaker_used'] as String,
      firstDateScheduled:
          json['first_date_scheduled'] != null
              ? DateTime.parse(json['first_date_scheduled'] as String)
              : null,
      dateStatus: json['date_status'] as String?,
      totalIcebreakersSent: (json['total_icebreakers_sent'] as num).toInt(),
      totalDates: (json['total_dates'] as num).toInt(),
      isActive: json['is_active'] as bool,
    );
  }
}

/// Match history response DTO
class MatchHistoryResponse {
  final bool success;
  final List<MatchHistoryDto> matches;
  final int totalCount;

  MatchHistoryResponse({
    required this.success,
    required this.matches,
    required this.totalCount,
  });

  factory MatchHistoryResponse.fromJson(Map<String, dynamic> json) {
    return MatchHistoryResponse(
      success: json['success'] as bool,
      matches: (json['matches'] as List)
          .map((m) => MatchHistoryDto.fromJson(m as Map<String, dynamic>))
          .toList(),
      totalCount: (json['total_count'] as num).toInt(),
    );
  }
}

/// Boost DTO
class BoostDto {
  final String boostId;
  final String boostType;
  final int durationMinutes;
  final int coinsCost;
  final bool isActive;
  final DateTime? activatedAt;
  final DateTime? expiresAt;
  final String? marketedTitle;

  BoostDto({
    required this.boostId,
    required this.boostType,
    required this.durationMinutes,
    required this.coinsCost,
    this.isActive = false,
    this.activatedAt,
    this.expiresAt,
    this.marketedTitle,
  });

  factory BoostDto.fromJson(Map<String, dynamic> json) {
    return BoostDto(
      boostId: json['boost_id'] as String,
      boostType: json['boost_type'] as String,
      durationMinutes: (json['duration_minutes'] as num).toInt(),
      coinsCost: (json['coins_cost'] as num).toInt(),
      isActive: json['is_active'] as bool,
      activatedAt: json['activated_at'] != null
          ? DateTime.parse(json['activated_at'] as String)
          : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      marketedTitle: json['marketed_title'] as String?,
    );
  }
}

/// Boost response DTO
class BoostResponse {
  final bool success;
  final BoostDto boost;

  BoostResponse({
    required this.success,
    required this.boost,
  });

  factory BoostResponse.fromJson(Map<String, dynamic> json) {
    return BoostResponse(
      success: json['success'] as bool,
      boost: BoostDto.fromJson(json['boost'] as Map<String, dynamic>),
    );
  }
}

/// Report user response DTO
class ReportUserResponse {
  final bool success;
  final String reportId;
  final String status;
  final String message;

  ReportUserResponse({
    required this.success,
    required this.reportId,
    required this.status,
    required this.message,
  });

  factory ReportUserResponse.fromJson(Map<String, dynamic> json) {
    return ReportUserResponse(
      success: json['success'] as bool,
      reportId: json['report_id'] as String,
      status: json['status'] as String,
      message: json['message'] as String,
    );
  }
}

/// Block user response DTO
class BlockUserResponse {
  final bool success;
  final String blockId;
  final String status;
  final String message;

  BlockUserResponse({
    required this.success,
    required this.blockId,
    required this.status,
    required this.message,
  });

  factory BlockUserResponse.fromJson(Map<String, dynamic> json) {
    return BlockUserResponse(
      success: json['success'] as bool,
      blockId: json['block_id'] as String,
      status: json['status'] as String,
      message: json['message'] as String,
    );
  }
}

/// Restrict user response DTO
class RestrictUserResponse {
  final bool success;
  final String restrictId;
  final String status;
  final String message;

  RestrictUserResponse({
    required this.success,
    required this.restrictId,
    required this.status,
    required this.message,
  });

  factory RestrictUserResponse.fromJson(Map<String, dynamic> json) {
    return RestrictUserResponse(
      success: json['success'] as bool,
      restrictId: json['restrict_id'] as String,
      status: json['status'] as String,
      message: json['message'] as String,
    );
  }
}

/// Unmatch response DTO
class UnmatchResponse {
  final bool success;
  final String message;
  final bool isMutual;

  UnmatchResponse({
    required this.success,
    required this.message,
    this.isMutual = false,
  });

  factory UnmatchResponse.fromJson(Map<String, dynamic> json) {
    return UnmatchResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      isMutual: json['is_mutual'] as bool,
    );
  }
}

/// Interact user response DTO
class InteractUserResponse {
  final bool success;
  final String actionTaken;
  final dynamic result;

  InteractUserResponse({
    required this.success,
    required this.actionTaken,
    this.result,
  });

  factory InteractUserResponse.fromJson(Map<String, dynamic> json) {
    return InteractUserResponse(
      success: json['success'] as bool,
      actionTaken: json['action_taken'] as String,
      result: json['result'],
    );
  }
}