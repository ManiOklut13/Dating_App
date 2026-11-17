import 'package:flutter/material.dart';

class MegaCrushCelebration extends StatelessWidget {
  final String recipientName;
  final VoidCallback? onDismiss;

  const MegaCrushCelebration({
    super.key,
    this.recipientName = 'Ananya',
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        color: const Color(0xE605070D),
        alignment: Alignment.center,
        child: Container(
          width: 310,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
          decoration: BoxDecoration(
            color: const Color(0xF2161923),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFFF4D88), width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x99FF4D88),
                blurRadius: 40,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF4D88), Color(0xFFF97316)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x80F97316),
                      blurRadius: 24,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.local_fire_department, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text(
                'MEGA CRUSH! 💖⚡',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'High-Priority Match Dispatched',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFFD700),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sent to $recipientName ✨\nYour profile will appear directly at the top of their admirers stack!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF94A3B8),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
