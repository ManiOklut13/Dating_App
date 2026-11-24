import 'package:flutter/material.dart';

/// Extra profile facts that the reference Profile Tab shows but the shared
/// [UserProfileModel] does not carry (area, languages, discovery settings).
/// Kept local to the profile folder so no file outside it has to change.
@immutable
class ProfileDetails {
  final String area;
  final double distanceKm;
  final List<String> languages;
  final String lookingFor;
  final String interestedIn;
  final int minAge;
  final int maxAge;
  final int maxDistanceKm;
  final List<String> activities;
  final int photoLimit;

  /// Locked identity values shown (read-only) in Edit Profile.
  final String nickname;
  final String dateOfBirth;
  final String gender;
  final String sexualOrientation;

  const ProfileDetails({
    required this.area,
    required this.distanceKm,
    required this.languages,
    required this.lookingFor,
    required this.interestedIn,
    required this.minAge,
    required this.maxAge,
    required this.maxDistanceKm,
    required this.activities,
    required this.photoLimit,
    required this.nickname,
    required this.dateOfBirth,
    required this.gender,
    required this.sexualOrientation,
  });

  static const ProfileDetails defaults = ProfileDetails(
    area: 'Jubilee Hills',
    distanceKm: 3.2,
    languages: ['English', 'Hindi', 'Telugu'],
    lookingFor: 'Dating',
    interestedIn: 'Women',
    minAge: 21,
    maxAge: 30,
    maxDistanceKm: 25,
    activities: [
      'Listen to music',
      'Watch movies',
      'Coffee walks',
      'Art galleries',
    ],
    photoLimit: 6,
    nickname: 'Alex',
    dateOfBirth: '06/15/1999',
    gender: 'Man',
    sexualOrientation: 'Straight',
  );

  ProfileDetails copyWith({
    String? area,
    double? distanceKm,
    List<String>? languages,
    String? lookingFor,
    String? interestedIn,
    int? minAge,
    int? maxAge,
    int? maxDistanceKm,
    List<String>? activities,
    int? photoLimit,
    String? nickname,
    String? dateOfBirth,
    String? gender,
    String? sexualOrientation,
  }) {
    return ProfileDetails(
      area: area ?? this.area,
      distanceKm: distanceKm ?? this.distanceKm,
      languages: languages ?? this.languages,
      lookingFor: lookingFor ?? this.lookingFor,
      interestedIn: interestedIn ?? this.interestedIn,
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      activities: activities ?? this.activities,
      photoLimit: photoLimit ?? this.photoLimit,
      nickname: nickname ?? this.nickname,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      sexualOrientation: sexualOrientation ?? this.sexualOrientation,
    );
  }

  String get distanceLabel => '${distanceKm.toStringAsFixed(1)} km away';

  String get ageRangeLabel => '$minAge – $maxAge years old';

  String get maxDistanceLabel => 'Within $maxDistanceKm km';
}

/// Extra selectable interests offered by the edit sheet.
const List<String> kExtraInterests = [
  'Specialty Espresso',
  'Mechanical Keyboards',
  'Reading',
  'Gaming',
  'Cooking',
  'Running',
];

const List<String> kLookingForOptions = [
  'Dating',
  'Long-term',
  'Friendship',
  'Something casual',
];

const List<String> kInterestedInOptions = ['Women', 'Men', 'Everyone'];

const List<String> kGenderOptions = [
  'Man',
  'Woman',
  'Non-binary',
  'Prefer not to say',
];

const List<String> kSexualOrientationOptions = [
  'Straight',
  'Gay',
  'Lesbian',
  'Bisexual',
  'Pansexual',
  'Asexual',
  'Prefer not to say',
];

const List<String> kActivityOptions = [
  'Listen to music',
  'Watch movies',
  'Coffee walks',
  'Art galleries',
  'Board game nights',
  'Sunset drives',
  'Live gigs',
  'Cooking together',
];

/// Accent colours used across the profile cards (screenshot palette).
class ProfilePalette {
  ProfilePalette._();

  static const Color pink = Color(0xFFFF2D6F);
  static const Color magenta = Color(0xFFE5326F);
  static const Color purple = Color(0xFF9B5CF6);
  static const Color cyan = Color(0xFF33E1F2);
  static const Color green = Color(0xFF23D18B);
  static const Color gold = Color(0xFFFFC542);
  static const Color blue = Color(0xFF4FA8FF);
  static const Color danger = Color(0xFFFF4D6D);

  static const LinearGradient banner = LinearGradient(
    colors: [Color(0xFFF0356F), Color(0xFFA34BEA), Color(0xFF35C8EA)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient primaryButton = LinearGradient(
    colors: [Color(0xFFF4386C), Color(0xFFE92C61)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient promptCard = LinearGradient(
    colors: [Color(0x33A64DFF), Color(0x22F0356F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient progressCard = LinearGradient(
    colors: [Color(0xFF12202B), Color(0xFF121826)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient completedChecklistItem = LinearGradient(
    colors: [Color(0xFF102A21), Color(0xFF0E2130)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
