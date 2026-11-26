import 'package:flutter/material.dart';
import '../screens/home/daily_streak_screen.dart';

class TopNavBar extends StatelessWidget {
  final int rubyBalance;
  final int streakDays;
  final VoidCallback onOpenRubies;
  final VoidCallback? onOpenStreak;
  final VoidCallback onOpenNotifications;
  final VoidCallback? onLogoTap;

  const TopNavBar({
    super.key,
    required this.rubyBalance,
    required this.streakDays,
    required this.onOpenRubies,
    this.onOpenStreak,
    required this.onOpenNotifications,
    this.onLogoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF111318),
        border: Border(
          bottom: BorderSide(color: Color(0x14FFFFFF), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: YoUnMe App Icon + Name
          GestureDetector(
            onTap: onLogoTap,
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF43F5E), Color(0xFFE11D48)],
                    ),
                    border: Border.all(color: const Color(0x4DFF8DA1)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x73FF4D88),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/younme-logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'YoUnMe',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFF8FAFC),
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),

          // Right: 1. Rubies Pill | 2. Streak Flame Pill | 3. Bell Icon
          Row(
            children: [
              // 1. Rubies Pill
              GestureDetector(
                onTap: onOpenRubies,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF191C24),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0x14FFFFFF)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.diamond, size: 14, color: Color(0xFFF43F5E)),
                      const SizedBox(width: 5),
                      Text(
                        '$rubyBalance',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFF8FAFC),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // 2. Daily Streak Pill
              GestureDetector(
                onTap: () {
                  if (onOpenStreak != null) {
                    onOpenStreak!();
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StreakPage(currentStreak: streakDays),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xF2191C24),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0x80F97316), width: 1.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x40F97316),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        size: 17,
                        color: Color(0xFFF97316),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$streakDays',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // 3. Notifications Bell
              GestureDetector(
                onTap: onOpenNotifications,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF191C24),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0x14FFFFFF)),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.notifications_none,
                        size: 17,
                        color: Color(0xFF94A3B8),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF43F5E),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
