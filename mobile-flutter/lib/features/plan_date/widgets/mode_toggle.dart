// ─────────────────────────────────────────────────────────────────────────────
// Mode Toggle (Virtual / Offline segmented control) - Restyled
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../models/plan_date_model.dart';
import '../plan_date_theme.dart';

class ModeToggle extends StatelessWidget {
  final DateMode mode;
  final ValueChanged<DateMode> onChanged;

  const ModeToggle({super.key, required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Date Mode',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: PDColors.textPrimary,
              ),
            ),
            Text(
              mode == DateMode.virtual
                  ? 'Video call from anywhere'
                  : 'Meet in person',
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: PDColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: PDColors.inputFill,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: PDColors.cardBorder),
          ),
          child: Row(
            children: [
              _pill('Virtual', DateMode.virtual, Icons.videocam_outlined),
              const SizedBox(width: 6),
              _pill('Offline', DateMode.offline, Icons.location_on_outlined),
            ],
          ),
        ),
      ],
    );
  }

  Widget _pill(String label, DateMode value, IconData icon) {
    final selected = mode == value;
    return Expanded(
      child: Semantics(
        label: '$label date mode',
        selected: selected,
        button: true,
        child: GestureDetector(
          onTap: () => onChanged(value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            height: 48,
            decoration: BoxDecoration(
              gradient: selected ? PDGradients.modePill : null,
              borderRadius: BorderRadius.circular(14),
              boxShadow: selected ? PDShadows.ctaGlow : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: selected ? Colors.white : PDColors.textMuted,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : PDColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
