import 'package:flutter/material.dart';
import '../../models/discovery_connect_models.dart';
import '../../data/profiles_data.dart';

class FullProfileScreen extends StatefulWidget {
  final CandidateCard profile;
  final VoidCallback? onLike;
  final VoidCallback? onPass;
  final VoidCallback? onMegaCrush;
  final VoidCallback? onDirectMessage;

  const FullProfileScreen({
    super.key,
    required this.profile,
    this.onLike,
    this.onPass,
    this.onMegaCrush,
    this.onDirectMessage,
  });

  @override
  State<FullProfileScreen> createState() => _FullProfileScreenState();
}

class _FullProfileScreenState extends State<FullProfileScreen> {
  int _activePhotoIndex = 0;

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;

    return Scaffold(
      backgroundColor: const Color(0xFF0D070C),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF140A12),
                border: Border(bottom: BorderSide(color: Color(0xFF2E1E2B))),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0x1AFFFFFF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0x26FFFFFF)),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    '${profile.nickname}\'s Profile',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Large Hero Photo Carousel
                    Container(
                      height: 360,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0x33FF4D88)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x40000000),
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: SafeProfileImage(
                              imageUrl: profile.photoUrls[_activePhotoIndex % profile.photoUrls.length],
                              borderRadius: BorderRadius.circular(21),
                            ),
                          ),

                          // Top Multi-photo segment indicator
                          if (profile.photoUrls.length > 1)
                            Positioned(
                              top: 12,
                              left: 14,
                              right: 14,
                              child: Row(
                                children: List.generate(profile.photoUrls.length, (idx) {
                                  final active = idx == _activePhotoIndex;
                                  return Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(() => _activePhotoIndex = idx),
                                      child: Container(
                                        height: 3.5,
                                        margin: const EdgeInsets.symmetric(horizontal: 2),
                                        decoration: BoxDecoration(
                                          color: active ? Colors.white : const Color(0x66FFFFFF),
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),

                          // Active Status pill
                          Positioned(
                            top: 26,
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

                          // Vibe Match badge
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

                    // Gallery Thumbnails
                    if (profile.photoUrls.length > 1)
                      Row(
                        children: List.generate(profile.photoUrls.length, (idx) {
                          final active = idx == _activePhotoIndex;
                          return GestureDetector(
                            onTap: () => setState(() => _activePhotoIndex = idx),
                            child: Container(
                              width: 56,
                              height: 56,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: active ? const Color(0xFFFF4D88) : const Color(0x26FFFFFF),
                                  width: active ? 2 : 1,
                                ),
                              ),
                              child: SafeProfileImage(
                                imageUrl: profile.photoUrls[idx],
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        }),
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
                    const SizedBox(height: 16),

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
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),

            // Fixed Bottom Action Dock
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: const BoxDecoration(
                color: Color(0xFF140A12),
                border: Border(top: BorderSide(color: Color(0xFF2E1E2B))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _dockAction(Icons.close, const Color(0xFFEF4444), () {
                    Navigator.pop(context);
                    widget.onPass?.call();
                  }),
                  _dockAction(Icons.local_fire_department, const Color(0xFFF97316), () {
                    Navigator.pop(context);
                    widget.onMegaCrush?.call();
                  }, isLarge: true),
                  _dockAction(Icons.favorite, const Color(0xFF22C55E), () {
                    Navigator.pop(context);
                    widget.onLike?.call();
                  }),
                  _dockAction(Icons.chat_bubble_outline, const Color(0xFF38BDF8), () {
                    Navigator.pop(context);
                    widget.onDirectMessage?.call();
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dockAction(IconData icon, Color color, VoidCallback onTap, {bool isLarge = false}) {
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
