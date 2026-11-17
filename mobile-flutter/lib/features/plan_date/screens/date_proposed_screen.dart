// ─────────────────────────────────────────────────────────────────────────────
// Date Proposed Screen
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/plan_date_model.dart';
import '../plan_date_theme.dart';
import '../widgets/gradient_text.dart';
import 'after_date_memories_screen.dart';

class DateProposedScreen extends StatelessWidget {
  final PlanDate plan;

  const DateProposedScreen({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEEE, MMM d').format(plan.startAt);
    final timeStr = DateFormat('hh:mm a').format(plan.startAt);

    return Scaffold(
      backgroundColor: PDColors.bg,
      body: SafeArea(
        child: Stack(
          children: [
            const _BgGlows(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  // ── Success icon ─────────────────────────────────────────
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      gradient: PDGradients.primary,
                      shape: BoxShape.circle,
                      boxShadow: PDShadows.ctaGlow,
                    ),
                    child: const Icon(
                      Icons.calendar_month_rounded,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Date ',
                        style: PDTextStyles.heading.copyWith(fontSize: 26),
                      ),
                      GradientText(
                        'Proposed!',
                        style: PDTextStyles.heading.copyWith(fontSize: 26),
                        gradient: PDGradients.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Your invitation has been sent.\nWaiting for partner\'s reply.',
                    textAlign: TextAlign.center,
                    style: PDTextStyles.muted,
                  ),
                  const SizedBox(height: 32),
                  // ── Plan recap card ──────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: PDColors.card,
                      borderRadius: BorderRadius.circular(PDRadius.card),
                      border: Border.all(color: PDColors.cardBorder),
                    ),
                    child: Column(
                      children: [
                        _row(Icons.person_outline, 'Partner', plan.partnerId),
                        _divider(),
                        _row(Icons.videocam_outlined,
                          'Mode',
                          plan.mode == DateMode.virtual ? 'Virtual' : 'Offline'),
                        _divider(),
                        _row(Icons.event, 'Date', dateStr),
                        _divider(),
                        _row(Icons.access_time_rounded, 'Time', timeStr),
                        _divider(),
                        _row(Icons.timer_outlined, 'Duration', '${plan.durationMin} min'),
                        _divider(),
                        _row(Icons.monetization_on_rounded, 'Coins spent',
                          '${plan.coins}', valueColor: Colors.amber),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // ── Status pill ──────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: PDColors.textSuccess.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(PDRadius.chip),
                      border: Border.all(
                        color: PDColors.textSuccess.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_outline,
                            color: PDColors.textSuccess, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Pending partner acceptance',
                          style: PDTextStyles.body.copyWith(color: PDColors.textSuccess),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // ── Actions ──────────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: PDColors.textViolet,
                            side: const BorderSide(color: PDColors.cardBorder),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(PDRadius.control),
                            ),
                          ),
                          child: const Text('Back to Chat'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AfterDateMemoriesScreen(
                                dateId: plan.id,
                                mode: plan.mode,
                              ),
                            ),
                          ),
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: PDGradients.primary,
                              borderRadius: BorderRadius.circular(PDRadius.control),
                              boxShadow: PDShadows.ctaGlow,
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'Add Memories',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: PDColors.textViolet),
          const SizedBox(width: 10),
          Text(label, style: PDTextStyles.muted),
          const Spacer(),
          Text(
            value,
            style: PDTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor ?? PDColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(color: PDColors.divider, height: 1);
}

class _BgGlows extends StatelessWidget {
  const _BgGlows();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: -60,
              left: -80,
              width: 320,
              height: 320,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    colors: [PDColors.glowPink, Colors.transparent],
                    radius: 0.8,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

