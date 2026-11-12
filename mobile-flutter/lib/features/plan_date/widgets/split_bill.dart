// ─────────────────────────────────────────────────────────────────────────────
// Split Bill Widget
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../models/plan_date_model.dart';
import '../plan_date_theme.dart';

class SplitBillWidget extends StatelessWidget {
  final int proposerPct;
  final ValueChanged<int> onPresetSelected;
  final ValueChanged<int> onSliderChanged;

  const SplitBillWidget({
    super.key,
    required this.proposerPct,
    required this.onPresetSelected,
    required this.onSliderChanged,
  });

  @override
  Widget build(BuildContext context) {
    final partnerPct = 100 - proposerPct;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PDColors.card,
        borderRadius: BorderRadius.circular(PDRadius.card),
        border: Border.all(color: PDColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Two-colour split bar ──────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 14,
              child: Row(
                children: [
                  Flexible(
                    flex: proposerPct,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: PDGradients.primary,
                      ),
                    ),
                  ),
                  Flexible(
                    flex: partnerPct,
                    child: Container(
                      color: PDColors.textViolet.withValues(alpha: 0.35),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          // ── Percentage labels ─────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('You (Proposer)', style: PDTextStyles.muted),
                    const SizedBox(height: 2),
                    Text(
                      '$proposerPct%',
                      style: PDTextStyles.heading.copyWith(
                        color: PDColors.textAccent,
                        fontSize: 26,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Partner', style: PDTextStyles.muted),
                    const SizedBox(height: 2),
                    Text(
                      '$partnerPct%',
                      style: PDTextStyles.heading.copyWith(
                        color: PDColors.textViolet,
                        fontSize: 26,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // ── Presets ───────────────────────────────────────────────────────
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(SplitBill.presets.length, (i) {
              final preset = SplitBill.presets[i];
              final label = SplitBill.presetLabels[i];
              final selected = proposerPct == preset.proposerPct;
              return Semantics(
                label: '$label split preset',
                selected: selected,
                button: true,
                child: GestureDetector(
                  onTap: () => onPresetSelected(preset.proposerPct),
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
                      label,
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
            }),
          ),
        ],
      ),
    );
  }
}

