import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/top_nav_bar.dart';
import '../../widgets/discovery_deck.dart';
import '../../widgets/streak_tracker_modal.dart';
import 'daily_streak_screen.dart';
import 'home_screen.dart';
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

class _DiscoveryTabScreenState extends ConsumerState<DiscoveryTabScreen> {
  bool _hasClaimedStreakBonus = false;
  String? _selectedLiveUserId;

  final List<LiveProfileUser> _liveProfiles = const [
    LiveProfileUser(
      id: 'live_1',
      name: 'Ananya',
      age: 24,
      city: 'Hyderabad',
      avatarIcon: Icons.face_4_rounded,
      avatarBgColor: Color(0xFFFFE5EC),
      avatarAccentColor: Color(0xFFE94057),
    ),
    LiveProfileUser(
      id: 'live_2',
      name: 'Meera',
      age: 23,
      city: 'Bengaluru',
      avatarIcon: Icons.face_3_rounded,
      avatarBgColor: Color(0xFFE8F0FE),
      avatarAccentColor: Color(0xFF3B82F6),
    ),
    LiveProfileUser(
      id: 'live_3',
      name: 'Kavya',
      age: 25,
      city: 'Secunderabad',
      avatarIcon: Icons.face_retouching_natural,
      avatarBgColor: Color(0xFFFEF3C7),
      avatarAccentColor: Color(0xFFD97706),
    ),
    LiveProfileUser(
      id: 'live_4',
      name: 'Riya',
      age: 22,
      city: 'Chennai',
      avatarIcon: Icons.face_2_rounded,
      avatarBgColor: Color(0xFFDCFCE7),
      avatarAccentColor: Color(0xFF16A34A),
    ),
    LiveProfileUser(
      id: 'live_5',
      name: 'Sneha',
      age: 24,
      city: 'Pune',
      avatarIcon: Icons.face_rounded,
      avatarBgColor: Color(0xFFF3E8FF),
      avatarAccentColor: Color(0xFF9333EA),
    ),
  ];

  void _onTapLiveProfile(String userId) {
    setState(() {
      _selectedLiveUserId = (_selectedLiveUserId == userId) ? null : userId;
    });
  }

  void _startLiveCall(LiveProfileUser user, {required bool isVideo}) {
    final callType = isVideo ? 'Video Call' : 'Audio Call';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting $callType with ${user.name}...'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LiveInteractiveCallScreen(
          userName: user.name,
          avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb',
          isVideo: isVideo,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && StreakSessionManager.shouldShowStreakPopup()) {
        _showStreakDialog(); // Your existing streak pop-up method
      }
    });
  }

  void _showStreakDialog() {
    _showDailyStreakDialog(context);
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
              setDialogState(() {
                _hasClaimedStreakBonus = true;
              });
              setState(() {
                _hasClaimedStreakBonus = true;
              });
              ref.read(appStateProvider.notifier).addRubies(40);
            },
            onClose: () {
              Navigator.of(dialogCtx).pop();
            },
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

  Widget _buildAvailableLiveProfilesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: Colors.greenAccent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Available Live Profiles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Text(
                'Tap avatar to call',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 104,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _liveProfiles.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final user = _liveProfiles[index];
              final isSelected = _selectedLiveUserId == user.id;

              return GestureDetector(
                onTap: () => _onTapLiveProfile(user.id),
                child: SizedBox(
                  width: 68,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(2.5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFE94057)
                                    : Colors.greenAccent,
                                width: isSelected ? 2.5 : 2.0,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFFE94057).withOpacity(0.35),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      )
                                    ]
                                  : null,
                            ),
                            child: Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: user.avatarBgColor,
                              ),
                              child: Icon(
                                user.avatarIcon,
                                color: user.avatarAccentColor,
                                size: 28,
                              ),
                            ),
                          ),
                          if (!isSelected)
                            Positioned(
                              bottom: 1,
                              right: 1,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF0D070C),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (isSelected)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () => _startLiveCall(user, isVideo: false),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(4.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2563EB).withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF3B82F6),
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.call_rounded,
                                  size: 13,
                                  color: Color(0xFF60A5FA),
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            InkWell(
                              onTap: () => _startLiveCall(user, isVideo: true),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(4.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE94057).withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFE94057),
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.videocam_rounded,
                                  size: 13,
                                  color: Color(0xFFE94057),
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          user.name,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appStateProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D070C),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Persistent App Bar
              TopNavBar(
                rubyBalance: appState.rubyBalance,
                streakDays: appState.streakDays,
                onOpenRubies: _openRubiesScreen,
                onOpenStreak: () => _openStreakModal(context),
                onOpenNotifications: _openNotificationsScreen,
                onLogoTap: () {
                  ref.read(appStateProvider.notifier).setAuthenticated(false);
                },
              ),

              // --- AVAILABLE LIVE PROFILES SECTION ---
              _buildAvailableLiveProfilesSection(),

              // Discovery Header: "Discovery" on left, "Swipe & Connect" on right
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Discovery',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Swipe & Connect',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),

              // Discovery Swipe Deck
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SizedBox(
                  height: 610,
                  child: DiscoveryDeck(
                    onOpenStore: _openRubiesScreen,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
