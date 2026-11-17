import 'package:flutter/material.dart';
import '../../data/profiles_data.dart';
import '../../models/discovery_connect_models.dart';
import '../calls/live_interactive_call_screen.dart';

class ConnectTabScreen extends StatefulWidget {
  const ConnectTabScreen({super.key});

  @override
  State<ConnectTabScreen> createState() => _ConnectTabScreenState();
}

class _ConnectTabScreenState extends State<ConnectTabScreen> {
  int _subTabIndex = 0; // 0: Random call, 1: Likes, 2: Matches
  String _activeFilter = 'Recommended';
  String? _expandedFloatingAvatarId;

  final List<String> _filters = ['Recommended', 'Nearby', '• Online', 'Interests'];

  final List<SparkCrushItem> _sparks = kSparkCrushList;

  void _startCall(String name, String avatar, bool isVideo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LiveInteractiveCallScreen(
          userName: name,
          avatarUrl: avatar,
          isVideo: isVideo,
        ),
      ),
    );
  }

  void _openPickPromptModal(String partnerName) {
    final prompts = [
      'Subko coffee or cozy midnight drives?',
      'If you could teleport right now, where in Mumbai would we go?',
      'What is your go-to song when you need instant good vibes?',
      'Tell me the best dish you can make in 15 minutes!',
      'Are you more of an acoustic sunset person or a neon rooftop person?',
      'What is the most spontaneous thing you did this year?',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFF1B1119),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: Color(0xFF2E1E2B))),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pick Prompt for $partnerName',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF9CA3AF), size: 18),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...prompts.map((prompt) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF241822),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF2E1E2B)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          prompt,
                          style: const TextStyle(fontSize: 12, color: Colors.white, height: 1.3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Prompt sent to $partnerName! 🚀'),
                              backgroundColor: const Color(0xFFEC4899),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE11D48), Color(0xFFEC4899)],
                            ),
                          ),
                          child: const Text(
                            'Send ▷',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D070C),
      body: SafeArea(
        child: Column(
          children: [
            // Top segmented pill switcher: Random call | Likes | Matches
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1119),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2E1E2B)),
                ),
                child: Row(
                  children: [
                    _segmentedButton('Random call', 0),
                    _segmentedButton('Likes', 1),
                    _segmentedButton('Matches', 2),
                  ],
                ),
              ),
            ),

            // Main body for each sub-tab
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: _buildSubTabContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _segmentedButton(String label, int index) {
    final active = _subTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _subTabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: active
                ? const LinearGradient(
                    colors: [Color(0xFFE11D48), Color(0xFFEC4899)],
                  )
                : null,
            color: active ? null : Colors.transparent,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: active ? FontWeight.w800 : FontWeight.w600,
              color: active ? Colors.white : const Color(0xFF9CA3AF),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubTabContent() {
    switch (_subTabIndex) {
      case 0:
        return _buildRandomCallSubTab();
      case 1:
        return _buildLikesSubTab();
      case 2:
      default:
        return _buildMatchesSubTab();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SUB-TAB 1: RANDOM CALL
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildRandomCallSubTab() {
    final floatingAvatars = [
      const RandomCallAvatarProfile(
        id: 'f_1',
        name: 'Kavya',
        sticker: '🦊',
        language: 'Telugu',
        avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=800&q=80',
        ringColor: Color(0xFF38BDF8),
      ),
      const RandomCallAvatarProfile(
        id: 'f_2',
        name: 'Aanya',
        sticker: '🐰',
        language: 'Hindi',
        avatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=800&q=80',
        ringColor: Color(0xFFEC4899),
      ),
      const RandomCallAvatarProfile(
        id: 'f_3',
        name: 'Rohan',
        sticker: '🐼',
        language: 'English',
        avatar: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=800&q=80',
        ringColor: Color(0xFF22C55E),
      ),
      const RandomCallAvatarProfile(
        id: 'f_4',
        name: 'Sneha',
        sticker: '🐱',
        language: 'Tamil',
        avatar: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=800&q=80',
        ringColor: Color(0xFFA855F7),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Horizontal filter pills + filter icon
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ..._filters.map((f) {
                final active = _activeFilter == f;
                return GestureDetector(
                  onTap: () => setState(() => _activeFilter = f),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: active ? const Color(0xFFEC4899) : const Color(0xFF1B1119),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: active ? const Color(0xFFEC4899) : const Color(0xFF2E1E2B),
                      ),
                    ),
                    child: Text(
                      f,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                        color: active ? Colors.white : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                );
              }),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1119),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF2E1E2B)),
                ),
                child: const Icon(Icons.tune, size: 16, color: Color(0xFF9CA3AF)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Quick-connect CTA buttons side-by-side: "📞 Join Audio Call" and "📹 Join Video Call"
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _startCall('Meera', 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=800&q=80', false),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                    ),
                    boxShadow: const [
                      BoxShadow(color: Color(0x3322C55E), blurRadius: 12, offset: Offset(0, 3)),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.call, size: 18, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Join Audio Call', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => _startCall('Ananya', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=800&q=80', true),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE11D48), Color(0xFFEC4899)],
                    ),
                    boxShadow: const [
                      BoxShadow(color: Color(0x33EC4899), blurRadius: 12, offset: Offset(0, 3)),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.videocam, size: 18, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Join Video Call', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Floating Connections [Live] Card (Tap bubble to connect)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1B1119),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF2E1E2B)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Text(
                        'Floating Connections',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '[Live]',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF22C55E)),
                      ),
                    ],
                  ),
                  const Text('Tap bubble to connect', style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                ],
              ),
              const SizedBox(height: 16),

              // 4 animal avatar bubbles with inline expandable Audio/Video call buttons on tap
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: floatingAvatars.map((p) {
                  final isExpanded = _expandedFloatingAvatarId == p.id;
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _expandedFloatingAvatarId = isExpanded ? null : p.id;
                          });
                        },
                        child: Stack(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isExpanded ? const Color(0xFFEC4899) : p.ringColor,
                                  width: isExpanded ? 2.5 : 2,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: SafeProfileImage(imageUrl: p.avatar, width: 60, height: 60),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              left: 0,
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: const BoxDecoration(color: Color(0xCC000000), shape: BoxShape.circle),
                                alignment: Alignment.center,
                                child: Text(p.sticker, style: const TextStyle(fontSize: 10)),
                              ),
                            ),
                            const Positioned(
                              bottom: 2,
                              right: 2,
                              child: CircleAvatar(radius: 5, backgroundColor: Color(0xFF22C55E)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(p.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                      Text(p.language, style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
                      if (isExpanded) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () => _startCall(p.name, p.avatar, false),
                              child: Container(
                                width: 26,
                                height: 26,
                                margin: const EdgeInsets.only(right: 4),
                                decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle),
                                child: const Icon(Icons.call, size: 14, color: Colors.white),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _startCall(p.name, p.avatar, true),
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: const BoxDecoration(color: Color(0xFF38BDF8), shape: BoxShape.circle),
                                child: const Icon(Icons.videocam, size: 14, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SUB-TAB 2: LIKES
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildLikesSubTab() {
    final history = generate50LikesHistory();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 🔥 Sparks & Mega Crushes (5) (Priority Matches pink label)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '🔥 Sparks & Mega Crushes (5)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0x33EC4899),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text('Priority Matches', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFEC4899))),
            ),
          ],
        ),
        const SizedBox(height: 10),

        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _sparks.length,
            itemBuilder: (context, i) {
              final s = _sparks[i];
              return Container(
                width: 105,
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1119),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2E1E2B)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage(s.avatar),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${s.name}, ${s.age}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      s.type == 'mega_crush' ? 'Mega Crush' : 'Spark Sent',
                      style: const TextStyle(fontSize: 9.5, color: Color(0xFFEC4899), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 18),

        // Weekly Activity & Insights (Live Analytics) - 4-column stat box
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1B1119),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF2E1E2B)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.analytics_outlined, color: Color(0xFF38BDF8), size: 16),
                  SizedBox(width: 6),
                  Text('Weekly Activity & Insights', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
                  Spacer(),
                  Text('Live Analytics', style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _statItem('24', 'Likes Sent', '+18%'),
                  _statItem('6', 'Sparks', '+25%'),
                  _statItem('3', 'Mega Crushes', '100%'),
                  _statItem('8', 'Matches/Wk', '92% rate'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 10 People Liked You (10 Views Daily, green badge Free Tier v1: Full View Active)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('10 People Liked You', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0x2622C55E),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0x8022C55E)),
              ),
              child: const Text('Free Tier v1: Full View Active', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF22C55E))),
            ),
          ],
        ),
        const SizedBox(height: 10),

        SizedBox(
          height: 65,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 10,
            itemBuilder: (context, i) {
              final p = kDemoProfiles[i % kDemoProfiles.length];
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: CircleAvatar(
                  radius: 26,
                  backgroundImage: NetworkImage(p.photoUrls.first),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 18),

        // Likes History (50) (Max 50 recent)
        const Text('Likes History (50)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 8),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 8, // sample top 8 for smooth view
          itemBuilder: (ctx, i) {
            final h = history[i];
            Color badgeColor;
            switch (h.type) {
              case 'mega_crush':
                badgeColor = const Color(0xFFEC4899);
                break;
              case 'spark':
                badgeColor = const Color(0xFFF59E0B);
                break;
              case 'passed':
                badgeColor = const Color(0xFF6B7280);
                break;
              default:
                badgeColor = const Color(0xFF22C55E);
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1B1119),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF2E1E2B)),
              ),
              child: Row(
                children: [
                  CircleAvatar(radius: 20, backgroundImage: NetworkImage(h.avatar)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${h.name}, ${h.age}', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white)),
                        Text('${h.city} • ${h.timestamp}', style: const TextStyle(fontSize: 10.5, color: Color(0xFF9CA3AF))),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      h.type.toUpperCase(),
                      style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: badgeColor),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _statItem(String val, String label, String trend) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
        const SizedBox(height: 2),
        Text(trend, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF22C55E))),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SUB-TAB 3: MATCHES
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildMatchesSubTab() {
    final matches = generate50Matches();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 🏆 Weekly Vibe Scoreboard (Top 3 Vibed)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '🏆 Weekly Vibe Scoreboard',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0x26F59E0B),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text('Top 3 Vibed', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFF59E0B))),
            ),
          ],
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            _podiumCard('#1 Ananya', '98% Vibe', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=800&q=80', isGold: true),
            const SizedBox(width: 8),
            _podiumCard('#2 Kavya', '97% Vibe', 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=800&q=80'),
            const SizedBox(width: 8),
            _podiumCard('#3 Meera', '96% Vibe', 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=800&q=80'),
          ],
        ),
        const SizedBox(height: 18),

        // Make First Move (Break the ice)
        const Text('Make First Move', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(child: _makeFirstMoveCard('Ananya', '99% Match', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=800&q=80')),
            const SizedBox(width: 10),
            Expanded(child: _makeFirstMoveCard('Kavya', '98% Match', 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=800&q=80')),
          ],
        ),
        const SizedBox(height: 18),

        // Matches History (50) (Max 50 recent)
        const Text('Matches History (50)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 10),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 6,
          itemBuilder: (ctx, i) {
            final m = matches[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1B1119),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF2E1E2B)),
              ),
              child: Row(
                children: [
                  CircleAvatar(radius: 20, backgroundImage: NetworkImage(m.avatar)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${m.name}, ${m.age} • ${m.matchPercentage}%', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white)),
                        Text('${m.city} • ${m.lastActive}', style: const TextStyle(fontSize: 10.5, color: Color(0xFF9CA3AF))),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.call, color: Color(0xFF22C55E), size: 18),
                    onPressed: () => _startCall(m.name, m.avatar, false),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFFEC4899), size: 18),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Opening chat with ${m.name}...')),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),

        // Potential Matches (10) (Tap for preview)
        const Text('Potential Matches (10)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 10),

        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 10,
            itemBuilder: (ctx, i) {
              final m = matches[i];
              return GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Previewing ${m.name}\'s profile card ✨')),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: CircleAvatar(
                    radius: 26,
                    backgroundImage: NetworkImage(m.avatar),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),

        // Matched Recently Metrics
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1B1119),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF2E1E2B)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bolt, color: Color(0xFFF59E0B), size: 16),
              SizedBox(width: 6),
              Text(
                '18.4% swipe-to-match • 94% avg compatibility',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _podiumCard(String rankAndName, String vibeScore, String avatar, {bool isGold = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1119),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isGold ? const Color(0xFFF59E0B) : const Color(0xFF2E1E2B),
            width: isGold ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            CircleAvatar(radius: 24, backgroundImage: NetworkImage(avatar)),
            const SizedBox(height: 6),
            Text(
              rankAndName,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              vibeScore,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isGold ? const Color(0xFFF59E0B) : const Color(0xFFEC4899)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _makeFirstMoveCard(String name, String matchPercent, String avatar) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1119),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2E1E2B)),
      ),
      child: Column(
        children: [
          CircleAvatar(radius: 26, backgroundImage: NetworkImage(avatar)),
          const SizedBox(height: 6),
          Text(name, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white)),
          Text(matchPercent, style: const TextStyle(fontSize: 10.5, color: Color(0xFF22C55E), fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Chat opened with $name')),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF241822),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF2E1E2B)),
                    ),
                    alignment: Alignment.center,
                    child: const Text('Chat', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: GestureDetector(
                  onTap: () => _openPickPromptModal(name),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFE11D48), Color(0xFFEC4899)]),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: const Text('💡 Prompt', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
