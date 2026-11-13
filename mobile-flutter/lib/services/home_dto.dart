import 'dart:convert';

/// Home notifications response DTO
class HomeNotificationsResponse {
  final bool success;
  final List<NotificationDto> notifications;
  final int unreadCount;

  HomeNotificationsResponse({
    required this.success,
    required this.notifications,
    required this.unreadCount,
  });

  factory HomeNotificationsResponse.fromJson(Map<String, dynamic> json) {
    return HomeNotificationsResponse(
      success: json['success'] as bool,
      notifications: (json['notifications'] as List?)
          ?.map((n) => NotificationDto.fromJson(n as Map<String, dynamic>))
          .toList() ?? [],
      unreadCount: (json['unread_count'] as num).toInt(),
    );
  }
}

/// Notification DTO
class NotificationDto {
  final String id;
  final String type; // 'like', 'match', 'message', 'super_like', etc.
  final String title;
  final String body;
  final String timestamp;
  final bool isRead;
  final String targetId; // User ID or match ID
  final dynamic targetData; // Additional data

  NotificationDto({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.isRead,
    required this.targetId,
    this.targetData,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    return NotificationDto(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      timestamp: json['timestamp'] as String,
      isRead: json['is_read'] as bool,
      targetId: json['target_id'] as String,
      targetData: json['target_data'],
    );
  }
}

/// Wallet balance response DTO
class WalletBalanceResponse {
  final bool success;
  final WalletBalanceDto balance;

  WalletBalanceResponse({
    required this.success,
    required this.balance,
  });

  factory WalletBalanceResponse.fromJson(Map<String, dynamic> json) {
    return WalletBalanceResponse(
      success: json['success'] as bool,
      balance: WalletBalanceDto.fromJson(json['balance'] as Map<String, dynamic>),
    );
  }
}

/// Wallet balance DTO
class WalletBalanceDto {
  final int coinBalance;
  final int lockedCoins;
  final int lifetimeEarnedCoins;
  final int lifetimeSpentCoins;
  final int currentStreakDays;
  final int longestStreakDays;
  final DateTime? lastClaimedDate;
  final bool canCashOut;
  final bool canPurchasePacks;

  WalletBalanceDto({
    required this.coinBalance,
    required this.lockedCoins,
    required this.lifetimeEarnedCoins,
    required this.lifetimeSpentCoins,
    required this.currentStreakDays,
    required this.longestStreakDays,
    this.lastClaimedDate,
    required this.canCashOut,
    required this.canPurchasePacks,
  });

  factory WalletBalanceDto.fromJson(Map<String, dynamic> json) {
    return WalletBalanceDto(
      coinBalance: (json['coin_balance'] as num).toInt(),
      lockedCoins: (json['locked_coins'] as num).toInt(),
      lifetimeEarnedCoins: (json['lifetime_earned_coins'] as num).toInt(),
      lifetimeSpentCoins: (json['lifetime_spent_coins'] as num).toInt(),
      currentStreakDays: (json['current_streak_days'] as num).toInt(),
      longestStreakDays: (json['longest_streak_days'] as num).toInt(),
      lastClaimedDate: json['last_claimed_date'] != null
          ? DateTime.parse(json['last_claimed_date'] as String)
          : null,
      canCashOut: json['can_cash_out'] as bool,
      canPurchasePacks: json['can_purchase_packs'] as bool,
    );
  }
}

/// Coin packs browsing response DTO
class CoinPacksResponse {
  final bool success;
  final List<CoinPackDto> packs;
  final bool hasPremiumAccess;

  CoinPacksResponse({
    required this.success,
    required this.packs,
    required this.hasPremiumAccess,
  });

  factory CoinPacksResponse.fromJson(Map<String, dynamic> json) {
    return CoinPacksResponse(
      success: json['success'] as bool,
      packs: (json['packs'] as List)
          .map((p) => CoinPackDto.fromJson(p as Map<String, dynamic>))
          .toList(),
      hasPremiumAccess: json['has_premium_access'] as bool,
    );
  }
}

/// Coin pack DTO
class CoinPackDto {
  final String packId;
  final String name;
  final String description;
  final int coinCount;
  final int price;
  final String priceCurrency;
  final bool isSubscription;
  final String? subscriptionDuration;
  final String? imageUrl;
  final List<String>? features;

  CoinPackDto({
    required this.packId,
    required this.name,
    required this.description,
    required this.coinCount,
    required this.price,
    required this.priceCurrency,
    this.isSubscription = false,
    this.subscriptionDuration,
    this.imageUrl,
    this.features,
  });

  factory CoinPackDto.fromJson(Map<String, dynamic> json) {
    return CoinPackDto(
      packId: json['pack_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      coinCount: (json['coin_count'] as num).toInt(),
      price: (json['price'] as num).toInt(),
      priceCurrency: json['price_currency'] as String,
      isSubscription: json['is_subscription'] as bool,
      subscriptionDuration: json['subscription_duration'] as String?,
      imageUrl: json['image_url'] as String?,
      features: (json['features'] as List?)
          ?.map((f) => f as String)
          .toList(),
    );
  }
}

/// Coin pack detail response DTO
class CoinPackDetailResponse {
  final bool success;
  final CoinPackDto pack;
  final bool canPurchase;

  CoinPackDetailResponse({
    required this.success,
    required this.pack,
    required this.canPurchase,
  });

  factory CoinPackDetailResponse.fromJson(Map<String, dynamic> json) {
    return CoinPackDetailResponse(
      success: json['success'] as bool,
      pack: CoinPackDto.fromJson(json['pack'] as Map<String, dynamic>),
      canPurchase: json['can_purchase'] as bool,
    );
  }
}

/// Purchase response DTO
class PurchaseResponse {
  final bool success;
  final String transactionId;
  final int coinsAdded;
  final int coinsRemaining;
  final String status;

  PurchaseResponse({
    required this.success,
    required this.transactionId,
    required this.coinsAdded,
    required this.coinsRemaining,
    required this.status,
  });

  factory PurchaseResponse.fromJson(Map<String, dynamic> json) {
    return PurchaseResponse(
      success: json['success'] as bool,
      transactionId: json['transaction_id'] as String,
      coinsAdded: (json['coins_added'] as num).toInt(),
      coinsRemaining: (json['coins_remaining'] as num).toInt(),
      status: json['status'] as String,
    );
  }
}

/// Cash-out response DTO
class CashOutResponse {
  final bool success;
  final String transactionId;
  final double amount;
  final String status;
  final String paymentMethod;

  CashOutResponse({
    required this.success,
    required this.transactionId,
    required this.amount,
    required this.status,
    this.paymentMethod,
  });

  factory CashOutResponse.fromJson(Map<String, dynamic> json) {
    return CashOutResponse(
      success: json['success'] as bool,
      transactionId: json['transaction_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      paymentMethod: json['payment_method'] as String?,
    );
  }
}

/// Transaction history response DTO
class TransactionHistoryResponse {
  final bool success;
  final List<TransactionDto> transactions;
  final int totalCount;

  TransactionHistoryResponse({
    required this.success,
    required this.transactions,
    required this.totalCount,
  });

  factory TransactionHistoryResponse.fromJson(Map<String, dynamic> json) {
    return TransactionHistoryResponse(
      success: json['success'] as bool,
      transactions: (json['transactions'] as List)
          .map((t) => TransactionDto.fromJson(t as Map<String, dynamic>))
          .toList(),
      totalCount: (json['total_count'] as num).toInt(),
    );
  }
}

/// Transaction DTO
class TransactionDto {
  final String transactionId;
  final String type; // 'earn', 'spend', 'cash_out', 'bonus'
  final int amount;
  final String description;
  final DateTime timestamp;
  final String? relatedId; // match ID, pack ID, etc.

  TransactionDto({
    required this.transactionId,
    required this.type,
    required this.amount,
    required this.description,
    required this.timestamp,
    this.relatedId,
  });

  factory TransactionDto.fromJson(Map<String, dynamic> json) {
    return TransactionDto(
      transactionId: json['transaction_id'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toInt(),
      description: json['description'] as String,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      relatedId: json['related_id'] as String?,
    );
  }
}

/// Referral response DTO
class ReferralResponse {
  final bool success;
  final ReferralDto referral;

  ReferralResponse({
    required this.success,
    required this.referral,
  });

  factory ReferralResponse.fromJson(Map<String, dynamic> json) {
    return ReferralResponse(
      success: json['success'] as bool,
      referral: ReferralDto.fromJson(json['referral'] as Map<String, dynamic>),
    );
  }
}

/// Referral DTO
class ReferralDto {
  final String referralCode;
  final String inviteLink;
  final int coinsEarned;
  final int friendsJoined;
  final int? totalCoinsEarned;

  ReferralDto({
    required this.referralCode,
    required this.inviteLink,
    required this.coinsEarned,
    required this.friendsJoined,
    this.totalCoinsEarned,
  });

  factory ReferralDto.fromJson(Map<String, dynamic> json) {
    return ReferralDto(
      referralCode: json['referral_code'] as String,
      inviteLink: json['invite_link'] as String,
      coinsEarned: (json['coins_earned'] as num).toInt(),
      friendsJoined: (json['friends_joined'] as num).toInt(),
      totalCoinsEarned: json['total_coins_earned'] as int?,
    );
  }
}

/// Streak status response DTO
class StreakStatusResponse {
  final bool success;
  final StreakDto streak;

  StreakStatusResponse({
    required this.success,
    required this.streak,
  });

  factory StreakStatusResponse.fromJson(Map<String, dynamic> json) {
    return StreakStatusResponse(
      success: json['success'] as bool,
      streak: StreakDto.fromJson(json['streak'] as Map<String, dynamic>),
    );
  }
}

/// Streak DTO
class StreakDto {
  final int currentStreakDays;
  final int longestStreakDays;
  final String lastActivityDate;
  final bool isOnStreak;
  final int? streakPoints;
  final bool canClaimToday;
  final String? nextClaimTime;

  StreakDto({
    required this.currentStreakDays,
    required this.longestStreakDays,
    required this.lastActivityDate,
    required this.isOnStreak,
    this.streakPoints,
    this.canClaimToday,
    this.nextClaimTime,
  });

  factory StreakDto.fromJson(Map<String, dynamic> json) {
    return StreakDto(
      currentStreakDays: (json['current_streak_days'] as num).toInt(),
      longestStreakDays: (json['longest_streak_days'] as num).toInt(),
      lastActivityDate: json['last_activity_date'] as String,
      isOnStreak: json['is_on_streak'] as bool,
      streakPoints: json['streak_points'] as int?,
      canClaimToday: json['can_claim_today'] as bool,
      nextClaimTime: json['next_claim_time'] as String?,
    );
  }
}

/// Spin-the-wheel response DTO
class SpinWheelResponse {
  final bool success;
  final SpinWheelDto result;
  final int spinsRemaining;
  final bool adRequiredForDouble;

  SpinWheelResponse({
    required this.success,
    required this.result,
    required this.spinsRemaining,
    this.adRequiredForDouble = false,
  });

  factory SpinWheelResponse.fromJson(Map<String, dynamic> json) {
    return SpinWheelResponse(
      success: json['success'] as bool,
      result: SpinWheelDto.fromJson(json['result'] as Map<String, dynamic>),
      spinsRemaining: (json['spins_remaining'] as num).toInt(),
      adRequiredForDouble: json['ad_required_for_double'] as bool,
    );
  }
}

/// Spin-wheel result DTO
class SpinWheelDto {
  final String prizeType; // 'coins', 'collectible', 'boost', etc.
  final dynamic prizeValue; // coin count, collectible ID, boost type
  final int coinAmount;
  final bool won;

  SpinWheelDto({
    required this.prizeType,
    required this.prizeValue,
    required this.coinAmount,
    required this.won,
  });

  factory SpinWheelDto.fromJson(Map<String, dynamic> json) {
    return SpinWheelDto(
      prizeType: json['prize_type'] as String,
      prizeValue: json['prize_value'],
      coinAmount: (json['coin_amount'] as num).toInt(),
      won: json['won'] as bool,
    );
  }
}

/// Spin-wheel double bonus response DTO
class SpinWheelDoubleResponse {
  final bool success;
  final SpinWheelDto result;
  final bool adWatched;
  final double bonusMultiplier;

  SpinWheelDoubleResponse({
    required this.success,
    required this.result,
    required this.adWatched,
    required this.bonusMultiplier,
  });

  factory SpinWheelDoubleResponse.fromJson(Map<String, dynamic> json) {
    return SpinWheelDoubleResponse(
      success: json['success'] as bool,
      result: SpinWheelDto.fromJson(json['result'] as Map<String, dynamic>),
      adWatched: json['ad_watched'] as bool,
      bonusMultiplier: (json['bonus_multiplier'] as num).toDouble(),
    );
  }
}

/// Reward claim response DTO
class RewardClaimResponse {
  final bool success;
  final String rewardId;
  final String rewardType;
  final int coinsGained;
  final String status;

  RewardClaimResponse({
    required this.success,
    required this.rewardId,
    required this.rewardType,
    required this.coinsGained,
    required this.status,
  });

  factory RewardClaimResponse.fromJson(Map<String, dynamic> json) {
    return RewardClaimResponse(
      success: json['success'] as bool,
      rewardId: json['reward_id'] as String,
      rewardType: json['reward_type'] as String,
      coinsGained: (json['coins_gained'] as num).toInt(),
      status: json['status'] as String,
    );
  }
}

/// Collectibles list response DTO
class CollectiblesListResponse {
  final bool success;
  final List<CollectibleDto> collectibles;
  final int totalCount;

  CollectiblesListResponse({
    required this.success,
    required this.collectibles,
    required this.totalCount,
  });

  factory CollectiblesListResponse.fromJson(Map<String, dynamic> json) {
    return CollectiblesListResponse(
      success: json['success'] as bool,
      collectibles: (json['collectibles'] as List)
          .map((c) => CollectibleDto.fromJson(c as Map<String, dynamic>))
          .toList(),
      totalCount: (json['total_count'] as num).toInt(),
    );
  }
}

/// Collectible DTO
class CollectibleDto {
  final String collectibleId;
  final String name;
  final String description;
  final String iconUrl;
  final String rarity; // 'common', 'rare', 'epic', 'legendary'
  final int costCoins;
  final bool isOwned;
  final String? descriptionPreview;

  CollectibleDto({
    required this.collectibleId,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.rarity,
    required this.costCoins,
    this.isOwned = false,
    this.descriptionPreview,
  });

  factory CollectibleDto.fromJson(Map<String, dynamic> json) {
    return CollectibleDto(
      collectibleId: json['collectible_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconUrl: json['icon_url'] as String,
      rarity: json['rarity'] as String,
      costCoins: (json['cost_coins'] as num).toInt(),
      isOwned: json['is_owned'] as bool,
      descriptionPreview: json['description_preview'] as String?,
    );
  }
}

/// Collectible detail response DTO
class CollectibleDetailResponse {
  final bool success;
  final CollectibleDto collectible;

  CollectibleDetailResponse({
    required this.success,
    required this.collectible,
  });

  factory CollectibleDetailResponse.fromJson(Map<String, dynamic> json) {
    return CollectibleDetailResponse(
      success: json['success'] as bool,
      collectible: CollectibleDto.fromJson(json['collectible'] as Map<String, dynamic>),
    );
  }
}

/// Collectible buy response DTO
class CollectibleBuyResponse {
  final bool success;
  final String transactionId;
  final String collectibleId;
  final int coinsSpent;
  final bool isNowOwned;
  final String status;

  CollectibleBuyResponse({
    required this.success,
    required this.transactionId,
    required this.collectibleId,
    required this.coinsSpent,
    this.isNowOwned = false,
    required this.status,
  });

  factory CollectibleBuyResponse.fromJson(Map<String, dynamic> json) {
    return CollectibleBuyResponse(
      success: json['success'] as bool,
      transactionId: json['transaction_id'] as String,
      collectibleId: json['collectible_id'] as String,
      coinsSpent: (json['coins_spent'] as num).toInt(),
      isNowOwned: json['is_now_owned'] as bool,
      status: json['status'] as String,
    );
  }
}

/// Active reminder response DTO
class ActiveReminderResponse {
  final bool success;
  final ActiveReminderDto reminder;

  ActiveReminderResponse({
    required this.success,
    required this.reminder,
  });

  factory ActiveReminderResponse.fromJson(Map<String, dynamic> json) {
    return ActiveReminderResponse(
      success: json['success'] as bool,
      reminder: ActiveReminderDto.fromJson(json['reminder'] as Map<String, dynamic>),
    );
  }
}

/// Active reminder DTO
class ActiveReminderDto {
  final bool hasActiveReminder;
  final String reminderText;
  final String date;
  final String? callToAction;
  final String callToActionUrl;

  ActiveReminderDto({
    required this.hasActiveReminder,
    required this.reminderText,
    required this.date,
    this.callToAction,
    this.callToActionUrl,
  });

  factory ActiveReminderDto.fromJson(Map<String, dynamic> json) {
    return ActiveReminderDto(
      hasActiveReminder: json['has_active_reminder'] as bool,
      reminderText: json['reminder_text'] as String,
      date: json['date'] as String,
      callToAction: json['call_to_action'] as String?,
      callToActionUrl: json['call_to_action_url'] as String?,
    );
  }
}

/// Date update response DTO
class DateUpdateResponse {
  final bool success;
  final String dateId;
  final String status;
  final String? updatedAt;

  DateUpdateResponse({
    required this.success,
    required this.dateId,
    required this.status,
    this.updatedAt,
  });

  factory DateUpdateResponse.fromJson(Map<String, dynamic> json) {
    return DateUpdateResponse(
      success: json['success'] as bool,
      dateId: json['date_id'] as String,
      status: json['status'] as String,
      updatedAt: json['updated_at'] as String?,
    );
  }
}

/// Random call bubbles response DTO
class RandomCallBubblesResponse {
  final bool success;
  final List<RandomCallBubbleDto> bubbles;
  final int totalActive;

  RandomCallBubblesResponse({
    required this.success,
    required this.bubbles,
    required this.totalActive,
  });

  factory RandomCallBubblesResponse.fromJson(Map<String, dynamic> json) {
    return RandomCallBubblesResponse(
      success: json['success'] as bool,
      bubbles: (json['bubbles'] as List)
          .map((b) => RandomCallBubbleDto.fromJson(b as Map<String, dynamic>))
          .toList(),
      totalActive: (json['total_active'] as num).toInt(),
    );
  }
}

/// Random call bubble DTO
class RandomCallBubbleDto {
  final String bubbleId;
  final String targetUserId;
  final String nickname;
  final String? avatarUrl;
  final String age;
  final bool isOnline;
  final String daysSinceMatch;
  final String prompt; // Icebreaker question

  RandomCallBubbleDto({
    required this.bubbleId,
    required this.targetUserId,
    required this.nickname,
    this.avatarUrl,
    required this.age,
    required this.isOnline,
    required this.daysSinceMatch,
    required this.prompt,
  });

  factory RandomCallBubbleDto.fromJson(Map<String, dynamic> json) {
    return RandomCallBubbleDto(
      bubbleId: json['bubble_id'] as String,
      targetUserId: json['target_user_id'] as String,
      nickname: json['nickname'] as String,
      avatarUrl: json['avatar_url'] as String?,
      age: json['age'] as String,
      isOnline: json['is_online'] as bool,
      daysSinceMatch: json['days_since_match'] as String,
      prompt: json['prompt'] as String,
    );
  }
}

/// Direct call response DTO
class DirectCallResponse {
  final bool success;
  final String callId;
  final String callType;
  final String token; // LiveKit or similar token
  final String roomUrl;
  final int durationSeconds;
  final String status;

  DirectCallResponse({
    required this.success,
    required this.callId,
    required this.callType,
    required this.token,
    required this.roomUrl,
    this.durationSeconds = 60,
    required this.status,
  });

  factory DirectCallResponse.fromJson(Map<String, dynamic> json) {
    return DirectCallResponse(
      success: json['success'] as bool,
      callId: json['call_id'] as String,
      callType: json['call_type'] as String,
      token: json['token'] as String,
      roomUrl: json['room_url'] as String,
      durationSeconds: (json['duration_seconds'] as num).toInt(),
      status: json['status'] as String,
    );
  }
}