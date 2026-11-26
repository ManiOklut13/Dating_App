import 'package:flutter/material.dart';
import '../data/profiles_data.dart';

class MatchModal extends StatelessWidget {
  final String matchedName;
  final String matchedAvatar;
  final String userAvatar;
  final VoidCallback? onStartChat;
  final VoidCallback? onKeepSwiping;

  const MatchModal({
    super.key,
    this.matchedName = 'Ananya',
    this.matchedAvatar = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=800&q=80',
    this.userAvatar = 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=800&q=80',
    this.onStartChat,
    this.onKeepSwiping,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        color: const Color(0xE605070D),
        alignment: Alignment.center,
        child: Container(
          width: 320,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
          decoration: BoxDecoration(
            color: const Color(0xF2161923),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFFF4D88), width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x99FF4D88),
                blurRadius: 36,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('✨', style: TextStyle(fontSize: 28)),
              const SizedBox(height: 6),
              const Text(
                "It's a Vibe Match! 🎉",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'You and $matchedName have a 98% compatibility vibe rating.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12.5, color: Color(0xFFCBD5E1), height: 1.4),
              ),
              const SizedBox(height: 22),

              // Overlapping Dual Avatars
              SizedBox(
                width: 170,
                height: 90,
                child: Stack(
                  children: [
                    Positioned(
                      left: 10,
                      top: 0,
                      child: Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF38BDF8), width: 2.5),
                          boxShadow: const [
                            BoxShadow(color: Color(0x6638BDF8), blurRadius: 16),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(42),
                          child: SafeProfileImage(imageUrl: userAvatar, width: 84, height: 84),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      top: 0,
                      child: Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFFF4D88), width: 2.5),
                          boxShadow: const [
                            BoxShadow(color: Color(0x66FF4D88), blurRadius: 16),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(42),
                          child: SafeProfileImage(imageUrl: matchedAvatar, width: 84, height: 84),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 72,
                      top: 28,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFF161923),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: const Icon(Icons.favorite, size: 16, color: Color(0xFFFF4D88)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Send Direct Message Button
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  onStartChat?.call();
                },
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF8DA1), Color(0xFFFF4D88)],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x66FF4D88),
                        blurRadius: 16,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Send Message Now',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Keep Swiping Button
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  onKeepSwiping?.call();
                },
                child: Container(
                  width: double.infinity,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0x14FFFFFF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0x1FFFFFFF)),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Keep Swiping',
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)),
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
