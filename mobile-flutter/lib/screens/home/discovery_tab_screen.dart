import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/top_nav_bar.dart';
import '../../widgets/discovery_deck.dart';
import '../../widgets/streak_tracker_modal.dart';
import 'daily_streak_screen.dart';
import 'date_plan_details_screen.dart';
import 'rubies_screen.dart';
import 'notifications_screen.dart';
import '../calls/live_interactive_call_screen.dart';
import '../../data/profiles_data.dart';
import '../../services/app_state_provider.dart';

class DiscoveryTabScreen extends ConsumerStatefulWidget {
  final bool showStreakOnEntry;

  const DiscoveryTabScreen({super.key, this.showStreakOnEntry = false});

  @override
  ConsumerState<DiscoveryTabScreen> createState() => _DiscoveryTabScreenState();
}

class _DiscoveryTabScreenState extends ConsumerState<DiscoveryTabScreen> {
  bool _hasClaimedStreakBonus = false;

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

  void _startCall(String userName, String avatarUrl, bool isVideo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LiveInteractiveCallScreen(
          userName: userName,
          avatarUrl: avatarUrl,
          isVideo: isVideo,
        ),
      ),
    );
  }

  Widget _buildScheduledDateCard({
    required String partnerName,
    required int partnerAge,
    required String avatarUrl,
    required String dateTimeText,
    required String venueName,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E24),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.pinkAccent.withOpacity(0.35)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundImage: NetworkImage(avatarUrl),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date with $partnerName, $partnerAge',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$dateTimeText • $venueName',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.pinkAccent,
            ),
          ],
        ),
      ),
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

              // Date Reminder Banner (Top of Home)
              _buildScheduledDateCard(
                partnerName: 'Ananya',
                partnerAge: 24,
                avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330',
                dateTimeText: 'Tonight, 7:30 PM',
                venueName: 'Roastery Coffee House',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DatePlanDetailsScreen()),
                  );
                },
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Icon(Icons.circle, color: Colors.greenAccent, size: 10),
                        SizedBox(width: 8),
                        Text(
                          'Available Live Profiles',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 110,
                    // Clean container without the CustomPaint sinusoidal wave background
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: liveProfiles.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final user = liveProfiles[index];
                        return GestureDetector(
                          onTap: () {
                            // Trigger random call or open profile
                            _startCall(user['name'] as String, user['avatar'] as String, true);
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(2.5),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.greenAccent, width: 2),
                                    ),
                                    child: CircleAvatar(
                                      radius: 28,
                                      backgroundImage: NetworkImage(user['avatar'] as String),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 2,
                                    right: 2,
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: Colors.greenAccent,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: const Color(0xFF121212), width: 2),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                user['name'] as String,
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

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
