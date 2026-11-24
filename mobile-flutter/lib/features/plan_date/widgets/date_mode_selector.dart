import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/plan_date_model.dart';
import '../plan_date_theme.dart';
import '../providers/plan_date_provider.dart';

/// Segmented Virtual/Offline selector with a gradient glow on the active side.
class DateModeSelector extends ConsumerWidget {
  const DateModeSelector({super.key, required this.chatId});

  final String chatId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(planDateProvider(chatId));
    final notifier = ref.read(planDateProvider(chatId).notifier);
    final hint = draft.mode == DateMode.virtual
        ? 'Video call from anywhere'
        : 'Meet in person';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: PDColors.card,
        borderRadius: BorderRadius.all(Radius.circular(PDRadius.card)),
        border: Border.fromBorderSide(BorderSide(color: PDColors.cardBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text('Date Mode', style: PDTextStyles.sectionTitle),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hint,
                  textAlign: TextAlign.end,
                  style: PDTextStyles.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: PDColors.inputFill,
              borderRadius: BorderRadius.circular(PDRadius.control),
              border: Border.all(color: PDColors.inputBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _Segment(
                    label: 'Virtual',
                    icon: Icons.videocam_outlined,
                    selected: draft.mode == DateMode.virtual,
                    onTap: () => notifier.setMode(DateMode.virtual),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _Segment(
                    label: 'Offline',
                    icon: Icons.place_outlined,
                    selected: draft.mode == DateMode.offline,
                    onTap: () => notifier.setMode(DateMode.offline),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 13),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: selected ? PDGradients.selection : null,
            color: selected ? null : PDColors.controlFill,
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x55E91E8C),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? Colors.white : PDColors.textMuted,
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? Colors.white : PDColors.textMuted,
                    fontSize: 13.5,
                    fontWeight:
                        selected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
