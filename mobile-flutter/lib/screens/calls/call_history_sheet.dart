import 'package:flutter/material.dart';

import '../../models/call_user.dart';
import '../../services/call_history_service.dart';
import 'audio_call_screen.dart';
import 'call_ui.dart';
import 'video_call_screen.dart';

/// Opens the dark Call History popup used by the main Chat tab header.
Future<void> showCallHistorySheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    barrierColor: Colors.black.withValues(alpha: 0.62),
    builder: (_) => const CallHistorySheet(),
  );
}

class CallHistorySheet extends StatefulWidget {
  const CallHistorySheet({super.key});

  @override
  State<CallHistorySheet> createState() => _CallHistorySheetState();
}

class _CallHistorySheetState extends State<CallHistorySheet> {
  String _filter = 'all'; // all | audio | video | missed

  List<CallHistoryEntry> get _filtered {
    final all = CallHistoryService.instance.history;
    switch (_filter) {
      case 'audio':
        return all.where((e) => e.type == CallType.audio).toList();
      case 'video':
        return all.where((e) => e.type == CallType.video).toList();
      case 'missed':
        return all
            .where((e) => e.direction == CallDirection.missed)
            .toList();
      default:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = _filtered;

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      maxChildSize: 0.92,
      minChildSize: 0.45,
      builder: (ctx, scroll) => Container(
        decoration: const BoxDecoration(
          color: CallUi.sheet,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: CallUi.border)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            _buildHeader(),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterPill('All Calls', 'all'),
                    const SizedBox(width: 8),
                    _filterPill('Audio Calls', 'audio'),
                    const SizedBox(width: 8),
                    _filterPill('Video Calls', 'video'),
                    const SizedBox(width: 8),
                    _filterPill('Missed Calls', 'missed'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: entries.isEmpty
                  ? const Center(
                      child: Text(
                        'No calls in this filter',
                        style: TextStyle(fontSize: 13, color: CallUi.muted),
                      ),
                    )
                  : ListView.builder(
                      controller: scroll,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: entries.length,
                      itemBuilder: (_, i) => _buildEntry(entries[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: CallUi.audio.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CallUi.audio.withValues(alpha: 0.30)),
            ),
            child: const Icon(Icons.phone, color: CallUi.audio, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Audio Call History',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Recent LiveKit WebRTC sessions',
                  style: TextStyle(fontSize: 12, color: CallUi.muted),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              child: Icon(
                Icons.close,
                size: 21,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterPill(String label, String key) {
    final selected = _filter == key;

    return GestureDetector(
      onTap: () => setState(() => _filter = key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? CallUi.pink.withValues(alpha: 0.16)
              : CallUi.panel,
          borderRadius: BorderRadius.circular(18),
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

  Widget _buildEntry(CallHistoryEntry entry) {
    final isMissed = entry.direction == CallDirection.missed;
    final minutes = entry.duration.inMinutes.toString().padLeft(2, '0');
    final seconds = entry.duration.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF171320),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CallUi.border),
      ),
      child: Row(
        children: [
          CallAvatar(
            name: entry.user.name,
            asset: CallUi.avatarAssetFor(entry.user.name),
            size: 48,
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
                        entry.user.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (isMissed) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: CallUi.pink.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Missed',
                          style: TextStyle(
                            color: CallUi.pinkSoft,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
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
                        '${callTimeLabel(entry.timestamp)}  ·  ${minutes}m ${seconds}s',
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
          const SizedBox(width: 6),
          CallActionButton(
            icon: Icons.phone,
            color: CallUi.audio,
            tooltip: 'Audio call',
            size: 38,
            onTap: () => _startCall(entry.user, video: false),
          ),
          const SizedBox(width: 7),
          CallActionButton(
            icon: Icons.videocam,
            color: CallUi.video,
            tooltip: 'Video call',
            size: 38,
            onTap: () => _startCall(entry.user, video: true),
          ),
        ],
      ),
    );
  }

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
