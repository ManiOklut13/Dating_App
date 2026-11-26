import 'package:flutter/material.dart';
import '../models/discovery_connect_models.dart';
import '../data/profiles_data.dart';

class FullProfileModal extends StatelessWidget {
  final CandidateCard profile;
  final VoidCallback? onLike;
  final VoidCallback? onPass;
  final VoidCallback? onMegaCrush;
  final VoidCallback? onDirectMessage;

  const FullProfileModal({
    super.key,
    required this.profile,
    this.onLike,
    this.onPass,
    this.onMegaCrush,
    this.onDirectMessage,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF131620),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: Color(0x33FFFFFF))),
            boxShadow: [
              BoxShadow(
                color: Colors.black87,
                blurRadius: 30,
                offset: Offset(0, -8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Top drag pill
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0x40FFFFFF),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Large Hero Photo Box
                      Container(
                        height: 340,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0x26FFFFFF)),
                        ),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: SafeProfileImage(
                                imageUrl: profile.photoUrls.first,
                                borderRadius: BorderRadius.circular(19),
                              ),
                            ),
                            Positioned(
                              top: 14,
                              left: 14,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xD90F1117),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: const Color(0x33FFFFFF)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF22C55E),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      profile.lastActive,
                                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 14,
                              right: 14,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xE6161923),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0x4DF43F5E)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.local_fire_department, size: 14, color: Color(0xFFF97316)),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${profile.vibeScore}% Vibe Match',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFFF8DA1)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Name, Age, Verified badge & Location
                      Row(
                        children: [
                          Text(
                            '${profile.nickname}, ${profile.age}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.verified, size: 20, color: Color(0xFF38BDF8)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '📍 ${profile.city} • ${profile.distanceKm} km away',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                      ),
                      const SizedBox(height: 14),

                      // About Me Bio
                      const Text(
                        'About Me',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFFFF8DA1)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        profile.bio,
                        style: const TextStyle(fontSize: 13.5, color: Color(0xFFCBD5E1), height: 1.45),
                      ),
                      const SizedBox(height: 18),

                      // Relationship Preference
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF191C24),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0x1FFFFFFF)),
                        ),
                        child: Row(
                          children: [
                            const Text('💍', style: TextStyle(fontSize: 20)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Looking For', style: TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8))),
                                  Text(
                                    profile.preference,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Passions & Shared Interests
                      const Text(
                        'Passions & Shared Interests',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFFFF8DA1)),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: profile.sharedInterests.map((interest) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0x2BF43F5E),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: const Color(0x66F43F5E)),
                            ),
                            child: Text(
                              interest,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFFF8DA1)),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Fixed Bottom Action Dock in Full Profile Modal
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _modalAction(Icons.close, const Color(0xFFEF4444), () {
                            Navigator.pop(context);
                            onPass?.call();
                          }),
                          _modalAction(Icons.local_fire_department, const Color(0xFFF97316), () {
                            Navigator.pop(context);
                            onMegaCrush?.call();
                          }, isLarge: true),
                          _modalAction(Icons.favorite, const Color(0xFF22C55E), () {
                            Navigator.pop(context);
                            onLike?.call();
                          }),
                          _modalAction(Icons.chat_bubble_outline, const Color(0xFF38BDF8), () {
                            Navigator.pop(context);
                            onDirectMessage?.call();
                          }),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _modalAction(IconData icon, Color color, VoidCallback onTap, {bool isLarge = false}) {
    final double size = isLarge ? 58 : 46;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF191C24),
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.6), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: isLarge ? 28 : 22),
      ),
    );
  }
}
