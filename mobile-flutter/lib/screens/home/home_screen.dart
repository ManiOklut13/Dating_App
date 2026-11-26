import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../widgets/discovery_action_dock.dart';
import '../../widgets/live_profiles_strip.dart';
import '../../widgets/match_modal.dart';
import '../../widgets/mega_crush_celebration.dart';
import '../../widgets/separated_profile_card.dart';
import '../calls/live_interactive_call_screen.dart';
import 'discovery_filters_screen.dart';
import 'full_profile_screen.dart';
import 'message_request_screen.dart';

class RandomCallUser {
  final String id;
  final String name;
  final int age;
  final String city;
  final String status;
  final IconData avatarIcon;
  final Color avatarBgColor;
  final Color avatarAccentColor;

  const RandomCallUser({
    required this.id,
    required this.name,
    required this.age,
    required this.city,
    required this.status,
    required this.avatarIcon,
    required this.avatarBgColor,
    required this.avatarAccentColor,
  });
}

class LiveProfileUser {
  final String id;
  final String name;
  final int age;
  final String city;
  final IconData avatarIcon;
  final Color avatarBgColor;
  final Color avatarAccentColor;

  const LiveProfileUser({
    required this.id,
    required this.name,
    required this.age,
    required this.city,
    required this.avatarIcon,
    required this.avatarBgColor,
    required this.avatarAccentColor,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentTabIndex = 0;
  int _profileIndex = 0;
  int _photoIndex = 0;
  bool _isAnimatingCard = false;

  Offset _dragOffset = Offset.zero;
  late final AnimationController _swipeAnimController;
  late final AnimationController _photoStatusCtrl;
  Animation<Offset>? _swipeAnimation;
  Map<String, dynamic>? _activeFilters;
  final List<DiscoverySwipeHistoryEntry> _swipeHistory = [];

  // Live Active Users Strip at Top of Home Tab (Avatars Only)
  final List<Map<String, dynamic>> _liveProfiles = const [
    {
      'name': 'Kavya',
      'isLive': true,
      'avatarIcon': Icons.face_4_rounded,
      'avatarBgColor': Color(0xFFFFE5EC),
      'avatarAccentColor': Color(0xFFE94057),
      'imageUrl': 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=300',
    },
    {
      'name': 'Sneha',
      'isLive': true,
      'avatarIcon': Icons.face_3_rounded,
      'avatarBgColor': Color(0xFFE8F0FE),
      'avatarAccentColor': Color(0xFF3B82F6),
      'imageUrl': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=300',
    },
    {
      'name': 'Divya',
      'isLive': true,
      'avatarIcon': Icons.face_retouching_natural,
      'avatarBgColor': Color(0xFFFEF3C7),
      'avatarAccentColor': Color(0xFFD97706),
      'imageUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300',
    },
    {
      'name': 'Riya',
      'isLive': true,
      'avatarIcon': Icons.face_2_rounded,
      'avatarBgColor': Color(0xFFDCFCE7),
      'avatarAccentColor': Color(0xFF16A34A),
      'imageUrl': 'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=300',
    },
    {
      'name': 'Meghana',
      'isLive': true,
      'avatarIcon': Icons.face_rounded,
      'avatarBgColor': Color(0xFFF3E8FF),
      'avatarAccentColor': Color(0xFF9333EA),
      'imageUrl': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=300',
    },
  ];

  // Discovery Stack Profiles
  final List<Map<String, dynamic>> _profiles = const [
    {
      'name': 'Ananya',
      'age': 24,
      'role': 'UI/UX Designer • Hyderabad',
      'distance': '3 km away',
      'goal': 'Long-term Partner',
      'verified': true,
      'bio':
          'Weekend café explorer, street photographer, and always up for a late-evening drive.',
      'interests': ['Coffee Lover', 'Photography', 'Road Trips', 'Telugu Melodies'],
      'imageUrl': 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=900',
      'imageUrls': [
        'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=900',
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=900',
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=900',
      ],
    },
    {
      'name': 'Riya',
      'age': 23,
      'role': 'Product Analyst • Jubilee Hills',
      'distance': '5 km away',
      'goal': 'New Friends',
      'verified': true,
      'bio':
          'Badminton addict, biryani critic, and binge-watching sci-fi series on weekends.',
      'interests': ['Badminton', 'Anime', 'Street Food', 'Live Concerts'],
      'imageUrl': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=900',
      'imageUrls': [
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=900',
        'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=900',
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=900',
      ],
    },
    {
      'name': 'Meghana',
      'age': 25,
      'role': 'Software Engineer • Gachibowli',
      'distance': '4 km away',
      'goal': 'Long-term Partner',
      'verified': true,
      'bio':
          'Building apps by day, baking in my air fryer by night. Looking for great playlists.',
      'interests': ['Coding & Tech', 'Air Fryer Baking', 'Trekking', 'Podcasts'],
      'imageUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=900',
      'imageUrls': [
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=900',
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=900',
        'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=900',
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _swipeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    )..addListener(() {
        if (_swipeAnimation != null) {
          setState(() => _dragOffset = _swipeAnimation!.value);
        }
      });

    _photoStatusCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          final currentProfile = _profiles[_profileIndex % _profiles.length];
          final photos = _photosForProfile(currentProfile);
          setState(() {
            _photoIndex = (_photoIndex + 1) % photos.length;
          });
          _photoStatusCtrl.forward(from: 0.0);
        }
      });
    _photoStatusCtrl.forward();
  }

  @override
  void dispose() {
    _swipeAnimController.dispose();
    _photoStatusCtrl.dispose();
    super.dispose();
  }

  List<String> _photosForProfile(Map<String, dynamic> profile) {
    final urls = (profile['imageUrls'] as List<dynamic>?)
            ?.cast<String>()
            .where((u) => u.isNotEmpty)
            .toList() ??
        const [];
    if (urls.isNotEmpty) return urls;
    final single = profile['imageUrl'] as String? ?? '';
    return [if (single.isNotEmpty) single];
  }

  void _resetPhotoStatus() {
    _photoIndex = 0;
    _photoStatusCtrl.forward(from: 0.0);
  }

  void _nextPhoto(Map<String, dynamic> profile) {
    final photos = _photosForProfile(profile);
    setState(() {
      _photoIndex = (_photoIndex + 1) % photos.length;
    });
    _photoStatusCtrl.forward(from: 0.0);
  }

  void _prevPhoto(Map<String, dynamic> profile) {
    final photos = _photosForProfile(profile);
    setState(() {
      _photoIndex = (_photoIndex - 1 + photos.length) % photos.length;
    });
    _photoStatusCtrl.forward(from: 0.0);
  }

  void _selectPhoto(Map<String, dynamic> profile, int idx) {
    final photos = _photosForProfile(profile);
    setState(() {
      _photoIndex = idx % photos.length;
    });
    _photoStatusCtrl.forward(from: 0.0);
  }

  Future<void> _openDiscoveryFilters() async {
    final updatedFilters = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => DiscoveryFiltersScreen(initialFilters: _activeFilters),
      ),
    );
    if (updatedFilters != null && mounted) {
      setState(() => _activeFilters = updatedFilters);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Filters updated: Age ${updatedFilters['minAge']}-${updatedFilters['maxAge']} • ${updatedFilters['radiusKm']} km',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _startLiveCall(
    Map<String, dynamic> liveUser, {
    required bool isVideo,
  }) {
    final callType = isVideo ? 'Video Call' : 'Audio Call';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting $callType with ${liveUser['name']}...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LiveInteractiveCallScreen(
          userName: liveUser['name'] as String,
          avatarUrl: liveUser['imageUrl'] as String,
          isVideo: isVideo,
        ),
      ),
    );
  }

  void _animateToOffset(Offset target, {VoidCallback? onComplete}) {
    _isAnimatingCard = true;
    _swipeAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: target,
    ).animate(
      CurvedAnimation(parent: _swipeAnimController, curve: Curves.easeOutCubic),
    );
    _swipeAnimController.forward(from: 0).then((_) {
      _isAnimatingCard = false;
      onComplete?.call();
    });
  }

  void _recordHistoryAndAdvance({
    required int profileIndex,
    required Offset exitOffset,
    required bool wasLiked,
  }) {
    final swipedProfile = _profiles[profileIndex % _profiles.length];
    setState(() {
      _swipeHistory.add(
        DiscoverySwipeHistoryEntry(
          profileIndex: profileIndex,
          exitOffset: exitOffset,
          wasLiked: wasLiked,
        ),
      );
      if (_swipeHistory.length > 3) {
        _swipeHistory.removeAt(0);
      }
      _profileIndex = (_profileIndex + 1) % _profiles.length;
      _dragOffset = Offset.zero;
    });
    _resetPhotoStatus();

    if (wasLiked && mounted && (DateTime.now().millisecond % 4 == 0)) {
      showDialog(
        context: context,
        builder: (_) => MatchModal(
          matchedName: swipedProfile['name'] as String,
          matchedAvatar: swipedProfile['imageUrl'] as String,
          onStartChat: () => _openMessageRequest(swipedProfile, profileIndex),
        ),
      );
    }
  }

  void _triggerActionSwipe({
    required Offset exitOffset,
    required bool wasLiked,
  }) {
    if (_isAnimatingCard) return;
    final currentIdx = _profileIndex % _profiles.length;
    _animateToOffset(
      exitOffset,
      onComplete: () => _recordHistoryAndAdvance(
        profileIndex: currentIdx,
        exitOffset: exitOffset,
        wasLiked: wasLiked,
      ),
    );
  }

  void _handleDislike(Size screenSize) {
    _triggerActionSwipe(
      exitOffset: Offset(-screenSize.width * 1.3, 30),
      wasLiked: false,
    );
  }

  void _handleLike(Size screenSize) {
    _triggerActionSwipe(
      exitOffset: Offset(screenSize.width * 1.3, 30),
      wasLiked: true,
    );
  }

  void _handleSpark(Map<String, dynamic> profile, Size screenSize) {
    if (_isAnimatingCard) return;
    final navigator = Navigator.of(context, rootNavigator: true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          MegaCrushCelebration(recipientName: profile['name'] as String),
    );

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      if (navigator.canPop()) {
        navigator.pop();
      }
      _handleLike(screenSize);
    });
  }

  void _handleRevert() {
    if (_isAnimatingCard) return;
    if (_swipeHistory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No swiped profiles to revert in history.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final entry = _swipeHistory.removeLast();
    final prevProfile = _profiles[entry.profileIndex % _profiles.length];

    setState(() {
      _profileIndex = entry.profileIndex % _profiles.length;
      _dragOffset = entry.exitOffset;
    });
    _resetPhotoStatus();
    _animateToOffset(Offset.zero);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '↺ Reverted ${prevProfile['name']}! (${_swipeHistory.length} of 3 rewinds remaining)',
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openMessageRequest(Map<String, dynamic> profile, int index) {
    final candidate = candidateCardFromDiscoveryMap(profile, index);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MessageRequestScreen(profile: candidate),
      ),
    );
  }

  void _openFullProfile(
    Map<String, dynamic> profile,
    int index,
    Size screenSize,
  ) {
    final candidate = candidateCardFromDiscoveryMap(profile, index);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullProfileScreen(
          profile: candidate,
          onLike: () => _handleLike(screenSize),
          onPass: () => _handleDislike(screenSize),
          onMegaCrush: () => _handleSpark(profile, screenSize),
          onDirectMessage: () => _openMessageRequest(profile, index),
        ),
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    _swipeAnimController.stop();
    _isAnimatingCard = false;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details, Size screenSize) {
    final horizontalThreshold = screenSize.width * 0.25;
    final verticalThreshold = screenSize.height * 0.16;
    final currentIdx = _profileIndex % _profiles.length;

    // Horizontal Left / Right Swipe -> Smooth slide out while next card rises underneath
    if (_dragOffset.dx.abs() > horizontalThreshold) {
      final liked = _dragOffset.dx > 0;
      final exitX = liked ? screenSize.width * 1.3 : -screenSize.width * 1.3;
      final exitOffset = Offset(exitX, _dragOffset.dy * 0.8);
      _animateToOffset(
        exitOffset,
        onComplete: () => _recordHistoryAndAdvance(
          profileIndex: currentIdx,
          exitOffset: exitOffset,
          wasLiked: liked,
        ),
      );
      return;
    }

    // Vertical Up / Down Swipe -> Separates cleanly as individual card (never attached)
    if (_dragOffset.dy.abs() > verticalThreshold) {
      final exitY = _dragOffset.dy > 0
          ? screenSize.height * 1.1
          : -screenSize.height * 1.1;
      final exitOffset = Offset(_dragOffset.dx * 0.4, exitY);
      _animateToOffset(
        exitOffset,
        onComplete: () => _recordHistoryAndAdvance(
          profileIndex: currentIdx,
          exitOffset: exitOffset,
          wasLiked: false,
        ),
      );
      return;
    }

    // Snap smoothly back to center
    _animateToOffset(Offset.zero);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final screenSize = MediaQuery.of(context).size;

    // 0.0 (at rest) -> 1.0 (fully swiped) drives smooth rise of background card
    final dragProgress = math.min(
      1.0,
      math.max(
        _dragOffset.dx.abs() / (screenSize.width * 0.42),
        _dragOffset.dy.abs() / (screenSize.height * 0.32),
      ),
    );

    final currentProfile = _profiles[_profileIndex];
    final nextProfile = _profiles[(_profileIndex + 1) % _profiles.length];

    return Scaffold(
      // Prevents any black background flash during transitions
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 48,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.favorite_rounded, color: primary, size: 18),
            ),
            const SizedBox(width: 8),
            const Text(
              'YoUnMe',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 19,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),

      body: Stack(
        fit: StackFit.expand,
        children: [
          // Soft animated ambient backdrop so background is never black or blank
          const _SmoothAnimatedBackground(),

          // Single-screen layout: Live Profiles + Full-Width Card + Action Buttons all visible without scrolling
          SafeArea(
            top: false,
            child: _currentTabIndex == 0
                ? Column(
                    children: [
                      // 1. AVAILABLE LIVE PROFILES (Heading + Audio/Video Call Toggle)
                      LiveProfilesStrip(
                        liveProfiles: _liveProfiles,
                        onStartCall: _startLiveCall,
                      ),

                      // 2. DISCOVERY HEADING + FILTERS BUTTON
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 2, 14, 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Discovery',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: theme.brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black87,
                                letterSpacing: -0.3,
                              ),
                            ),
                            FilledButton.tonalIcon(
                              onPressed: _openDiscoveryFilters,
                              icon: Icon(
                                Icons.tune_rounded,
                                size: 15,
                                color: primary,
                              ),
                              label: Text(
                                'Filters',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: primary,
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: primary.withOpacity(0.12),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                minimumSize: const Size(0, 30),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 3. FULL-WIDTH SEPARATED DISCOVERY CARD DECK (with bottom 5-button dock inside card)
                      Expanded(
                        child: Padding(
                          // Minimal horizontal padding so card spreads wide across screen
                          padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // NEXT PROFILE IN BACKGROUND: Smoothly rises up & scales in while swiping
                              Transform.translate(
                                offset: Offset(0, 18 * (1 - dragProgress)),
                                child: Transform.scale(
                                  scale: 0.93 + (0.07 * dragProgress),
                                  child: Opacity(
                                    opacity: 0.85 + (0.15 * dragProgress),
                                    child: SeparatedProfileCard(
                                      profile: nextProfile,
                                      swipeProgressDx: 0,
                                    ),
                                  ),
                                ),
                              ),

                              // ACTIVE FRONT PROFILE CARD: Smooth sliding, gentle tilt & 3s status photos
                              GestureDetector(
                                onDoubleTap: () =>
                                    _handleSpark(currentProfile, screenSize),
                                onPanStart: _onPanStart,
                                onPanUpdate: _onPanUpdate,
                                onPanEnd: (details) =>
                                    _onPanEnd(details, screenSize),
                                child: Transform.translate(
                                  offset: _dragOffset,
                                  child: Transform.rotate(
                                    angle: (_dragOffset.dx / screenSize.width) *
                                        0.16,
                                    child: SeparatedProfileCard(
                                      profile: currentProfile,
                                      swipeProgressDx: _dragOffset.dx,
                                      activePhotoIndex: _photoIndex,
                                      photoProgress: _photoStatusCtrl,
                                      isFrontCard: true,
                                      onPrevPhoto: () =>
                                          _prevPhoto(currentProfile),
                                      onNextPhoto: () =>
                                          _nextPhoto(currentProfile),
                                      onSelectPhoto: (idx) =>
                                          _selectPhoto(currentProfile, idx),
                                      onOpenProfile: () => _openFullProfile(
                                        currentProfile,
                                        _profileIndex,
                                        screenSize,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // 5-BUTTON ACTION BAR AT PROFILE CARD BOTTOM
                              Positioned(
                                bottom: 10,
                                left: 2,
                                right: 2,
                                child: DiscoveryActionDock(
                                  revertCount: _swipeHistory.length,
                                  onRevert: _handleRevert,
                                  onDislike: () => _handleDislike(screenSize),
                                  onSpark: () =>
                                      _handleSpark(currentProfile, screenSize),
                                  onLike: () => _handleLike(screenSize),
                                  onMessageRequest: () => _openMessageRequest(
                                    currentProfile,
                                    _profileIndex,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Text(
                      ['Discover', 'Matches', 'Chats', 'Profile'][_currentTabIndex],
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
          ),
        ],
      ),

      bottomNavigationBar: NavigationBar(
        height: 62,
        selectedIndex: _currentTabIndex,
        indicatorColor: primary.withOpacity(0.14),
        onDestinationSelected: (idx) => setState(() => _currentTabIndex = idx),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded, color: primary),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_border_rounded),
            selectedIcon: Icon(Icons.favorite_rounded, color: primary),
            label: 'Matches',
          ),
          NavigationDestination(
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble_rounded, color: primary),
            label: 'Chats',
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: primary),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// Smoothly Moving Ambient Background (Prevents black/empty gaps)
class _SmoothAnimatedBackground extends StatefulWidget {
  const _SmoothAnimatedBackground();

  @override
  State<_SmoothAnimatedBackground> createState() =>
      _SmoothAnimatedBackgroundState();
}

class _SmoothAnimatedBackgroundState extends State<_SmoothAnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, _) {
        final t = Curves.easeInOutSine.transform(_bgController.value);
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1.0 + (0.7 * t), -1.0),
              end: Alignment(1.0, 1.0 - (0.7 * t)),
              colors: isDark
                  ? [
                      const Color(0xFF15131E),
                      Color.lerp(
                        const Color(0xFF1F1629),
                        primary.withOpacity(0.18),
                        t,
                      )!,
                      const Color(0xFF111219),
                    ]
                  : [
                      const Color(0xFFFFF5F7),
                      Color.lerp(
                        const Color(0xFFF6F2FF),
                        primary.withOpacity(0.10),
                        t,
                      )!,
                      const Color(0xFFFAFAFC),
                    ],
            ),
          ),
        );
      },
    );
  }
}
