import 'package:flutter/material.dart';
import '../screens/home/daily_streak_screen.dart';

class StreakTrackerModal extends StatefulWidget {
  final int streakDays;
  final bool hasClaimed;
  final VoidCallback onClaimBonus;
  final VoidCallback onClose;

  const StreakTrackerModal({
    super.key,
    this.streakDays = 4,
    required this.hasClaimed,
    required this.onClaimBonus,
    required this.onClose,
  });

  @override
  State<StreakTrackerModal> createState() => _StreakTrackerModalState();
}

class _StreakTrackerModalState extends State<StreakTrackerModal> {
  @override
  Widget build(BuildContext context) {
    final int rewardAmount = widget.streakDays * 10;
    return Material(
      color: const Color(0xB806080E),
      child: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: const Color(0xF212151E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0x4DF43F5E)),
            boxShadow: const [
              BoxShadow(
                color: Color(0xA6000000),
                blurRadius: 32,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: widget.onClose,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: const Color(0x14FFFFFF),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0x1FFFFFFF)),
                    ),
                    child: const Icon(Icons.close, size: 14, color: Color(0xFF94A3B8)),
                  ),
                ),
              ),
              const Icon(
                Icons.local_fire_department,
                size: 36,
                color: Color(0xFFF97316),
              ),
              const SizedBox(height: 4),
              Text(
                'Day ${widget.streakDays} Streak! 🔥',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Keep logging in daily to claim free Rubies!',
                style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  final day = index + 1;
                  final isCurrent = day == widget.streakDays;
                  final isCompleted = day <= widget.streakDays;
                  return Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.local_fire_department_rounded,
                            size: 32,
                            color: isCompleted
                                ? (isCurrent ? const Color(0xFFFFD166) : const Color(0xFFF43F5E))
                                : const Color(0x26FFFFFF),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '$day',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: isCompleted
                                    ? (isCurrent ? const Color(0xFF9B1D20) : Colors.white)
                                    : const Color(0x66FFFFFF),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isCurrent ? 'Today' : 'D$day',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          color: isCurrent ? Colors.white : const Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '+${day * 10}💎',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: isCurrent
                              ? const Color(0xFFFFD700)
                              : isCompleted
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF475569),
                        ),
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 16),
              widget.hasClaimed
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: const Color(0x2622C55E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0x5922C55E)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_outline, size: 15, color: Color(0xFF4ADE80)),
                          const SizedBox(width: 6),
                          Text(
                            '+$rewardAmount Rubies Credited!',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF4ADE80),
                            ),
                          ),
                        ],
                      ),
                    )
                  : GestureDetector(
                      onTap: widget.onClaimBonus,
                      child: Container(
                        width: double.infinity,
                        height: 38,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF43F5E), Color(0xFFE11D48)],
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x59F43F5E),
                              blurRadius: 12,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.diamond, size: 14, color: Color(0xFFFFD700)),
                            const SizedBox(width: 6),
                            Text(
                              'Claim Day ${widget.streakDays} Bonus (+$rewardAmount Rubies)',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StreakPage(currentStreak: widget.streakDays),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0x1AFFFFFF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0x33FF6B6B)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.stars_rounded, size: 16, color: Color(0xFFFECA57)),
                      SizedBox(width: 8),
                      Text(
                        'Spin Daily Lucky Wheel 🎰',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFF8DA1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
