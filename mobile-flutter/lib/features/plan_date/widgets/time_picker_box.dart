import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../plan_date_theme.dart';
import '../providers/plan_date_provider.dart';

/// Hour/minute steppers plus an AM/PM toggle derived from the draft date.
class TimePickerBox extends ConsumerWidget {
  const TimePickerBox({super.key, required this.chatId});

  final String chatId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateTime = ref.watch(planDateProvider(chatId)).dateTime;
    final notifier = ref.read(planDateProvider(chatId).notifier);
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final isPm = dateTime.hour >= 12;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'TIME',
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
            _Stepper(
              value: hour.toString().padLeft(2, '0'),
              onUp: () => notifier.stepHour(1),
              onDown: () => notifier.stepHour(-1),
              upLabel: 'Increase hour',
              downLabel: 'Decrease hour',
            ),
            const SizedBox(width: 10),
            _Stepper(
              value: dateTime.minute.toString().padLeft(2, '0'),
              onUp: () => notifier.stepMinute(1),
              onDown: () => notifier.stepMinute(-1),
              upLabel: 'Increase minutes',
              downLabel: 'Decrease minutes',
            ),
          ],
        ),
        const SizedBox(height: 10),
        Semantics(
          button: true,
          label: 'Toggle AM or PM, currently ${isPm ? 'PM' : 'AM'}',
          child: GestureDetector(
            onTap: notifier.toggleAmPm,
            child: Container(
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: PDColors.inputFill,
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: PDColors.gradientPink, width: 1.4),
              ),
              child: Text(
                isPm ? 'PM' : 'AM',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.value,
    required this.onUp,
    required this.onDown,
    required this.upLabel,
    required this.downLabel,
  });

  final String value;
  final VoidCallback onUp;
  final VoidCallback onDown;
  final String upLabel;
  final String downLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 62,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            button: true,
            label: upLabel,
            child: IconButton(
              onPressed: onUp,
              icon: const Icon(Icons.keyboard_arrow_up),
              color: PDColors.chooserPink,
              iconSize: 22,
              constraints: const BoxConstraints(
                minWidth: kMinTouchTarget,
                minHeight: 32,
              ),
              padding: EdgeInsets.zero,
              tooltip: upLabel,
            ),
          ),
          Container(
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: PDColors.inputFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: PDColors.gradientPink, width: 1.4),
            ),
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Semantics(
            button: true,
            label: downLabel,
            child: IconButton(
              onPressed: onDown,
              icon: const Icon(Icons.keyboard_arrow_down),
              color: PDColors.chooserPink,
              iconSize: 22,
              constraints: const BoxConstraints(
                minWidth: kMinTouchTarget,
                minHeight: 32,
              ),
              padding: EdgeInsets.zero,
              tooltip: downLabel,
            ),
          ),
        ],
      ),
    );
  }
}
