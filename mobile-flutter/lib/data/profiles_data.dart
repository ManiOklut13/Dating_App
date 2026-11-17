import 'package:flutter/material.dart';
import '../models/discovery_connect_models.dart';

/// Safe image loader that gracefully falls back to a working portrait if an asset or URL fails
class SafeProfileImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const SafeProfileImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  static const String _fallbackUrl =
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=800&q=80';

  @override
  Widget build(BuildContext context) {
    Widget img;
    if (imageUrl.startsWith('http')) {
      img = Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => Image.network(
          _fallbackUrl,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) => Container(
            width: width,
            height: height,
            color: const Color(0xFF2B091C),
            alignment: Alignment.center,
            child: const Icon(Icons.person, color: Color(0xFFFF8DA1), size: 28),
          ),
        ),
      );
    } else {
      final cleanPath = imageUrl.startsWith('/')
          ? 'assets/images$imageUrl'
          : imageUrl;
      img = Image.asset(
        cleanPath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => Image.network(
          _fallbackUrl,
          width: width,
          height: height,
          fit: fit,
        ),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: img);
    }
    return img;
  }
}

final ScheduledDateModel kDemoScheduledDate = ScheduledDateModel(
  id: 'sd_1',
  withUserId: 'p-01',
  nickname: 'Ananya',
  avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=800&q=80',
  venue: 'Olive Bistro, Jubilee Hills',
  address: 'Road No. 46, Jubilee Hills, Hyderabad, Telangana 500033',
  city: 'Hyderabad',
  scheduledAt: DateTime(2026, 11, 16, 18, 30),
  durationMins: 120,
  isDate: true,
  activityType: 'Specialty Coffee Tasting & Vinyl Browsing ☕🎵',
  dressCode: 'Smart Casual / Indie Chic 👗',
  tableReservation: 'Corner Vinyl Lounge (Reserved under "YoUnMe")',
  romanticMilestone: '7-Day Connection Streak 🔥 • 98% Compatibility Vibe',
  sharedPlaylist: 'Acoustic Sunset Romance • 18 Songs Curated for Two',
  vibeNotes:
      'Subko has cozy candlelit booths, artisan sourdough croissants, and an eclectic vinyl selection. Perfect quiet ambiance to chat and unwind together.',
);

const List<CandidateCard> kDemoProfiles = [
  CandidateCard(
    userId: 'p-01',
    nickname: 'Ananya',
    age: 24,
    gender: 'female',
    city: 'Mumbai (Bandra)',
    distanceKm: 0.6,
    bio: 'UI designer & matcha lover 🍵 Seeking someone who laughs at witty dry humor. Let\'s explore quaint cafes & vinyl stores.',
    photoUrls: [
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=800&q=80',
    ],
    sharedInterests: ['Specialty Coffee ☕', 'Indie Vinyl 🎵', 'Modern Art 🎨'],
    vibeScore: 98,
    language: 'Telugu',
    sticker: '🦊',
    ringColor: Color(0xFFF43F5E),
  ),
  CandidateCard(
    userId: 'p-02',
    nickname: 'Rohit',
    age: 24,
    gender: 'male',
    city: 'Mumbai (Juhu)',
    distanceKm: 5.3,
    bio: 'Architecting spaces by day, chasing sunsets by evening. Fitness, rock climbing, and deep late-night conversations.',
    photoUrls: [
      'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=800&q=80',
    ],
    sharedInterests: ['Architecture 🏛️', 'Rock Climbing 🧗', 'Sunsets 🌇'],
    vibeScore: 95,
    language: 'Hindi',
    sticker: '🐰',
    ringColor: Color(0xFF38BDF8),
  ),
  CandidateCard(
    userId: 'p-03',
    nickname: 'Riya',
    age: 24,
    gender: 'female',
    city: 'Mumbai (Colaba)',
    distanceKm: 4.1,
    bio: 'Curating art exhibitions, vintage bookstores, and jazz nights. Swipe right if you have an eclectic Spotify playlist.',
    photoUrls: [
      'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=800&q=80',
    ],
    sharedInterests: ['Art Galleries 🖼️', 'Jazz Nights 🎷', 'Pottery 🏺'],
    vibeScore: 96,
    language: 'Tamil',
    sticker: '🐱',
    ringColor: Color(0xFFFB923C),
  ),
  CandidateCard(
    userId: 'p-04',
    nickname: 'Kavya',
    age: 23,
    gender: 'female',
    city: 'Bengaluru, Indiranagar',
    distanceKm: 2.1,
    bio: 'Product designer sketching streetscapes & hoarding artisanal stationery ✏️ South Indian filter coffee > everything else.',
    photoUrls: [
      'https://images.unsplash.com/photo-1610030469983-98e550d6193c?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=800&q=80',
    ],
    sharedInterests: ['Design Systems 📐', 'Filter Coffee ☕', 'Stationery 🖋️'],
    vibeScore: 97,
    language: 'Hindi',
    sticker: '🐰',
    ringColor: Color(0xFF38BDF8),
  ),
  CandidateCard(
    userId: 'p-05',
    nickname: 'Meera',
    age: 25,
    gender: 'female',
    city: 'Hyderabad, Banjara Hills',
    distanceKm: 3.2,
    bio: 'Indie bookstore lover & classical dancer ✨ Strolling around Banjara lake at dusk, discussing magical realism & jazz vinyl.',
    photoUrls: [
      'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=800&q=80',
    ],
    sharedInterests: ['Books 📚', 'Classical Dance 💃', 'Vinyl Records 🎶'],
    vibeScore: 96,
    language: 'English',
    sticker: '🐼',
    ringColor: Color(0xFFA855F7),
  ),
  CandidateCard(
    userId: 'p-06',
    nickname: 'Ishita',
    age: 26,
    gender: 'female',
    city: 'Hyderabad, Gachibowli',
    distanceKm: 4.5,
    bio: 'Fintech lead & weekend badminton player 🏸 Obsessed with sourdough baking, indie podcasts, and impromptu road trips.',
    photoUrls: [
      'https://images.unsplash.com/photo-1567532939604-b6b5b0db2604?auto=format&fit=crop&w=800&q=80',
    ],
    sharedInterests: ['Badminton 🏸', 'Sourdough 🥖', 'Tech Startups 🚀'],
    vibeScore: 95,
    language: 'Kannada',
    sticker: '🦄',
    ringColor: Color(0xFF22C55E),
  ),
  CandidateCard(
    userId: 'p-07',
    nickname: 'Diya',
    age: 23,
    gender: 'female',
    city: 'Bengaluru, Koramangala',
    distanceKm: 3.0,
    bio: 'Data scientist with an obsession for street photography & rooftop sunsets 🌇 Let\'s grab artisanal gelato and talk sci-fi.',
    photoUrls: [
      'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?auto=format&fit=crop&w=800&q=80',
    ],
    sharedInterests: ['Street Photography 📸', 'Gelato 🍨', 'Sci-Fi 🚀'],
    vibeScore: 94,
    language: 'Malayalam',
    sticker: '🌸',
    ringColor: Color(0xFFEC4899),
  ),
  CandidateCard(
    userId: 'p-08',
    nickname: 'Aisha',
    age: 25,
    gender: 'female',
    city: 'Hyderabad, Madhapur',
    distanceKm: 2.2,
    bio: 'Architectural conservator & heritage walk enthusiast 🏛️ Love Hyderabadi chai, Urdu poetry, and quiet museum afternoons.',
    photoUrls: [
      'https://images.unsplash.com/photo-1616683693504-3ea7e9ad6fec?auto=format&fit=crop&w=800&q=80',
    ],
    sharedInterests: ['Heritage Walks 🏛️', 'Irani Chai ☕', 'Poetry 📜'],
    vibeScore: 93,
    language: 'Telugu',
    sticker: '🐻',
    ringColor: Color(0xFFFACC15),
  ),
  CandidateCard(
    userId: 'p-09',
    nickname: 'Tanvi',
    age: 24,
    gender: 'female',
    city: 'Mumbai, Juhu',
    distanceKm: 3.6,
    bio: 'Contemporary dancer & ocean swimmer 🌊 Catch me barefoot on the sand or hunting for the city\'s spiciest pani puri.',
    photoUrls: [
      'https://images.unsplash.com/photo-1607746882042-944635dfe10e?auto=format&fit=crop&w=800&q=80',
    ],
    sharedInterests: ['Dance 💃', 'Ocean Swims 🏊‍♀️', 'Street Food 🍲'],
    vibeScore: 92,
    language: 'Hindi',
    sticker: '🐯',
    ringColor: Color(0xFF14B8A6),
  ),
  CandidateCard(
    userId: 'p-10',
    nickname: 'Kriti',
    age: 26,
    gender: 'female',
    city: 'Bengaluru, HSR Layout',
    distanceKm: 4.1,
    bio: 'Brand strategist & amateur mixologist 🍸 Vinyl records, lush plant nurseries, and deep conversations about psychology.',
    photoUrls: [
      'https://images.unsplash.com/photo-1616766098956-c81f12114571?auto=format&fit=crop&w=800&q=80',
    ],
    sharedInterests: ['Mixology 🍹', 'Plant Care 🌿', 'Psychology 🧠'],
    vibeScore: 91,
    language: 'English',
    sticker: '🍓',
    ringColor: Color(0xFFF43F5E),
  ),
  CandidateCard(
    userId: 'p-11',
    nickname: 'Arjun',
    age: 27,
    gender: 'male',
    city: 'Hyderabad, Jubilee Hills',
    distanceKm: 1.8,
    bio: 'Creative director & marathon runner 🏃‍♂️ Morning trails, vintage motorbikes, and finding the best biryani spots in town.',
    photoUrls: [
      'https://images.unsplash.com/photo-1622253692010-333f2da6031d?auto=format&fit=crop&w=800&q=80',
    ],
    sharedInterests: ['Marathon 🏃‍♂️', 'Vintage Bikes 🏍️', 'Biryani 🍛'],
    vibeScore: 93,
    language: 'Kannada',
    sticker: '🦋',
    ringColor: Color(0xFFA855F7),
  ),
  CandidateCard(
    userId: 'p-12',
    nickname: 'Aditya',
    age: 28,
    gender: 'male',
    city: 'Bengaluru, Lavelle Road',
    distanceKm: 2.7,
    bio: 'Venture architect & jazz saxophonist 🎷 Pour-over coffee nerd, architectural sketching, and spontaneous weekend getaways.',
    photoUrls: [
      'https://images.unsplash.com/photo-1615813967515-e1838c1c5116?auto=format&fit=crop&w=800&q=80',
    ],
    sharedInterests: ['Pour Over ☕', 'Live Jazz 🎷', 'Architecture 🏛️'],
    vibeScore: 95,
    language: 'Malayalam',
    sticker: '🐥',
    ringColor: Color(0xFFFACC15),
  ),
];

const List<SparkCrushItem> kSparkCrushList = [
  SparkCrushItem(
    id: 'sc-1',
    name: 'Ananya',
    age: 24,
    city: 'Hyderabad, Jubilee Hills',
    avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=800&q=80',
    type: 'mega_crush',
    direction: 'received',
    timestamp: '15m ago',
    interests: ['Specialty Coffee ☕', 'Indie Vinyl 🎵', 'Modern Art 🎨'],
  ),
  SparkCrushItem(
    id: 'sc-2',
    name: 'Kavya',
    age: 23,
    city: 'Bengaluru, Indiranagar',
    avatar: 'https://images.unsplash.com/photo-1610030469983-98e550d6193c?auto=format&fit=crop&w=800&q=80',
    type: 'spark',
    direction: 'received',
    timestamp: '1h ago',
    interests: ['Design Systems 📐', 'Filter Coffee ☕'],
  ),
  SparkCrushItem(
    id: 'sc-3',
    name: 'Meera',
    age: 25,
    city: 'Hyderabad, Banjara Hills',
    avatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=800&q=80',
    type: 'mega_crush',
    direction: 'sent',
    timestamp: '3h ago',
    interests: ['Books 📚', 'Classical Dance 💃', 'Vinyl 🎶'],
  ),
  SparkCrushItem(
    id: 'sc-4',
    name: 'Riya',
    age: 24,
    city: 'Mumbai, Bandra West',
    avatar: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=800&q=80',
    type: 'spark',
    direction: 'received',
    timestamp: '5h ago',
    interests: ['Pottery 🏺', 'Acoustic Rock 🎸'],
  ),
  SparkCrushItem(
    id: 'sc-5',
    name: 'Ishita',
    age: 26,
    city: 'Hyderabad, Gachibowli',
    avatar: 'https://images.unsplash.com/photo-1567532939604-b6b5b0db2604?auto=format&fit=crop&w=800&q=80',
    type: 'spark',
    direction: 'sent',
    timestamp: 'Yesterday',
    interests: ['Badminton 🏸', 'Tech Startups 🚀'],
  ),
];

const List<String> kIcebreakerPrompts = [
  "☕ If we met for coffee, what's your go-to order?",
  "🎵 What's one song that never fails to lift your mood?",
  "✈️ Spontaneous weekend getaway or cozy movie marathon?",
  "🌮 Best street food hidden gem in your city?",
  "🎨 If you could master any skill overnight, what would it be?",
  "📖 What's the last book that genuinely moved you?",
];

List<MatchHistoryItem> generate50Matches() {
  final List<MatchHistoryItem> list = [];
  for (int i = 0; i < 50; i++) {
    final p = kDemoProfiles[i % kDemoProfiles.length];
    list.add(
      MatchHistoryItem(
        id: 'match_${i + 1}',
        userId: p.userId,
        name: p.nickname,
        age: p.age + (i % 3),
        gender: p.gender,
        city: p.city.split('(').first.split(',').first.trim(),
        avatar: p.photoUrls.first,
        matchPercentage: 99 - (i % 18),
        vibeScore: 98 - (i % 12),
        lastActive: i % 3 == 0 ? 'Active now' : 'Active ${(i * 3) % 50 + 5}m ago',
        distanceKm: p.distanceKm,
        preferences: p.preference,
        bio: p.bio,
        sharedInterests: p.sharedInterests,
      ),
    );
  }
  return list;
}

final ScheduledDateModel demoScheduledDate = kDemoScheduledDate;
const List<SparkCrushItem> sparkCrushList = kSparkCrushList;
List<LikeHistoryItem> generate50History() => generate50LikesHistory();

const List<RandomCallAvatarProfile> randomCallAvatarProfiles = [
  RandomCallAvatarProfile(
    id: 'rc_1',
    name: 'Ananya',
    sticker: '🦊',
    language: 'Telugu',
    avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=800&q=80',
    ringColor: Color(0xFFF43F5E),
  ),
  RandomCallAvatarProfile(
    id: 'rc_2',
    name: 'Kavya',
    sticker: '🐰',
    language: 'Hindi',
    avatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=800&q=80',
    ringColor: Color(0xFF38BDF8),
  ),
  RandomCallAvatarProfile(
    id: 'rc_3',
    name: 'Meera',
    sticker: '🐼',
    language: 'English',
    avatar: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=800&q=80',
    ringColor: Color(0xFF22C55E),
  ),
  RandomCallAvatarProfile(
    id: 'rc_4',
    name: 'Riya',
    sticker: '🐱',
    language: 'Tamil',
    avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=800&q=80',
    ringColor: Color(0xFFA855F7),
  ),
  RandomCallAvatarProfile(
    id: 'rc_5',
    name: 'Kriti',
    sticker: '🐨',
    language: 'English',
    avatar: 'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?auto=format&fit=crop&w=800&q=80',
    ringColor: Color(0xFFEC4899),
  ),
  RandomCallAvatarProfile(
    id: 'rc_6',
    name: 'Tanvi',
    sticker: '🐯',
    language: 'Hindi',
    avatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=800&q=80',
    ringColor: Color(0xFFF59E0B),
  ),
  RandomCallAvatarProfile(
    id: 'rc_7',
    name: 'Alisha',
    sticker: '🦄',
    language: 'Telugu',
    avatar: 'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?auto=format&fit=crop&w=800&q=80',
    ringColor: Color(0xFF06B6D4),
  ),
  RandomCallAvatarProfile(
    id: 'rc_8',
    name: 'Diya',
    sticker: '🐶',
    language: 'Malayalam',
    avatar: 'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?auto=format&fit=crop&w=800&q=80',
    ringColor: Color(0xFF10B981),
  ),
  RandomCallAvatarProfile(
    id: 'rc_9',
    name: 'Ishita',
    sticker: '🦁',
    language: 'Kannada',
    avatar: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=800&q=80',
    ringColor: Color(0xFF8B5CF6),
  ),
];

List<LikeHistoryItem> generate50LikesHistory() {
  final List<LikeHistoryItem> list = [];
  const types = ['like', 'spark', 'mega_crush', 'passed', 'like'];
  for (int i = 0; i < 50; i++) {
    final p = kDemoProfiles[i % kDemoProfiles.length];
    list.add(
      LikeHistoryItem(
        id: 'lh_${i + 1}',
        userId: p.userId,
        name: p.nickname,
        age: p.age + (i % 4),
        gender: p.gender,
        city: p.city.split('(').first.split(',').first.trim(),
        avatar: p.photoUrls.first,
        type: types[i % types.length],
        timestamp: i < 4 ? '${(i + 1) * 2}h ago' : 'Yesterday',
        interests: p.sharedInterests,
        bio: p.bio,
      ),
    );
  }
  return list;
}


