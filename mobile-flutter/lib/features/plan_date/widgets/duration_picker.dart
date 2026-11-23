// ─────────────────────────────────────────────────────────────────────────────
// Duration Picker
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../models/plan_date_model.dart';
import '../plan_date_theme.dart';

class DurationPicker extends StatelessWidget {
  final int durationMin;
  final DateMode mode;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final ValueChanged<int> onQuickSelect;

  const DurationPicker({
    super.key,
    required this.durationMin,
    required this.mode,
    required this.onIncrement,
    required this.onDecrement,
    required this.onQuickSelect,
  });

  @override
  Widget build(BuildContext context) {
    final quickOptions = mode == DateMode.virtual
        ? const [30, 60, 90, 120]
        : const [60, 90, 120, 180];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PDColors.card,
        borderRadius: BorderRadius.circular(PDRadius.card),
        border: Border.all(color: PDColors.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ctrlBtn(
                icon: Icons.remove,
                label: 'Decrease duration',
                onTap: durationMin > 15 ? onDecrement : null,
              ),
              const SizedBox(width: 20),
              Column(
                children: [
                  Text(
                    _formatDuration(durationMin),
                    style: PDTextStyles.heading.copyWith(
                      fontSize: 28,
                      color: PDColors.textAccent,
                    ),
                  ),
                  Text('duration', style: PDTextStyles.muted),
                ],
              ),
              const SizedBox(width: 20),
              _ctrlBtn(
                icon: Icons.add,
                label: 'Increase duration',
                onTap: durationMin < 240 ? onIncrement : null,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            children: quickOptions.map((min) {
              final selected = durationMin == min;
              return Semantics(
                label: '${_formatDuration(min)} quick select',
                selected: selected,
                button: true,
                child: GestureDetector(
                  onTap: () => onQuickSelect(min),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: selected ? PDGradients.primary : null,
                      color: selected ? null : PDColors.inputFill,
                      borderRadius: BorderRadius.circular(PDRadius.chip),
                      border: Border.all(
                        color: selected ? Colors.transparent : PDColors.cardBorder,
                      ),
                    ),
                    child: Text(
                      _formatDuration(min),
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : PDColors.textMuted,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _ctrlBtn({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    final enabled = onTap != null;
    return Semantics(
      label: label,
      button: true,
      enabled: enabled,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PDRadius.avatar),
        child: Container(
          width: kMinTouchTarget,
          height: kMinTouchTarget,
          decoration: BoxDecoration(
            gradient: enabled ? PDGradients.primary : null,
            color: enabled ? null : PDColors.disabledFill,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: enabled ? Colors.white : PDColors.textMuted.withValues(alpha: 0.4),
            size: 22,
          ),
        ),
      ),
    );
  }

  String _formatDuration(int min) {
    if (min < 60) return '${min}m';
    final h = min ~/ 60;
    final m = min % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }
}

