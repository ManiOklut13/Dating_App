import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../features/plan_date/plan_date_theme.dart';
import "date_plan_models.dart";
import "after_the_date_screen.dart";

/// Confirmation screen shown after a date has been proposed.
class DateProposedScreen extends StatelessWidget {
  const DateProposedScreen({
    super.key,
    required this.partnerName,
    required this.dateTitle,
    required this.dateTime,
    required this.duration,
    required this.splitLabel,
    required this.coinCost,
    required this.proposalNotes,
    required this.partnerNotes,
    required this.todos,
    this.mode = DateMode.virtual,
  });

  final String partnerName;
  final String dateTitle;
  final DateTime dateTime;
  final int duration;
  final String splitLabel;
  final int coinCost;
  final String proposalNotes;
  final String partnerNotes;
  final List<dynamic> todos;
  final DateMode mode;

  @override
  Widget build(BuildContext context) {
    final whenText = DateFormat('MMMM d, yyyy ·\nh:mm a').format(dateTime);

    return Scaffold(
      backgroundColor: PDColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            children: [
              const SizedBox(height: 12),
              _HeroBadge(),
              const SizedBox(height: 20),
              const Text(
                'Date proposed!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: PDColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$partnerName will get your invite in chat. You\'ll be notified as soon as she responds.',
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(
                  color: PDColors.textMuted,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              _SummaryCard(
                dateTitle: dateTitle,
                partnerName: partnerName,
                whenText: whenText,
                duration: duration,
                splitLabel: splitLabel,
                coinCost: coinCost,
              ),
              const Spacer(),
              _PrimaryButton(
                label: 'Back to chat',
                onPressed: () {
                  final nav = Navigator.of(context);
                  nav.pop();
                  if (nav.canPop()) nav.pop();
                },
              ),
              const SizedBox(height: 12),
              _SecondaryButton(
                label: 'View After the Date',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AfterTheDateScreen(
                        partnerName: partnerName,
                        dateTitle: dateTitle,
                        dateTime: dateTime,
                        durationMinutes: duration,
                        mode: mode,
                        splitLabel: splitLabel,
                        coinCost: coinCost,
                        rating: 0, // not yet rated
                        photos: const [], // no photos yet
                        highlights: const [], // no highlights selected yet
                        memoryNote: proposalNotes, // reuse proposal notes as memory note placeholder
                        shareToggle: true, // sharing on by default
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      height: 88,
      child: CustomPaint(
        painter: _DashedCirclePainter(),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.translate(
                offset: const Offset(-10, 0),
                child: const Icon(Icons.favorite, color: Color(0xFFFF4D8D), size: 40),
              ),
              Transform.translate(
                offset: const Offset(10, 6),
                child: const Icon(Icons.favorite, color: Color(0xFF8B5CF6), size: 36),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE9297B).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    final radius = size.width / 2 - 2;
    final circumference = 2 * 3.1415926535 * radius;
    final dashCount = (circumference / (dashWidth + dashSpace)).floor();
    for (int i = 0; i < dashCount; i++) {
      final startAngle = (i * (dashWidth + dashSpace)) / radius;
      final sweep = dashWidth / radius;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: radius),
        startAngle,
        sweep,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.dateTitle,
    required this.partnerName,
    required this.whenText,
    required this.duration,
    required this.splitLabel,
    required this.coinCost,
  });

  final String dateTitle;
  final String partnerName;
  final String whenText;
  final int duration;
  final String splitLabel;
  final int coinCost;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PDColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PDColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: PDColors.gradientPink.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.calendar_month, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateTitle,
                      style: const TextStyle(
                        color: PDColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Virtual Date with $partnerName',
                      style: const TextStyle(
                        color: PDColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: PDColors.divider, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DetailCell(label: 'WHEN', value: whenText),
              ),
              Expanded(
                child: _DetailCell(label: 'DURATION', value: '$duration min'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DetailCell(label: 'SPLIT BILL', value: splitLabel),
              ),
              Expanded(
                child: _DetailCell(
                  label: 'COST',
                  value: '$coinCost coins',
                  leadingIcon: Icons.monetization_on,
                  iconColor: const Color(0xFFFFC94D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailCell extends StatelessWidget {
  const _DetailCell({
    required this.label,
    required this.value,
    this.leadingIcon,
    this.iconColor,
  });

  final String label;
  final String value;
  final IconData? leadingIcon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: PDColors.textMuted,
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            if (leadingIcon != null) ...[
              Icon(leadingIcon, size: 16, color: iconColor ?? PDColors.textPrimary),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                value,
                style: const TextStyle(
                  color: PDColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 54,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFE9297B),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 54,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF181222),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2F2640)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}