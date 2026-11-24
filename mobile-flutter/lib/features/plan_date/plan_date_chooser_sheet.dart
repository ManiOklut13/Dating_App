import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/profiles_data.dart';
import '../../models/chat_profile_models.dart';
import '../../services/chat_list_provider.dart';
import 'plan_date_theme.dart';

/// Opens the Plan a Date chooser as a centered, dimmed modal dialog.
Future<void> showPlanDateChooser({
  required BuildContext context,
  required ValueChanged<ChatConversationModel> onPick,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close Plan a Date chooser',
    barrierColor: Colors.black.withValues(alpha: 0.7),
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
              child: PlanDateChooserSheet(onPick: onPick),
            ),
          ),
        ),
      );
    },
  );
}

/// Modal list of every chat conversation that can be used as a date partner.
class PlanDateChooserSheet extends ConsumerWidget {
  const PlanDateChooserSheet({super.key, required this.onPick});

  final ValueChanged<ChatConversationModel> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chats = ref.watch(chatConversationsProvider);
    final maxHeight = MediaQuery.sizeOf(context).height * 0.8;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 460,
        maxHeight: maxHeight,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: PDColors.chooserCard,
          borderRadius: BorderRadius.circular(PDRadius.card),
          border: Border.all(color: PDColors.chooserBorder),
          boxShadow: PDShadows.cardShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: const TextSpan(
                        style: PDTextStyles.heading,
                        children: [
                          TextSpan(text: 'Plan a '),
                          TextSpan(
                            text: 'Date',
                            style: TextStyle(color: PDColors.chooserPink),
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
                      icon: const Icon(Icons.close, color: PDColors.textPrimary),
                      iconSize: 22,
                      constraints: const BoxConstraints(
                        minWidth: kMinTouchTarget,
                        minHeight: kMinTouchTarget,
                      ),
                      tooltip: 'Close',
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Text(
                'Pick a chat to plan a date with:',
                style: PDTextStyles.muted,
              ),
            ),
            Flexible(
              child: Scrollbar(
                thickness: 2,
                radius: const Radius.circular(2),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    return _ChooserRow(
                      chat: chats[index],
                      onTap: () => onPick(chats[index]),
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
          borderRadius: BorderRadius.circular(PDRadius.control),
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                ClipOval(
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: chat.avatarAsset != null
                        ? SafeProfileImage(
                            imageUrl: chat.avatarAsset!,
                            width: 48,
                            height: 48,
                          )
                        : Container(
                            color: PDColors.controlFill,
                            alignment: Alignment.center,
                            child: Text(
                              chat.name.substring(0, 1),
                              style: const TextStyle(
                                color: PDColors.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    chat.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: PDColors.textPrimary,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_month_outlined,
                  color: PDColors.calendarYellow,
                  size: 22,
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
