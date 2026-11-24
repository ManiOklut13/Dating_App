import 'package:flutter/material.dart';

import '../../models/call_user.dart';
import '../../services/call_history_service.dart';
import 'audio_call_screen.dart';
import 'call_ui.dart';
import 'video_call_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Calls page — Audio · Video · History
// ─────────────────────────────────────────────────────────────────────────────
class CallsScreen extends StatefulWidget {
  const CallsScreen({super.key});

  @override
  State<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {
  int _tab = 0; // 0 audio · 1 video · 2 history
  String _historyFilter = 'all'; // all | audio | video | missed

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CallUi.bg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x26180A14), Color(0x0008060C)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTabs(),
              const SizedBox(height: 4),
              Expanded(child: _buildTabBody()),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 14),
      child: Row(
        children: [
          Material(
            color: CallUi.panel,
            shape: const CircleBorder(side: BorderSide(color: CallUi.border)),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Navigator.of(context).maybePop(),
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(Icons.arrow_back_ios_new,
                    size: 15, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Calls',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Audio calls, video calls and call history',
                  style: TextStyle(fontSize: 11.5, color: CallUi.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Tabs ─────────────────────────────────────────────────────────────────
  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: CallUi.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CallUi.border),
      ),
      child: Row(
        children: [
          _tabButton(
            index: 0,
            icon: Icons.phone_outlined,
            label: 'Audio',
            count: _kContacts.length,
            gradient: CallUi.audioTab,
          ),
          _tabButton(
            index: 1,
            icon: Icons.videocam_outlined,
            label: 'Video',
            count: _kContacts.length,
            gradient: CallUi.videoTab,
          ),
          _tabButton(
            index: 2,
            icon: Icons.history,
            label: 'History',
            gradient: CallUi.historyTab,
          ),
        ],
      ),
    );
  }

  Widget _tabButton({
    required int index,
    required IconData icon,
    required String label,
    int? count,
    required LinearGradient gradient,
  }) {
    final selected = _tab == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _tab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 2),
          decoration: BoxDecoration(
            gradient: selected ? gradient : null,
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: gradient.colors.last.withValues(alpha: 0.30),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: selected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.55),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  count == null ? label : '$label ($count)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    color: selected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.55),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Tab body ─────────────────────────────────────────────────────────────
  Widget _buildTabBody() {
    switch (_tab) {
      case 1:
        return _buildContactList(
          forVideo: true,
          sectionLabel: '${_kContacts.length} video call contacts',
        );
      case 2:
        return _buildHistory();
      default:
        return _buildContactList(
          forVideo: false,
          sectionLabel: '${_kContacts.length} audio call contacts',
        );
    }
  }

  Widget _buildContactList({
    required bool forVideo,
    required String sectionLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
          child: Text(
            sectionLabel,
            style: const TextStyle(fontSize: 12, color: CallUi.muted),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: _kContacts.length,
            itemBuilder: (_, i) => _buildContactCard(_kContacts[i], forVideo),
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard(_CallContact contact, bool forVideo) {
    final user = contact.user;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: CallUi.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: CallUi.border),
      ),
      child: Row(
        children: [
          CallAvatar(
            name: user.name,
            asset: CallUi.avatarAssetFor(user.name),
            size: 52,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (user.isVerified) ...[
                      const SizedBox(width: 5),
                      const Icon(Icons.verified,
                          size: 15, color: CallUi.verified),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                contact.isOnline
                    ? Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: CallUi.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'Active now',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: CallUi.green,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        contact.lastSeen,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: CallUi.muted,
                        ),
                      ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          CallActionButton(
            icon: forVideo ? Icons.videocam : Icons.phone,
            color: forVideo ? CallUi.video : CallUi.audio,
            tooltip: forVideo ? 'Video call' : 'Audio call',
            onTap: () => _startCall(user, video: forVideo),
          ),
        ],
      ),
    );
  }

  // ─── History ──────────────────────────────────────────────────────────────
  Widget _buildHistory() {
    final service = CallHistoryService.instance;

    return AnimatedBuilder(
      animation: service,
      builder: (context, _) {
        final all = service.history;
        final filtered = all.where((e) {
          switch (_historyFilter) {
            case 'audio':
              return e.type == CallType.audio;
            case 'video':
              return e.type == CallType.video;
            case 'missed':
              return e.direction == CallDirection.missed;
            default:
              return true;
          }
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterPill('All', 'all'),
                    const SizedBox(width: 8),
                    _filterPill('Audio', 'audio'),
                    const SizedBox(width: 8),
                    _filterPill('Video', 'video'),
                    const SizedBox(width: 8),
                    _filterPill('Missed', 'missed'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Text(
                        'No calls in this filter',
                        style: TextStyle(fontSize: 13, color: CallUi.muted),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 24),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) => _buildHistoryCard(filtered[i]),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _filterPill(String label, String key) {
    final selected = _historyFilter == key;

    return GestureDetector(
      onTap: () => setState(() => _historyFilter = key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? CallUi.pink.withValues(alpha: 0.14)
              : CallUi.panel,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? CallUi.pink : CallUi.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected
                ? CallUi.pinkSoft
                : Colors.white.withValues(alpha: 0.60),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(CallHistoryEntry entry) {
    final isMissed = entry.direction == CallDirection.missed;
    final isVideo = entry.type == CallType.video;
    final accent = isVideo ? CallUi.video : CallUi.audio;

    final details = [
      callTimeLabel(entry.timestamp),
      if (!isMissed && entry.duration.inSeconds > 0)
        callDurationLabel(entry.duration),
    ].join('  ·  ');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: CallUi.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: CallUi.border),
      ),
      child: Row(
        children: [
          CallAvatar(
            name: entry.user.name,
            asset: CallUi.avatarAssetFor(entry.user.name),
            size: 50,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.user.name.split(' ').first,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (isMissed) ...[
                      const SizedBox(width: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 1),
                        decoration: BoxDecoration(
                          color: CallUi.pink.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: const Text(
                          'Missed',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: CallUi.pinkSoft,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      entry.directionIcon,
                      size: 13,
                      color: entry.directionColor,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        details,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: CallUi.muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: accent.withValues(alpha: 0.30)),
            ),
            child: Icon(
              isVideo ? Icons.videocam : Icons.phone,
              size: 16,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Calls (existing demo call screens) ───────────────────────────────────
  void _startCall(CallUser user, {required bool video}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => video
            ? VideoCallScreen(user: user)
            : AudioCallScreen(user: user),
        fullscreenDialog: true,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Demo roster for the Audio / Video tabs
// ─────────────────────────────────────────────────────────────────────────────
class _CallContact {
  final CallUser user;
  final bool isOnline;
  final String lastSeen;

  const _CallContact({
    required this.user,
    required this.isOnline,
    this.lastSeen = '',
  });
}

const _kContacts = <_CallContact>[
  _CallContact(
    user: CallUser(
      id: '22222222-2222-2222-2222-222222222222',
      name: 'Ananya Sharma',
      isVerified: true,
      city: 'Bandra, Mumbai',
    ),
    isOnline: true,
  ),
  _CallContact(
    user: CallUser(
      id: 'user-meera-kapoor',
      name: 'Meera Kapoor',
      isVerified: true,
      city: 'Andheri, Mumbai',
    ),
    isOnline: true,
  ),
  _CallContact(
    user: CallUser(
      id: 'user-meera-4',
      name: 'Meera Nair',
      isVerified: true,
      city: 'Kochi, Kerala',
    ),
    isOnline: true,
  ),
  _CallContact(
    user: CallUser(
      id: 'user-riya-2',
      name: 'Riya Sen',
      isVerified: true,
      city: 'Hauz Khas, Delhi',
    ),
    isOnline: true,
  ),
  _CallContact(
    user: CallUser(
      id: 'user-tara-5',
      name: 'Tara Deshmukh',
      city: 'Pune, Maharashtra',
    ),
    isOnline: true,
  ),
  _CallContact(
    user: CallUser(
      id: 'user-vikram-6',
      name: 'Vikram Singhania',
      isVerified: true,
      city: 'Colaba, Mumbai',
    ),
    isOnline: true,
  ),
  _CallContact(
    user: CallUser(
      id: 'user-aanya-7',
      name: 'Aanya Patel',
      city: 'Ahmedabad, Gujarat',
    ),
    isOnline: false,
    lastSeen: 'Last seen 1d ago',
  ),
  _CallContact(
    user: CallUser(
      id: 'user-kabir-6',
      name: 'Kabir Kapoor',
      isVerified: true,
      city: 'Colaba, Mumbai',
    ),
    isOnline: false,
    lastSeen: 'Last seen 2h ago',
  ),
];
