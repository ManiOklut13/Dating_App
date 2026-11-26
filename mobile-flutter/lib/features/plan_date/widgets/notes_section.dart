// ─────────────────────────────────────────────────────────────────────────────
// Notes Section (Virtual-only) — Proposal Notes + Partner Notes
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../plan_date_theme.dart';

class NotesSection extends StatelessWidget {
  final String proposalNote;
  final String partnerNote;
  final ValueChanged<String> onProposalChanged;
  final ValueChanged<String> onPartnerChanged;

  const NotesSection({
    super.key,
    required this.proposalNote,
    required this.partnerNote,
    required this.onProposalChanged,
    required this.onPartnerChanged,
  });

  @override
  Widget build(BuildContext context) {
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
          Text('Notes', style: PDTextStyles.sectionTitle),
          const SizedBox(height: 14),
          _noteField(
            label: 'Proposal Notes',
            hint: 'Share what you have in mind for this date...',
            value: proposalNote,
            onChanged: onProposalChanged,
          ),
          const SizedBox(height: 12),
          _noteField(
            label: 'Partner Notes',
            hint: 'Space for your partner\'s suggestions...',
            value: partnerNote,
            onChanged: onPartnerChanged,
          ),
        ],
      ),
    );
  }

  Widget _noteField({
    required String label,
    required String hint,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: PDTextStyles.muted),
            Text(
              '${value.length}/200',
              style: PDTextStyles.muted.copyWith(
                color: value.length > 180
                    ? PDColors.textAccent
                    : PDColors.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: PDColors.inputFill,
            borderRadius: BorderRadius.circular(PDRadius.input),
            border: Border.all(color: PDColors.inputBorder),
          ),
          child: TextField(
            maxLength: 200,
            maxLines: 4,
            minLines: 3,
            style: PDTextStyles.body,
            onChanged: onChanged,
            buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
                const SizedBox.shrink(),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: PDColors.textMuted, fontSize: 13),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ),
      ],
    );
  }
}

