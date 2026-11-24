import 'package:flutter/material.dart';

import '../../models/call_user.dart';
import '../../services/call_history_service.dart';
import 'call_ui.dart';
import 'live_interactive_call_screen.dart';

/// Video-call entry point for calls started from Chat (call history popup and
/// the Calls page).
///
/// The app's video-call UI already exists as [LiveInteractiveCallScreen] and is
/// used by Connect/Discovery. This screen now delegates to that implementation
/// instead of showing the old standalone demo video layout.
class VideoCallScreen extends StatelessWidget {
  final CallUser user;

  const VideoCallScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return LiveInteractiveCallScreen(
      userName: user.name,
      avatarUrl: user.avatarUrl ?? CallUi.avatarAssetFor(user.name) ?? '',
      isVideo: true,
      onCallEnded: (duration) {
        CallHistoryService.instance.addEntry(CallHistoryEntry(
          id: 'video-${DateTime.now().millisecondsSinceEpoch}',
          user: user,
          type: CallType.video,
          direction: CallDirection.outgoing,
          timestamp: DateTime.now(),
          duration: duration,
        ));
      },
    );
  }
}
