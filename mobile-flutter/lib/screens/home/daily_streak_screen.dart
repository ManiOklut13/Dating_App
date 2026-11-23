import 'dart:math';
import 'package:flutter/material.dart';

class StreakSessionManager {
  // Resets automatically when the app is killed from background and reopened
  static bool _hasShownInCurrentSession = false;

  static bool shouldShowStreakPopup() {
    if (_hasShownInCurrentSession) {
      return false;
    }
    _hasShownInCurrentSession = true;
    return true;
  }

  static void resetSession() {
    _hasShownInCurrentSession = false;
  }
}

class DailyStreakScreen extends StatelessWidget {
  final int currentStreak;
  const DailyStreakScreen({super.key, this.currentStreak = 4});

  @override
  Widget build(BuildContext context) {
    return StreakPage(currentStreak: currentStreak);
  }
}

class StreakPage extends StatefulWidget {
  final int currentStreak;
  const StreakPage({super.key, this.currentStreak = 4});

  @override
  State<StreakPage> createState() => _StreakPageState();
}

class _StreakPageState extends State<StreakPage> with SingleTickerProviderStateMixin {
  late AnimationController _wheelController;
  double _currentAngle = 0.0;
  double _targetAngle = 0.0;
  bool _hasSpunToday = false;
  String? _wonReward;

  final List<Map<String, dynamic>> _rewards = [
    {'label': '1 Super Like', 'detail': 'Stand out instantly to your crush', 'color': const Color(0xFFFF6B6B)},
    {'label': '2x Profile Boost', 'detail': 'Top profile in your city for 30 mins', 'color': const Color(0xFFFF9F43)},
    {'label': '50 Coins', 'detail': 'Use coins to unlock special gifts', 'color': const Color(0xFFFECA57)},
    {'label': 'Free Rewind', 'detail': 'Undo your last accidental left swipe', 'color': const Color(0xFF54A0FF)},
    {'label': '3 Super Likes', 'detail': 'Triple your chances of matching', 'color': const Color(0xFF5F27CD)},
    {'label': '100 Coins', 'detail': 'Bonus coins added to your wallet', 'color': const Color(0xFF1DD1A1)},
  ];

  @override
  void initState() {
    super.initState();
    _wheelController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addListener(() {
        setState(() {
          final curveValue = Curves.easeOutCubic.transform(_wheelController.value);
          _currentAngle = _targetAngle * curveValue;
        });
      });

    _wheelController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _calculateWinner();
      }
    });
  }

  void _spinWheel() {
    if (_wheelController.isAnimating || _hasSpunToday) return;

    final random = Random();
    // Spin at least 5 full rotations + random angle
    final extraSpins = 5 * 2 * pi;
    final randomOffset = random.nextDouble() * 2 * pi;
    _targetAngle = extraSpins + randomOffset;

    _wheelController.forward(from: 0.0);
  }

  void _calculateWinner() {
    final normalizedAngle = _currentAngle % (2 * pi);
    final sliceAngle = (2 * pi) / _rewards.length;
    final pointerAngle = (3 * pi / 2 - normalizedAngle) % (2 * pi);
    final winningIndex = (pointerAngle ~/ sliceAngle) % _rewards.length;

    final wonItem = _rewards[winningIndex];

    setState(() {
      _hasSpunToday = true;
      _wonReward = wonItem['label'] as String;
    });

    // Trigger the pop-out blast celebration dialog
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Reward Won',
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, anim1, anim2) {
        return _RewardBlastDialog(
          rewardTitle: wonItem['label'] as String,
          rewardDetail: wonItem['detail'] as String,
          accentColor: wonItem['color'] as Color,
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.elasticOut),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    );
  }

  @override
  void dispose() {
    _wheelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Daily Streak & Rewards',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Streak Header Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF512F), Color(0xFFDD2476)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    '${widget.currentStreak} Day Streak!',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Check in daily to keep your flame alive & unlock spins',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 20),

                  // 2. 7-Day Fire Badges Row (Replaces numbered circles)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (index) {
                      final dayNumber = index + 1;
                      final isCompleted = dayNumber <= widget.currentStreak;
                      final isToday = dayNumber == widget.currentStreak;

                      return _FireDayBadge(
                        day: dayNumber,
                        isCompleted: isCompleted,
                        isToday: isToday,
                      );
                    }),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 3. Daily Spin Wheel Section
            const Text(
              'Daily Lucky Spin',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _hasSpunToday
                  ? 'You won: $_wonReward!'
                  : 'Spin once every 24 hours for free dating perks',
              style: TextStyle(
                color: _hasSpunToday ? const Color(0xFFFECA57) : Colors.grey[400],
                fontSize: 14,
                fontWeight: _hasSpunToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 24),

            // Wheel + Top Pointer Stack
            Stack(
              alignment: Alignment.topCenter,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Transform.rotate(
                    angle: _currentAngle,
                    child: SizedBox(
                      width: 260,
                      height: 260,
                      child: CustomPaint(
                        painter: _WheelPainter(rewards: _rewards),
                      ),
                    ),
                  ),
                ),
                // Top Pointer Triangle
                const Icon(
                  Icons.arrow_drop_down,
                  size: 48,
                  color: Colors.white,
                ),
                // Center Spin Button
                Positioned(
                  top: 112,
                  child: GestureDetector(
                    onTap: _spinWheel,
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: _hasSpunToday ? Colors.grey[800] : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(color: Colors.black45, blurRadius: 8),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _hasSpunToday ? 'DONE' : 'SPIN',
                        style: TextStyle(
                          color: _hasSpunToday ? Colors.white54 : Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // 4. Spin Wheel Reward Details Breakdown
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Reward Details & Odds',
                style: TextStyle(
                  color: Colors.grey[200],
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ..._rewards.map((reward) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (reward['color'] as Color).withOpacity(0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: reward['color'] as Color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reward['label'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            reward['detail'] as String,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// Custom Widget: Number inside a Fire Icon for Days 1 to 7
class _FireDayBadge extends StatelessWidget {
  final int day;
  final bool isCompleted;
  final bool isToday;

  const _FireDayBadge({
    required this.day,
    required this.isCompleted,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.local_fire_department_rounded,
              size: 42,
              color: isCompleted ? const Color(0xFFFFD166) : Colors.black38,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: isCompleted ? const Color(0xFF9B1D20) : Colors.white60,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          isToday ? 'Today' : 'D$day',
          style: TextStyle(
            fontSize: 11,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            color: isToday ? Colors.white : Colors.white70,
          ),
        ),
      ],
    );
  }
}

// Custom Painter for the 6-Slice Spin Wheel
class _WheelPainter extends CustomPainter {
  final List<Map<String, dynamic>> rewards;
  _WheelPainter({required this.rewards});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final sliceAngle = (2 * pi) / rewards.length;

    final paint = Paint()..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white24
      ..strokeWidth = 2;

    for (int i = 0; i < rewards.length; i++) {
      final startAngle = i * sliceAngle;
      paint.color = rewards[i]['color'] as Color;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sliceAngle,
        true,
        paint,
      );
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sliceAngle,
        true,
        borderPaint,
      );

      // Draw Slice Label
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(startAngle + sliceAngle / 2);

      final textPainter = TextPainter(
        text: TextSpan(
          text: rewards[i]['label'] as String,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: radius * 0.55);

      textPainter.paint(canvas, Offset(radius * 0.36, -textPainter.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Pop-out blast celebration dialog with elastic bounce animation
class _RewardBlastDialog extends StatelessWidget {
  final String rewardTitle;
  final String rewardDetail;
  final Color accentColor;

  const _RewardBlastDialog({
    required this.rewardTitle,
    required this.rewardDetail,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E24),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: accentColor.withOpacity(0.6), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.35),
              blurRadius: 30,
              spreadRadius: 2,
            ),
            const BoxShadow(
              color: Colors.black54,
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Glowing Trophy / Star Icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: accentColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.4),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Icon(
                Icons.emoji_events_rounded,
                size: 38,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Reward Unlocked! 🎉',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: accentColor.withOpacity(0.3)),
              ),
              child: Text(
                rewardTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              rewardDetail,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 13.5,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accentColor, accentColor.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Collect Reward',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
