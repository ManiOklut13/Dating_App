import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/date_invite.dart';
import '../plan_date_theme.dart';
import '../providers/plan_date_provider.dart';

/// Horizontal mode-aware date-type carousel with animated selected tiles.
class DateTypeCarousel extends ConsumerWidget {
  const DateTypeCarousel({super.key, required this.chatId});

  final String chatId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(planDateProvider(chatId));
    final notifier = ref.read(planDateProvider(chatId).notifier);
    final options = DateTypeOption.optionsFor(draft.mode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Text('Date Type', style: PDTextStyles.sectionTitle),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Swipe for more >',
                textAlign: TextAlign.end,
                style: PDTextStyles.muted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 108,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            itemCount: options.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final option = options[index];
              final selected = option.id == draft.type.id;
              return Semantics(
                button: true,
                selected: selected,
                label: option.label,
                child: GestureDetector(
                  onTap: () => notifier.setType(option),
                  child: AnimatedScale(
                    scale: selected ? 1.04 : 1,
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutBack,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: 84,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: selected ? PDGradients.selection : null,
                        color: selected ? null : PDColors.card,
                        borderRadius:
                            BorderRadius.circular(PDRadius.control),
                        border: Border.all(
                          color: selected
                              ? PDColors.gradientPink
                              : PDColors.cardBorder,
                        ),
                        boxShadow: selected
                            ? const [
                                BoxShadow(
                                  color: Color(0x55E91E8C),
                                  blurRadius: 18,
                                  offset: Offset(0, 5),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            option.icon,
                            size: 24,
                            color: selected
                                ? Colors.white
                                : PDColors.textMuted,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            option.label,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : PDColors.textPrimary,
                              fontSize: 11.5,
                              fontWeight: selected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
