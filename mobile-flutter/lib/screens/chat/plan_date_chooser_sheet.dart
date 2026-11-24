import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/profiles_data.dart';
import '../../models/chat_profile_models.dart';
import '../../services/chat_list_provider.dart';

/// Opens the Plan a Date chooser as a centered, dimmed modal.
///
/// Returns the conversation picked by the user, or null when dismissed.
Future<ChatConversationModel?> showPlanDateChooser(BuildContext context) {
  return showGeneralDialog<ChatConversationModel>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close Plan a Date chooser',
    barrierColor: Colors.black.withValues(alpha: 0.82),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            ),
            child: FadeTransition(
              opacity: animation,
              child: const PlanDateChooserSheet(),
            ),
          ),
        ),
      );
    },
  );
}

/// Modal list of every chat conversation that can be used as a date partner.
class PlanDateChooserSheet extends ConsumerWidget {
  const PlanDateChooserSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chats = ref.watch(chatConversationsProvider);
    final maxHeight = MediaQuery.sizeOf(context).height * 0.8;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 460, maxHeight: maxHeight),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0x33FF2D55)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                        children: [
                          TextSpan(text: 'Plan a '),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: _GradientDateWord(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Semantics(
                    button: true,
                    label: 'Close Plan a Date chooser',
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                      iconSize: 22,
                      constraints: const BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                      ),
                      tooltip: 'Close',
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 2, 20, 10),
              child: Text(
                'Pick a chat to plan a date with:',
                style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
              ),
            ),
            Flexible(
              child: Scrollbar(
                thickness: 2,
                radius: const Radius.circular(2),
                child: chats.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.fromLTRB(20, 8, 20, 28),
                        child: Text(
                          'No conversations yet. Start chatting to plan a date.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        itemCount: chats.length,
                        itemBuilder: (context, index) {
                          final chat = chats[index];
                          return _ChooserRow(
                            chat: chat,
                            onTap: () => Navigator.of(context).pop(chat),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChooserRow extends StatelessWidget {
  const _ChooserRow({required this.chat, required this.onTap});

  final ChatConversationModel chat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Plan a date with ${chat.name}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: 62,
            child: Row(
              children: [
                ClipOval(
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: chat.avatarAsset != null
                        ? SafeProfileImage(
                            imageUrl: chat.avatarAsset!,
                            width: 44,
                            height: 44,
                          )
                        : _AvatarFallback(name: chat.name, size: 44),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    chat.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.calendar_month_outlined,
                  color: Color(0xFFFFD700),
                  size: 20,
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.name, required this.size});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      color: const Color(0xFF2A2036),
      child: Text(
        name.isEmpty ? '?' : name.substring(0, 1).toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _GradientDateWord extends StatelessWidget {
  const _GradientDateWord();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xFFFF5C9A), Color(0xFFC77DFF)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(bounds),
      child: const Text(
        'Date',
        style: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -0.3,
        ),
      ),
    );
  }
}
