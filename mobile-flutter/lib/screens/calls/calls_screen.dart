import 'package:flutter/material.dart';
import '../../models/call_user.dart';
import '../../services/call_history_service.dart';
import 'audio_call_screen.dart';
import 'video_call_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Main Calls Screen — three tabs: Audio · Video · History
// ─────────────────────────────────────────────────────────────────────────────
class CallsScreen extends StatefulWidget {
  const CallsScreen({super.key});

  @override
  State<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Tab bar ────────────────────────────────────────────────────────
        Container(
          color: const Color(0xFF0F121D),
          child: TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFFFF2D55),
            indicatorWeight: 3,
            labelColor: const Color(0xFFFF2D55),
            unselectedLabelColor: Colors.white38,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              letterSpacing: 0.3,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            tabs: const [
              Tab(
                icon: Icon(Icons.phone_outlined, size: 20),
                text: 'Audio',
              ),
              Tab(
                icon: Icon(Icons.videocam_outlined, size: 20),
                text: 'Video',
              ),
              Tab(
                icon: Icon(Icons.history, size: 20),
                text: 'History',
              ),
            ],
          ),
        ),

        // ── Tab views ──────────────────────────────────────────────────────
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              _AudioTab(),
              _VideoTab(),
              _HistoryTab(),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared contact-list tile
// ─────────────────────────────────────────────────────────────────────────────
class _ContactTile extends StatelessWidget {
  final CallUser user;
  final VoidCallback onAudioCall;
  final VoidCallback onVideoCall;
  final bool showBothButtons;
  final bool isForVideo;

  const _ContactTile({
    required this.user,
    required this.onAudioCall,
    required this.onVideoCall,
    this.showBothButtons = false,
    this.isForVideo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF111318),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          // Avatar
          _AvatarWidget(user: user, size: 52),
          const SizedBox(width: 14),

          // Name + city
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (user.isVerified) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.verified,
                          color: Color(0xFF3B82F6), size: 16),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  user.city,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          ),

          // Call buttons
          if (showBothButtons) ...[
            _CallIconBtn(
              icon: Icons.phone,
              color: const Color(0xFF00E676),
              tooltip: 'Audio call',
              onTap: onAudioCall,
            ),
            const SizedBox(width: 8),
            _CallIconBtn(
              icon: Icons.videocam,
              color: const Color(0xFF00E5FF),
              tooltip: 'Video call',
              onTap: onVideoCall,
            ),
          ] else if (isForVideo) ...[
            _CallIconBtn(
              icon: Icons.videocam,
              color: const Color(0xFF00E5FF),
              tooltip: 'Video call demo',
              onTap: onVideoCall,
            ),
          ] else ...[
            _CallIconBtn(
              icon: Icons.phone,
              color: const Color(0xFF00E676),
              tooltip: 'Audio call demo',
              onTap: onAudioCall,
            ),
          ],
        ],
      ),
    );
  }
}

class _CallIconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _CallIconBtn({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.12),
            border: Border.all(color: color.withOpacity(0.35)),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Audio Tab
// ─────────────────────────────────────────────────────────────────────────────
class _AudioTab extends StatelessWidget {
  const _AudioTab();

  void _startAudioCall(BuildContext context, CallUser user) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AudioCallScreen(user: user),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      children: [
        _SectionHeader(
          icon: Icons.phone_in_talk,
          label: 'Audio Calls',
          subtitle: 'Tap a contact to start a voice call demo',
        ),
        ...kDemoUsers.map(
          (u) => _ContactTile(
            user: u,
            showBothButtons: false,
            onAudioCall: () => _startAudioCall(context, u),
            onVideoCall: () {},
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Video Tab
// ─────────────────────────────────────────────────────────────────────────────
class _VideoTab extends StatelessWidget {
  const _VideoTab();

  void _startVideoCall(BuildContext context, CallUser user) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VideoCallScreen(user: user),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      children: [
        _SectionHeader(
          icon: Icons.videocam,
          label: 'Video Calls',
          subtitle: 'Tap the video button to start a video call demo',
        ),
        ...kDemoUsers.map(
          (u) => _ContactTile(
            user: u,
            showBothButtons: false,
            isForVideo: true,
            onAudioCall: () {},
            onVideoCall: () => _startVideoCall(context, u),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// History Tab
// ─────────────────────────────────────────────────────────────────────────────
class _HistoryTab extends StatefulWidget {
  const _HistoryTab();

  @override
  State<_HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<_HistoryTab> {
  @override
  void initState() {
    super.initState();
    // Listen for new entries added by call screens
    CallHistoryService.instance.addListener(_onHistoryChanged);
  }

  @override
  void dispose() {
    CallHistoryService.instance.removeListener(_onHistoryChanged);
    super.dispose();
  }

  void _onHistoryChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final history = CallHistoryService.instance.history;

    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.white12),
            const SizedBox(height: 16),
            const Text(
              'No call history yet',
              style: TextStyle(fontSize: 16, color: Colors.white38),
            ),
            const SizedBox(height: 6),
            const Text(
              'Make a call from the Audio or Video tab',
              style: TextStyle(fontSize: 13, color: Colors.white24),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      itemCount: history.length,
      itemBuilder: (_, i) => _HistoryTile(entry: history[i]),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final CallHistoryEntry entry;

  const _HistoryTile({required this.entry});

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) {
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return 'Today $h:$m';
    } else if (diff.inDays == 1) {
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return 'Yesterday $h:$m';
    } else {
      return '${dt.day}/${dt.month}/${dt.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMissed = entry.direction == CallDirection.missed;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF111318),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMissed
              ? const Color(0xFFFF4757).withOpacity(0.3)
              : Colors.white.withOpacity(0.07),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          _AvatarWidget(user: entry.user, size: 48),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.user.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isMissed
                              ? const Color(0xFFFF4757)
                              : Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (entry.user.isVerified) ...[
                      const SizedBox(width: 5),
                      const Icon(Icons.verified,
                          color: Color(0xFF3B82F6), size: 14),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(entry.directionIcon,
                        color: entry.directionColor, size: 14),
                    const SizedBox(width: 4),
                    Icon(
                      entry.type == CallType.audio
                          ? Icons.phone
                          : Icons.videocam,
                      color: Colors.white38,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      entry.type == CallType.audio ? 'Audio' : 'Video',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.white38),
                    ),
                    if (!isMissed) ...[
                      const SizedBox(width: 8),
                      Text(
                        '· ${entry.durationLabel}',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.white38),
                      ),
                    ],
                    if (entry.isDemo) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'DEMO',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.white30,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Date
          Text(
            _formatDate(entry.timestamp),
            style: const TextStyle(fontSize: 11, color: Colors.white30),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Section header row inside a list.
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;

  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFF2D55), Color(0xFF9B51E0)],
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: Colors.white38),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Reusable avatar: shows network image or coloured initials.
class _AvatarWidget extends StatelessWidget {
  final CallUser user;
  final double size;

  const _AvatarWidget({required this.user, required this.size});

  String get _initials {
    final parts = user.name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  Color get _bgColor {
    const colors = [
      Color(0xFF9B51E0),
      Color(0xFFFF2D55),
      Color(0xFF00E5FF),
      Color(0xFFFF6B35),
      Color(0xFF00E676),
    ];
    final idx =
        user.id.codeUnits.fold(0, (a, b) => a + b) % colors.length;
    return colors[idx];
  }

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: user.avatarUrl != null
          ? Image.network(
              user.avatarUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildInitials(),
            )
          : _buildInitials(),
    );
  }

  Widget _buildInitials() => Container(
        width: size,
        height: size,
        color: _bgColor,
        alignment: Alignment.center,
        child: Text(
          _initials,
          style: TextStyle(
            fontSize: size * 0.38,
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
}
