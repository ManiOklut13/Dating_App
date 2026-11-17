import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/top_nav_bar.dart';
import '../../widgets/date_reminder_card.dart';
import '../../widgets/discovery_deck.dart';
import '../../widgets/streak_tracker_modal.dart';
import 'date_plan_details_screen.dart';
import 'rubies_screen.dart';
import 'notifications_screen.dart';
import '../calls/live_interactive_call_screen.dart';
import '../../data/profiles_data.dart';
import '../../models/discovery_connect_models.dart';
import '../../services/app_state_provider.dart';

class DiscoveryTabScreen extends ConsumerStatefulWidget {
  const DiscoveryTabScreen({super.key});

  @override
  ConsumerState<DiscoveryTabScreen> createState() => _DiscoveryTabScreenState();
}

class _DiscoveryTabScreenState extends ConsumerState<DiscoveryTabScreen> {
  String? _expandedAvatarId;
  bool _hasClaimedStreakBonus = false;

  void _openStreakModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Consumer(
        builder: (context, ref, _) {
          final appState = ref.watch(appStateProvider);
          return StreakTrackerModal(
            streakDays: appState.streakDays,
            hasClaimed: _hasClaimedStreakBonus,
            onClaimBonus: () {
              setState(() => _hasClaimedStreakBonus = true);
              ref.read(appStateProvider.notifier).addRubies(40);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✓ +40 Rubies Credited! 🔥'),
                  backgroundColor: Color(0xFF22C55E),
                ),
              );
            },
            onClose: () => Navigator.pop(ctx),
          );
        },
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

  void _startCall(RandomCallAvatarProfile profile, bool isVideo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LiveInteractiveCallScreen(
          userName: profile.name,
          avatarUrl: profile.avatar,
          isVideo: isVideo,
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
              ),

              // Date Reminder Banner (Top of Home)
              DateReminderCard(
                scheduledDate: demoScheduledDate,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DatePlanDetailsScreen()),
                  );
                },
              ),

              const SizedBox(height: 8),

              // Random Call Strip Header: "Random Call" + green "Live" pill on left; "Tap bubble to connect" on right
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Random Call',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0x2622C55E),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: const Color(0x8022C55E)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(radius: 3, backgroundColor: Color(0xFF22C55E)),
                              SizedBox(width: 4),
                              Text(
                                'Live',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF22C55E),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'Tap bubble to connect',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Random Call Strip (Horizontal Scrollable Row with Inline Expand)
              SizedBox(
                height: 125,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: randomCallAvatarProfiles.length,
                  itemBuilder: (context, index) {
                    final p = randomCallAvatarProfiles[index];
                    final isExpanded = _expandedAvatarId == p.id;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _expandedAvatarId = isExpanded ? null : p.id;
                              });
                            },
                            child: Stack(
                              children: [
                                Container(
                                  width: 58,
                                  height: 58,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isExpanded ? const Color(0xFFEC4899) : p.ringColor,
                                      width: isExpanded ? 2.5 : 2,
                                    ),
                                    boxShadow: isExpanded
                                        ? [
                                            BoxShadow(
                                              color: const Color(0x66EC4899),
                                              blurRadius: 12,
                                              spreadRadius: 2,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(29),
                                    child: SafeProfileImage(imageUrl: p.avatar, width: 58, height: 58),
                                  ),
                                ),
                                // Online green dot
                                Positioned(
                                  right: 2,
                                  bottom: 2,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF22C55E),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFF0D070C), width: 2),
                                    ),
                                  ),
                                ),
                                // Animal sticker emoji badge
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: const BoxDecoration(
                                      color: Color(0xCC000000),
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(p.sticker, style: const TextStyle(fontSize: 10)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            p.name,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            p.language,
                            style: const TextStyle(
                              fontSize: 9.5,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                          const SizedBox(height: 2),

                          // Inline expandable Audio Call and Video Call buttons
                          if (isExpanded)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () => _startCall(p, false),
                                  child: Container(
                                    width: 26,
                                    height: 26,
                                    margin: const EdgeInsets.only(right: 4),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF22C55E),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.call, size: 14, color: Colors.white),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _startCall(p, true),
                                  child: Container(
                                    width: 26,
                                    height: 26,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF38BDF8),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.videocam, size: 14, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    );
                  },
                ),
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
