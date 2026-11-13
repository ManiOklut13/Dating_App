// ─────────────────────────────────────────────────────────────────────────────
// About Plan a Date — 4 numbered steps
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../plan_date_theme.dart';

class AboutPlanDate extends StatelessWidget {
  const AboutPlanDate({super.key});

  static const _steps = [
    (icon: Icons.send_rounded, title: 'Propose', body: 'Send a date invitation to your partner.'),
    (icon: Icons.reply_rounded, title: 'Partner replies', body: 'They accept or suggest changes.'),
    (icon: Icons.videocam_rounded, title: 'Join the call or Meet up', body: 'Start the date at the scheduled time.'),
    (icon: Icons.favorite_rounded, title: 'After the date', body: 'Rate, tag photos and save memories.'),
  ];

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
          Text('How it works', style: PDTextStyles.sectionTitle),
          const SizedBox(height: 14),
          ...List.generate(_steps.length, (i) => _buildStep(i, _steps[i])),
        ],
      ),
    );
  }

  Widget _buildStep(int index, ({IconData icon, String title, String body}) step) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number circle
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: PDGradients.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step.title, style: PDTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(step.body, style: PDTextStyles.muted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

