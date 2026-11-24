import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../plan_date_theme.dart';
import '../providers/plan_date_provider.dart';

/// Compact month calendar with month arrows, swipe support and past-day locks.
class MiniCalendar extends ConsumerStatefulWidget {
  const MiniCalendar({super.key, required this.chatId});

  final String chatId;

  @override
  ConsumerState<MiniCalendar> createState() => _MiniCalendarState();
}

class _MiniCalendarState extends ConsumerState<MiniCalendar> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final selected = ref.read(planDateProvider(widget.chatId)).dateTime;
    _month = DateTime(selected.year, selected.month);
  }

  void _changeMonth(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(planDateProvider(widget.chatId));
    final notifier = ref.read(planDateProvider(widget.chatId).notifier);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final leadingBlanks = DateTime(_month.year, _month.month, 1).weekday % 7;
    final selected = draft.dateTime;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                DateFormat('MMMM yyyy').format(_month),
                style: const TextStyle(
                  color: PDColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                final current = DateTime.now();
                setState(() {
                  _month = DateTime(current.year, current.month);
                });
                notifier.jumpToToday();
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: Text(
                  'Today',
                  style: TextStyle(
                    color: PDColors.gradientPink,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            _Weekday('S'),
            _Weekday('M'),
            _Weekday('T'),
            _Weekday('W'),
            _Weekday('T'),
            _Weekday('F'),
            _Weekday('S'),
          ],
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onHorizontalDragEnd: (details) {
            final velocity = details.primaryVelocity ?? 0;
            if (velocity < -180) {
              _changeMonth(1);
            } else if (velocity > 180) {
              _changeMonth(-1);
            }
          },
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 2,
              childAspectRatio: 1,
            ),
            itemCount: leadingBlanks + daysInMonth,
            itemBuilder: (context, index) {
              if (index < leadingBlanks) return const SizedBox.shrink();
              final day = index - leadingBlanks + 1;
              final date = DateTime(_month.year, _month.month, day);
              final isPast = date.isBefore(today);
              final isSelected =
                  date.year == selected.year &&
                  date.month == selected.month &&
                  date.day == selected.day;

              return Semantics(
                button: true,
                enabled: !isPast,
                selected: isSelected,
                label: DateFormat('EEEE, d MMMM y').format(date),
                child: GestureDetector(
                  onTap: isPast ? null : () => notifier.setDate(date),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: isSelected ? PDGradients.selection : null,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$day',
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : isPast
                                ? PDColors.disabledText
                                : PDColors.textPrimary,
                        fontSize: 12.5,
                        fontWeight: isPast
                            ? FontWeight.w400
                            : FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Semantics(
              button: true,
              label: 'Previous month',
              child: IconButton(
                onPressed: () => _changeMonth(-1),
                icon: const Icon(Icons.chevron_left),
                color: PDColors.textMuted,
                iconSize: 20,
                constraints: const BoxConstraints(
                  minWidth: kMinTouchTarget,
                  minHeight: kMinTouchTarget,
                ),
                tooltip: 'Previous month',
              ),
            ),
            Expanded(
              child: Text(
                'Selected: ${DateFormat('EEE, d MMM yyyy').format(selected)}',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: PDTextStyles.muted,
              ),
            ),
            Semantics(
              button: true,
              label: 'Next month',
              child: IconButton(
                onPressed: () => _changeMonth(1),
                icon: const Icon(Icons.chevron_right),
                color: PDColors.textMuted,
                iconSize: 20,
                constraints: const BoxConstraints(
                  minWidth: kMinTouchTarget,
                  minHeight: kMinTouchTarget,
                ),
                tooltip: 'Next month',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Weekday extends StatelessWidget {
  const _Weekday(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: PDColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
