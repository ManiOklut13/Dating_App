// ─────────────────────────────────────────────────────────────────────────────
// Plan Date Header - Restyled
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../plan_date_theme.dart';
import 'gradient_text.dart';

class PlanDateHeader extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onMyDates;

  const PlanDateHeader({
    super.key,
    required this.onClose,
    required this.onMyDates,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          Semantics(
            label: 'Close Plan a Date',
            button: true,
            child: InkWell(
              onTap: onClose,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: PDColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: PDColors.cardBorder),
                ),
                child: const Icon(Icons.close, color: PDColors.textPrimary, size: 20),
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Plan a ',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: PDColors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                GradientText(
                  'Date',
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF5C9A), Color(0xFFC77DFF)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ],
            ),
          ),
          Semantics(
            label: 'My Dates calendar',
            button: true,
            child: InkWell(
              onTap: onMyDates,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: PDColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: PDColors.cardBorder),
                ),
                child: const Icon(
                  Icons.calendar_today_outlined,
                  color: Color(0xFFFF6FA3),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
