// ─────────────────────────────────────────────────────────────────────────────
// Date & Time Picker - Restyled
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../plan_date_theme.dart';

class DateTimePicker extends StatelessWidget {
  final DateTime? selectedDate;
  final int hour;
  final int minute;
  final bool isAm;
  final int durationMin;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<int> onHourChanged;
  final ValueChanged<int> onMinuteChanged;
  final ValueChanged<bool> onAmPmChanged;

  const DateTimePicker({
    super.key,
    required this.selectedDate,
    required this.hour,
    required this.minute,
    required this.isAm,
    required this.durationMin,
    required this.onDateChanged,
    required this.onHourChanged,
    required this.onMinuteChanged,
    required this.onAmPmChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column - Time
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TIME',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: PDColors.textMuted,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _timeBox(
                    value: hour.toString().padLeft(2, '0'),
                    onUp: () => onHourChanged(hour == 12 ? 1 : hour + 1),
                    onDown: () => onHourChanged(hour == 1 ? 12 : hour - 1),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      ':',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 28,
                        color: PDColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _timeBox(
                    value: minute.toString().padLeft(2, '0'),
                    onUp: () {
                      final minutes = [0, 15, 30, 45];
                      final idx = minutes.indexOf(minute);
                      onMinuteChanged(minutes[(idx + 1) % 4]);
                    },
                    onDown: () {
                      final minutes = [0, 15, 30, 45];
                      final idx = minutes.indexOf(minute);
                      onMinuteChanged(minutes[(idx - 1 + 4) % 4]);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => onAmPmChanged(!isAm),
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    color: PDColors.card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: PDColors.cardBorder,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      isAm ? 'AM' : 'PM',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: PDColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Right column - Calendar
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMMM yyyy').format(selectedDate ?? DateTime.now()),
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: PDColors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => onDateChanged(DateTime.now()),
                    child: const Text(
                      'Today',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: PDColors.textAccent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildCalendar(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _timeBox({
    required String value,
    required VoidCallback onUp,
    required VoidCallback onDown,
  }) {
    return Expanded(
      child: Column(
        children: [
          GestureDetector(
            onTap: onUp,
            child: Container(
              height: 28,
              decoration: const BoxDecoration(
                color: PDColors.card,
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: const Icon(
                Icons.keyboard_arrow_up,
                color: PDColors.textMuted,
                size: 18,
              ),
            ),
          ),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: PDColors.card,
              border: Border.all(
                color: PDColors.cardBorder,
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                value,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: PDColors.textPrimary,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: onDown,
            child: Container(
              height: 28,
              decoration: const BoxDecoration(
                color: PDColors.card,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
              ),
              child: const Icon(
                Icons.keyboard_arrow_down,
                color: PDColors.textMuted,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final now = DateTime.now();
    final displayMonth = selectedDate ?? now;
    final firstDayOfMonth = DateTime(displayMonth.year, displayMonth.month, 1);
    final lastDayOfMonth = DateTime(displayMonth.year, displayMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday; // 1 = Monday

    final List<Widget> dayWidgets = [];
    
    // Add day headers
    final headers = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    for (var h in headers) {
      dayWidgets.add(
        Center(
          child: Text(
            h,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: PDColors.textPrimary,
            ),
          ),
        ),
      );
    }

    // Add empty cells for days before month starts
    for (var i = 1; i < firstWeekday; i++) {
      dayWidgets.add(const SizedBox());
    }

    // Add days of month
    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(displayMonth.year, displayMonth.month, day);
      final isSelected = selectedDate != null &&
          selectedDate!.year == date.year &&
          selectedDate!.month == date.month &&
          selectedDate!.day == date.day;
      final isToday = now.year == date.year &&
          now.month == date.month &&
          now.day == date.day;

      dayWidgets.add(
        GestureDetector(
          onTap: () => onDateChanged(date),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              gradient: isSelected ? PDGradients.primary : null,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 11,
                  fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : isToday
                          ? PDColors.textAccent
                          : PDColors.textMuted,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: dayWidgets,
    );
  }
}
