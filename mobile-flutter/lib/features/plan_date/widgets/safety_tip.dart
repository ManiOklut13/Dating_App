// ─────────────────────────────────────────────────────────────────────────────
// Safety Tip (Offline-only)
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../plan_date_theme.dart';

class SafetyTip extends StatelessWidget {
  const SafetyTip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: PDColors.safetyBg,
        borderRadius: BorderRadius.circular(PDRadius.control),
        border: Border.all(color: PDColors.safetyBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: PDColors.textSuccess.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield_outlined,
                color: PDColors.textSuccess, size: 18),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Meet in a public place and share your plan with a friend.',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: PDColors.textSuccess,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

