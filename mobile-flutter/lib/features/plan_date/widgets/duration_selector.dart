import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../plan_date_theme.dart';
import '../providers/plan_date_provider.dart';

/// Duration stepper with quick preset chips from 30 to 120 minutes.
class DurationSelector extends ConsumerWidget {
  const DurationSelector({super.key, required this.chatId});

  final String chatId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(planDateProvider(chatId));
    final notifier = ref.read(planDateProvider(chatId).notifier);
    const presets = [30, 60, 90, 120];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'DURATION',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: PDColors.textMuted,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              button: true,
              label: 'Decrease duration',
              child: GestureDetector(
                onTap: () => notifier.stepDuration(-1),
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: PDColors.controlFill,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: PDColors.inputBorder),
                  ),
                  child: const Icon(Icons.remove, color: PDColors.textPrimary),
                ),
              ),
            ),
            const SizedBox(width: 14),
            SizedBox(
              width: 58,
              child: Column(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: Text(
                      '${draft.durationMinutes}',
                      key: ValueKey<int>(draft.durationMinutes),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Text(
                    'minutes',
                    textAlign: TextAlign.center,
                    style: PDTextStyles.muted,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Semantics(
              button: true,
              label: 'Increase duration',
              child: GestureDetector(
                onTap: () => notifier.stepDuration(1),
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: PDGradients.selection,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x55E91E8C),
                        blurRadius: 14,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final preset in presets)
              Semantics(
                button: true,
                selected: draft.durationMinutes == preset,
                label: '$preset minutes',
                child: GestureDetector(
                  onTap: () => notifier.setDuration(preset),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 48,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: draft.durationMinutes == preset
                          ? PDColors.gradientPink.withValues(alpha: 0.12)
                          : PDColors.controlFill,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: draft.durationMinutes == preset
                            ? PDColors.gradientPink
                            : PDColors.inputBorder,
                      ),
                    ),
                    child: Text(
                      '$preset',
                      style: TextStyle(
                        color: draft.durationMinutes == preset
                            ? Colors.white
                            : PDColors.textMuted,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
