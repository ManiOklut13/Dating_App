import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/profiles_data.dart';
import '../../widgets/discovery_action_dock.dart';
import '../../widgets/live_profiles_strip.dart';
import '../../widgets/match_modal.dart';
import '../../widgets/mega_crush_celebration.dart';
import '../../widgets/separated_profile_card.dart';
import '../../widgets/streak_tracker_modal.dart';
import 'daily_streak_screen.dart';
import 'discovery_filters_screen.dart';
import 'full_profile_screen.dart';
import 'message_request_screen.dart';
import 'rubies_screen.dart';
import 'notifications_screen.dart';
import '../calls/live_interactive_call_screen.dart';
import '../../services/app_state_provider.dart';

class DiscoveryTabScreen extends ConsumerStatefulWidget {
  final bool showStreakOnEntry;
  final VoidCallback? onNavigateToConnect;

  const DiscoveryTabScreen({
    super.key,
    this.showStreakOnEntry = false,
    this.onNavigateToConnect,
  });

  @override
  ConsumerState<DiscoveryTabScreen> createState() => _DiscoveryTabScreenState();
}

class _DiscoveryTabScreenState extends ConsumerState<DiscoveryTabScreen>
    with TickerProviderStateMixin {
  bool _hasClaimedStreakBonus = false;
  int _profileIndex = 0;
  int _photoIndex = 0;
  bool _isAnimatingCard = false;
  bool _isWheelScrolling = false;

  Offset _dragOffset = Offset.zero;
  late final PageController _profilePageController;
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

  // Discovery Stack Profiles (shared 24-profile catalog)
  List<Map<String, dynamic>> get _allProfiles => kDiscoveryProfiles;

  List<Map<String, dynamic>> get _profiles {
    if (_activeFilters == null) return _allProfiles;
    final minAge = (_activeFilters!['minAge'] as int?) ?? 18;
    final maxAge = (_activeFilters!['maxAge'] as int?) ?? 60;
    final maxDist = (_activeFilters!['radiusKm'] as int?) ?? 150;
    final verifiedOnly = (_activeFilters!['verifiedOnly'] as bool?) ?? false;

    final filtered = _allProfiles.where((p) {
      final age = p['age'] as int;
      final dist = p['distanceKm'] as int;
      final verified = p['verified'] as bool;
      if (age < minAge || age > maxAge) return false;
      if (dist > maxDist) return false;
      if (verifiedOnly && !verified) return false;
      return true;
    }).toList();

    return filtered.isEmpty ? _allProfiles : filtered;
  }

  @override
  void initState() {
    super.initState();
    _profilePageController = PageController(initialPage: _profileIndex);
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && StreakSessionManager.shouldShowStreakPopup()) {
        _showDailyStreakDialog(context);
      }
    });
  }

  @override
  void dispose() {
    _profilePageController.dispose();
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

  void _showDailyStreakDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final appState = ref.watch(appStateProvider);
          return StreakTrackerModal(
            streakDays: appState.streakDays,
            hasClaimed: _hasClaimedStreakBonus,
            onClaimBonus: () {
              setDialogState(() => _hasClaimedStreakBonus = true);
              setState(() => _hasClaimedStreakBonus = true);
              ref.read(appStateProvider.notifier).addRubies(40);
            },
            onClose: () => Navigator.of(dialogCtx).pop(),
          );
        },
      ),
    );
  }

  void _openStreakModal(BuildContext context) {
    final appState = ref.read(appStateProvider);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StreakPage(currentStreak: appState.streakDays),
      ),
    );
  }

  void _openRubiesScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RubiesScreen()),
    );
  }

  void _openNotificationsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  }

  Future<void> _openDiscoveryFilters() async {
    final updatedFilters = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => DiscoveryFiltersScreen(initialFilters: _activeFilters),
      ),
    );
    if (updatedFilters != null && mounted) {
      setState(() {
        _activeFilters = updatedFilters;
        _profileIndex = 0;
        _dragOffset = Offset.zero;
        _swipeHistory.clear();
        _photoIndex = 0;
      });
      if (_profilePageController.hasClients) {
        _profilePageController.jumpToPage(0);
      }
      _photoStatusCtrl.forward(from: 0.0);
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
      _profileIndex = _profileIndex + 1;
      _dragOffset = Offset.zero;
    });
    if (_profilePageController.hasClients) {
      _profilePageController.jumpToPage(_profileIndex);
    }
    _resetPhotoStatus();

    // 25% chance of triggering mutual match celebration modal on Like
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
    final currentPage = _profileIndex;
    _animateToOffset(
      exitOffset,
      onComplete: () => _recordHistoryAndAdvance(
        profileIndex: currentPage,
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
      _profileIndex = entry.profileIndex;
      _dragOffset = entry.exitOffset;
    });
    if (_profilePageController.hasClients) {
      _profilePageController.jumpToPage(_profileIndex);
    }
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

  void _onProfilePageChanged(int newIndex) {
    if (_isAnimatingCard || _profileIndex == newIndex) return;
    setState(() {
      _profileIndex = newIndex;
      _dragOffset = Offset.zero;
    });
    _resetPhotoStatus();
  }

  void _handleReelsPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    GestureBinding.instance.pointerSignalResolver.register(event, (e) {
      if (_isWheelScrolling || !mounted || !_profilePageController.hasClients) {
        return;
      }
      final dy = (e as PointerScrollEvent).scrollDelta.dy;
      if (dy.abs() < 6) return;
      final targetPage = dy > 0 ? _profileIndex + 1 : _profileIndex - 1;
      if (targetPage < 0) return;

      _isWheelScrolling = true;
      _profilePageController
          .animateToPage(
            targetPage,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          )
          .whenComplete(() {
        if (mounted) _isWheelScrolling = false;
      });
    });
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    _swipeAnimController.stop();
    _isAnimatingCard = false;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset = Offset(_dragOffset.dx + details.delta.dx, 0);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details, Size screenSize) {
    final horizontalThreshold = screenSize.width * 0.25;
    final currentPage = _profileIndex;

    // Horizontal Left / Right Swipe -> Smooth slide out
    if (_dragOffset.dx.abs() > horizontalThreshold) {
      final liked = _dragOffset.dx > 0;
      final exitX = liked ? screenSize.width * 1.3 : -screenSize.width * 1.3;
      final exitOffset = Offset(exitX, 0);
      _animateToOffset(
        exitOffset,
        onComplete: () => _recordHistoryAndAdvance(
          profileIndex: currentPage,
          exitOffset: exitOffset,
          wasLiked: liked,
        ),
      );
      return;
    }

    // Snap smoothly back to center
    _animateToOffset(Offset.zero);
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appStateProvider);
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final screenSize = MediaQuery.of(context).size;

    final profiles = _profiles;
    final safeIdx = _profileIndex % profiles.length;
    final currentProfile = profiles[safeIdx];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 50,
        title: GestureDetector(
          onTap: () => ref.read(appStateProvider.notifier).setAuthenticated(false),
          child: Row(
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
        actions: [
          // Rubies mini pill
          GestureDetector(
            onTap: _openRubiesScreen,
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.diamond_rounded, size: 14, color: primary),
                  const SizedBox(width: 4),
                  Text(
                    '${appState.rubyBalance}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Streak mini pill
          GestureDetector(
            onTap: () => _openStreakModal(context),
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department_rounded,
                      size: 14, color: Colors.orange),
                  const SizedBox(width: 3),
                  Text(
                    '${appState.streakDays}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Notifications
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.notifications_none_rounded, size: 20),
              onPressed: _openNotificationsScreen,
            ),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Soft animated ambient backdrop so background is never black or blank
          const _SmoothAnimatedBackground(),

          // Single-screen layout: Live Profiles + Discovery Heading + Card + 5-Button Dock
          SafeArea(
            top: false,
            child: Column(
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
                        icon: Icon(Icons.tune_rounded, size: 15, color: primary),
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

                // 3. VERTICAL REELS-SCROLLABLE DISCOVERY PROFILE CARDS (with next card rising behind)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // BACKGROUND NEXT PROFILE: Slowly rises, scales in, and fades up as top card moves
                        if (profiles.length > 1)
                          AnimatedBuilder(
                            animation: _profilePageController,
                            builder: (context, _) {
                              final double page =
                                  _profilePageController.hasClients
                                      ? (_profilePageController.page ??
                                          _profileIndex.toDouble())
                                      : _profileIndex.toDouble();
                              final int basePage =
                                  page.floor() < 0 ? 0 : page.floor();
                              final double scrollFraction =
                                  (page - basePage).clamp(0.0, 1.0);
                              final double swipeFraction =
                                  (_dragOffset.dx.abs() /
                                          (screenSize.width * 0.42))
                                      .clamp(0.0, 1.0);
                              final double progress =
                                  scrollFraction > swipeFraction
                                      ? scrollFraction
                                      : swipeFraction;

                              final bgProfile =
                                  profiles[(basePage + 1) % profiles.length];
                              return Transform.translate(
                                offset: Offset(0, 18 * (1 - progress)),
                                child: Transform.scale(
                                  scale: 0.93 + (0.07 * progress),
                                  child: Opacity(
                                    opacity: 0.85 + (0.15 * progress),
                                    child: SeparatedProfileCard(
                                      profile: bgProfile,
                                      swipeProgressDx: 0,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                        // FOREGROUND REELS-SCROLLABLE + HORIZONTALLY SWIPEABLE PROFILE DECK
                        ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(
                            dragDevices: {
                              PointerDeviceKind.touch,
                              PointerDeviceKind.mouse,
                              PointerDeviceKind.trackpad,
                              PointerDeviceKind.stylus,
                            },
                          ),
                          child: PageView.builder(
                            controller: _profilePageController,
                            scrollDirection: Axis.vertical,
                            physics: const ReelsSnapScrollPhysics(
                              parent: ClampingScrollPhysics(
                                parent: AlwaysScrollableScrollPhysics(),
                              ),
                            ),
                            onPageChanged: _onProfilePageChanged,
                            itemBuilder: (context, idx) {
                              return Listener(
                                behavior: HitTestBehavior.translucent,
                                onPointerSignal: _handleReelsPointerSignal,
                                child: AnimatedBuilder(
                                  animation: _profilePageController,
                                  builder: (context, _) {
                                    final double page =
                                        _profilePageController.hasClients
                                            ? (_profilePageController.page ??
                                                _profileIndex.toDouble())
                                            : _profileIndex.toDouble();
                                    final int basePage =
                                        page.floor() < 0 ? 0 : page.floor();

                                    if (idx != basePage) {
                                      return const SizedBox.expand();
                                    }

                                    final profileIdx = idx % profiles.length;
                                    final profile = profiles[profileIdx];
                                    final isCurrent = idx == _profileIndex;

                                    return GestureDetector(
                                      onDoubleTap: isCurrent
                                          ? () =>
                                              _handleSpark(profile, screenSize)
                                          : null,
                                      onHorizontalDragStart: isCurrent
                                          ? _onHorizontalDragStart
                                          : null,
                                      onHorizontalDragUpdate: isCurrent
                                          ? _onHorizontalDragUpdate
                                          : null,
                                      onHorizontalDragEnd: isCurrent
                                          ? (details) => _onHorizontalDragEnd(
                                              details, screenSize)
                                          : null,
                                      child: Transform.translate(
                                        offset: isCurrent
                                            ? _dragOffset
                                            : Offset.zero,
                                        child: Transform.rotate(
                                          angle: isCurrent
                                              ? (_dragOffset.dx /
                                                      screenSize.width) *
                                                  0.16
                                              : 0.0,
                                          child: SeparatedProfileCard(
                                            profile: profile,
                                            swipeProgressDx:
                                                isCurrent ? _dragOffset.dx : 0.0,
                                            activePhotoIndex:
                                                isCurrent ? _photoIndex : 0,
                                            photoProgress: isCurrent
                                                ? _photoStatusCtrl
                                                : null,
                                            isFrontCard: true,
                                            onPrevPhoto: isCurrent
                                                ? () => _prevPhoto(profile)
                                                : null,
                                            onNextPhoto: isCurrent
                                                ? () => _nextPhoto(profile)
                                                : null,
                                            onSelectPhoto: isCurrent
                                                ? (pIdx) =>
                                                    _selectPhoto(profile, pIdx)
                                                : null,
                                            onOpenProfile: () =>
                                                _openFullProfile(
                                              profile,
                                              profileIdx,
                                              screenSize,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
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
                            onMessageRequest: () =>
                                _openMessageRequest(currentProfile, safeIdx),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
