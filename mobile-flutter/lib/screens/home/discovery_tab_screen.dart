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
  String? _selectedRandomCallUserId;

  final List<RandomCallUser> _randomCallUsers = const [
    RandomCallUser(
      id: 'usr_1',
      name: 'Aarav',
      age: 24,
      city: 'Hyderabad',
      status: 'Online',
      avatarIcon: Icons.face_retouching_natural,
      avatarBgColor: Color(0xFFFFE5EC),
      avatarAccentColor: Color(0xFFE94057),
    ),
    RandomCallUser(
      id: 'usr_2',
      name: 'Meera',
      age: 23,
      city: 'Bengaluru',
      status: 'Online',
      avatarIcon: Icons.face_3,
      avatarBgColor: Color(0xFFE8F0FE),
      avatarAccentColor: Color(0xFF3B82F6),
    ),
    RandomCallUser(
      id: 'usr_3',
      name: 'Rohan',
      age: 26,
      city: 'Visakhapatnam',
      status: 'Available',
      avatarIcon: Icons.face_6,
      avatarBgColor: Color(0xFFFEF3C7),
      avatarAccentColor: Color(0xFFD97706),
    ),
    RandomCallUser(
      id: 'usr_4',
      name: 'Ananya',
      age: 22,
      city: 'Chennai',
      status: 'Online',
      avatarIcon: Icons.face_4,
      avatarBgColor: Color(0xFFDCFCE7),
      avatarAccentColor: Color(0xFF16A34A),
    ),
  ];

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

  void _toggleRandomCallSelection(String userId) {
    setState(() {
      _selectedRandomCallUserId =
          (_selectedRandomCallUserId == userId) ? null : userId;
    });
  }

  void _startRandomCall(RandomCallUser user, {required bool isVideo}) {
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

  Widget _buildRandomCallsSection() {
    const primaryColor = Color(0xFFE94057);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Random Calls',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap an avatar to start an audio or video call',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: widget.onNavigateToConnect ?? () {},
                icon: const Icon(Icons.shuffle_rounded,
                    size: 18, color: primaryColor),
                label: const Text(
                  'Connect Tab',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),

        // 2-Column Grid of Avatar-Only Profiles
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _randomCallUsers.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.86,
            ),
            itemBuilder: (context, index) {
              final user = _randomCallUsers[index];
              final isSelected = _selectedRandomCallUserId == user.id;

              return GestureDetector(
                onTap: () => _toggleRandomCallSelection(user.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16161D),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? primaryColor : Colors.white12,
                      width: isSelected ? 1.8 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? primaryColor.withOpacity(0.25)
                            : Colors.black.withOpacity(0.3),
                        blurRadius: isSelected ? 12 : 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Avatar + Status Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: user.avatarBgColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              user.avatarIcon,
                              color: user.avatarAccentColor,
                              size: 26,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: user.status == 'Online'
                                  ? const Color(0xFFDCFCE7).withOpacity(0.2)
                                  : const Color(0xFFFEF3C7).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: user.status == 'Online'
                                        ? const Color(0xFF16A34A)
                                        : const Color(0xFFD97706),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  user.status,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: user.status == 'Online'
                                        ? Colors.greenAccent
                                        : Colors.amberAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Name, Age, City
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${user.name}, ${user.age}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined,
                                  size: 13, color: Colors.grey[400]),
                              const SizedBox(width: 2),
                              Text(
                                user.city,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Action: Pop out Audio & Video buttons when selected, or prompt button
                      if (isSelected)
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () =>
                                    _startRandomCall(user, isVideo: false),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color:
                                        const Color(0xFFE8F0FE).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.call_rounded,
                                      size: 18, color: Color(0xFF60A5FA)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: InkWell(
                                onTap: () =>
                                    _startRandomCall(user, isVideo: true),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color:
                                        const Color(0xFFFFE5EC).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.videocam_rounded,
                                      size: 18, color: primaryColor),
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          decoration: BoxDecoration(
                            color: const Color(0xFF22222C),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.touch_app_rounded,
                                  size: 14, color: Colors.grey[400]),
                              const SizedBox(width: 4),
                              Text(
                                'Tap to Call',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
      ],
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

              // --- RANDOM CALLS SECTION (Replaces Date Planning) ---
              _buildRandomCallsSection(),

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
