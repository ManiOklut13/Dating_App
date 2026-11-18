import 'package:flutter/material.dart';

class CandidateCard {
  final String userId;
  final String nickname;
  final int age;
  final String gender;
  final String city;
  final double distanceKm;
  final String bio;
  final List<String> photoUrls;
  final bool isVerified;
  final bool isOnline;
  final String lastActive;
  final String preference;
  final List<String> sharedInterests;
  final int profileProgress;
  final int vibeScore;
  final String language;
  final String sticker;
  final Color ringColor;

  const CandidateCard({
    required this.userId,
    required this.nickname,
    required this.age,
    this.gender = 'female',
    required this.city,
    required this.distanceKm,
    required this.bio,
    required this.photoUrls,
    this.isVerified = true,
    this.isOnline = true,
    this.lastActive = 'Active now',
    this.preference = 'Long-term relationship',
    this.sharedInterests = const [],
    this.profileProgress = 95,
    this.vibeScore = 95,
    this.language = 'Telugu',
    this.sticker = '🦊',
    this.ringColor = const Color(0xFFF43F5E),
  });
}

class ScheduledDateModel {
  final String id;
  final String withUserId;
  final String nickname;
  final String avatar;
  final String venue;
  final String address;
  final String city;
  final DateTime scheduledAt;
  final int durationMins;
  final bool isDate;
  final String activityType;
  final String dressCode;
  final String tableReservation;
  final String romanticMilestone;
  final String sharedPlaylist;
  final String vibeNotes;

  const ScheduledDateModel({
    required this.id,
    required this.withUserId,
    required this.nickname,
    required this.avatar,
    required this.venue,
    required this.address,
    required this.city,
    required this.scheduledAt,
    this.durationMins = 120,
    this.isDate = true,
    required this.activityType,
    required this.dressCode,
    required this.tableReservation,
    required this.romanticMilestone,
    required this.sharedPlaylist,
    required this.vibeNotes,
  });
}

class SparkCrushItem {
  final String id;
  final String name;
  final int age;
  final String city;
  final String avatar;
  final String type; // 'mega_crush' | 'spark'
  final String direction; // 'received' | 'sent'
  final String timestamp;
  final List<String> interests;

  const SparkCrushItem({
    required this.id,
    required this.name,
    required this.age,
    required this.city,
    required this.avatar,
    required this.type,
    required this.direction,
    required this.timestamp,
    required this.interests,
  });
}

class LikeHistoryItem {
  final String id;
  final String userId;
  final String name;
  final int age;
  final String gender;
  final String city;
  final String avatar;
  final String type; // 'like' | 'spark' | 'mega_crush' | 'passed'
  final String timestamp;
  final List<String> interests;
  final String bio;

  const LikeHistoryItem({
    required this.id,
    required this.userId,
    required this.name,
    required this.age,
    required this.gender,
    required this.city,
    required this.avatar,
    required this.type,
    required this.timestamp,
    required this.interests,
    required this.bio,
  });
}

class MatchHistoryItem {
  final String id;
  final String userId;
  final String name;
  final int age;
  final String gender;
  final String city;
  final String avatar;
  final int matchPercentage;
  final int vibeScore;
  final String lastActive;
  final double distanceKm;
  final String preferences;
  final String bio;
  final List<String> sharedInterests;

  const MatchHistoryItem({
    required this.id,
    required this.userId,
    required this.name,
    required this.age,
    required this.gender,
    required this.city,
    required this.avatar,
    required this.matchPercentage,
    required this.vibeScore,
    required this.lastActive,
    required this.distanceKm,
    required this.preferences,
    required this.bio,
    required this.sharedInterests,
  });
}

class AppNotificationItem {
  final String id;
  final String kind; // 'streak' | 'like' | 'date' | 'prompt' | 'rubies'
  final String title;
  final String desc;
  final String time;
  bool unread;

  AppNotificationItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.desc,
    required this.time,
    this.unread = false,
  });
}

typedef AppNotification = AppNotificationItem;

class RubyPackage {
  final String id;
  final String name;
  final int rubies;
  final int bonus;
  final String priceInr;
  final bool popular;

  const RubyPackage({
    required this.id,
    required this.name,
    required this.rubies,
    this.bonus = 0,
    required this.priceInr,
    this.popular = false,
  });
}

class RandomCallAvatarProfile {
  final String id;
  final String name;
  final String sticker;
  final String language;
  final String avatar;
  final Color ringColor;

  const RandomCallAvatarProfile({
    required this.id,
    required this.name,
    required this.sticker,
    required this.language,
    required this.avatar,
    required this.ringColor,
  });
}


class RubyTransactionItem {
  final String id;
  final String title;
  final String subtitle;
  final int amount;
  final bool isCredit;

  const RubyTransactionItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isCredit,
  });
}

class OnboardingProfileData {
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final String? userType;
  final String? password;
  final String birthDate;
  final String gender;
  final String orientation;
  final String primaryPhoto;
  final bool autoEnhanced;
  final String intent;
  final List<String> interests;
  final List<String>? interestedIn;
  final String profession;
  final String education;
  final String? city;
  final String height;
  final List<String> languages;
  final String bio;
  final List<String> galleryPhotos;
  final String location;
  final int maxDistance;
  final int ageRangeMax;
  final bool allowNotifications;
  final bool allowLocation;
  final String whoCanMessage; // 'everyone' | 'matches' | 'verified'
  final bool isVoiceVerified;
  final bool isFaceVerified;
  final bool allowContactsSync;

  const OnboardingProfileData({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.userType,
    this.password,
    required this.birthDate,
    required this.gender,
    required this.orientation,
    required this.primaryPhoto,
    required this.autoEnhanced,
    required this.intent,
    required this.interests,
    this.interestedIn,
    required this.profession,
    required this.education,
    this.city,
    required this.height,
    required this.languages,
    required this.bio,
    required this.galleryPhotos,
    required this.location,
    required this.maxDistance,
    required this.ageRangeMax,
    required this.allowNotifications,
    required this.allowLocation,
    required this.whoCanMessage,
    required this.isVoiceVerified,
    required this.isFaceVerified,
    this.allowContactsSync = false,
  });
}

class LoginPayload {
  final String identifier;
  final String? password;
  final String? otp;
  final bool remember;
  final String? method; // 'password' | 'otp' | 'google' | 'apple'

  const LoginPayload({
    required this.identifier,
    this.password,
    this.otp,
    this.remember = true,
    this.method,
  });
}
