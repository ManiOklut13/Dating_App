import 'package:flutter/material.dart';
import '../models/discovery_connect_models.dart';

/// Stores a swiped card's index and exit direction so Revert can slide it back in.
class DiscoverySwipeHistoryEntry {
  final int profileIndex;
  final Offset exitOffset;
  final bool wasLiked;

  const DiscoverySwipeHistoryEntry({
    required this.profileIndex,
    required this.exitOffset,
    required this.wasLiked,
  });
}

/// Converts a discovery map entry into a [CandidateCard] for modals/screens.
CandidateCard candidateCardFromDiscoveryMap(
  Map<String, dynamic> profile,
  int index,
) {
  final roleParts = (profile['role'] as String? ?? 'Hyderabad').split('•');
  final city = roleParts.length > 1
      ? roleParts.last.trim()
      : roleParts.first.trim();
  final distanceText = profile['distance'] as String? ?? '3 km away';
  final parsedDist = double.tryParse(
        RegExp(r'[\d.]+').firstMatch(distanceText)?.group(0) ?? '',
      ) ??
      ((profile['distanceKm'] as num?)?.toDouble() ?? 3.0);
  final imageUrl = profile['imageUrl'] as String? ?? '';
  final imageUrls = (profile['imageUrls'] as List<dynamic>?)
          ?.cast<String>()
          .where((u) => u.isNotEmpty)
          .toList() ??
      const [];
  final photoUrls = imageUrls.isNotEmpty
      ? imageUrls
      : <String>[if (imageUrl.isNotEmpty) imageUrl];

  return CandidateCard(
    userId: (profile['userId'] as String?) ?? 'disc_$index',
    nickname: (profile['name'] as String?) ?? 'Member',
    age: (profile['age'] as int?) ?? 24,
    city: city,
    distanceKm: parsedDist,
    bio: (profile['bio'] as String?) ?? '',
    photoUrls: photoUrls,
    isVerified: profile['verified'] == true,
    preference: (profile['goal'] as String?) ?? 'Long-term Partner',
    sharedInterests:
        (profile['interests'] as List<dynamic>?)?.cast<String>() ?? const [],
  );
}

/// 5-button discovery dock: Revert, Dislike, Spark, Like, and Message Request.
class DiscoveryActionDock extends StatelessWidget {
  final int revertCount;
  final VoidCallback onRevert;
  final VoidCallback onDislike;
  final VoidCallback onSpark;
  final VoidCallback onLike;
  final VoidCallback onMessageRequest;

  const DiscoveryActionDock({
    super.key,
    required this.revertCount,
    required this.onRevert,
    required this.onDislike,
    required this.onSpark,
    required this.onLike,
    required this.onMessageRequest,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dockBg =
        isDark ? const Color(0xCC0D101A) : Colors.white.withOpacity(0.94);
    final dockBorder = isDark
        ? const Color(0x26FFFFFF)
        : Colors.black.withOpacity(0.08);
    final btnBg =
        isDark ? const Color(0xFF191C24) : const Color(0xFFF8FAFC);
    final mutedBorder = isDark
        ? const Color(0x33FFFFFF)
        : Colors.grey.shade300;
    final hasRevert = revertCount > 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: dockBg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: dockBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.54 : 0.12),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 1. Revert (3-step directional rewind)
          _DockCircleButton(
            tooltip: 'Revert',
            size: 42,
            bgColor: btnBg,
            borderColor: hasRevert ? const Color(0xFFFACC15) : mutedBorder,
            icon: Icons.replay,
            iconColor: hasRevert
                ? const Color(0xFFFACC15)
                : const Color(0xFF64748B),
            iconSize: 20,
            badgeCount: hasRevert ? revertCount : null,
            onTap: onRevert,
          ),

          // 2. Dislike (Reject / Swipe Left)
          _DockCircleButton(
            tooltip: 'Dislike',
            size: 46,
            bgColor: btnBg,
            borderColor: const Color(0xFFEF4444),
            icon: Icons.close,
            iconColor: const Color(0xFFEF4444),
            iconSize: 23,
            onTap: onDislike,
          ),

          // 3. Spark (Mega Crush gradient glow)
          Tooltip(
            message: 'Spark',
            child: GestureDetector(
              onTap: onSpark,
              child: Container(
                width: 54,
                height: 54,
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
                      blurRadius: 18,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_fire_department,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // 4. Like (Heart / Swipe Right)
          _DockCircleButton(
            tooltip: 'Like',
            size: 46,
            bgColor: btnBg,
            borderColor: const Color(0xFF22C55E),
            icon: Icons.favorite,
            iconColor: const Color(0xFF22C55E),
            iconSize: 23,
            onTap: onLike,
          ),

          // 5. Message Request
          _DockCircleButton(
            tooltip: 'Message Request',
            size: 42,
            bgColor: btnBg,
            borderColor: const Color(0x6638BDF8),
            icon: Icons.chat_bubble_outline,
            iconColor: const Color(0xFF38BDF8),
            iconSize: 20,
            onTap: onMessageRequest,
          ),
        ],
      ),
    );
  }
}

class _DockCircleButton extends StatelessWidget {
  final String tooltip;
  final double size;
  final Color bgColor;
  final Color borderColor;
  final IconData icon;
  final Color iconColor;
  final double iconSize;
  final int? badgeCount;
  final VoidCallback onTap;

  const _DockCircleButton({
    required this.tooltip,
    required this.size,
    required this.bgColor,
    required this.borderColor,
    required this.icon,
    required this.iconColor,
    required this.iconSize,
    required this.onTap,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x26000000),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: iconColor, size: iconSize),
            ),
            if (badgeCount != null)
              Positioned(
                top: -3,
                right: -3,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFACC15),
                    shape: BoxShape.circle,
                    border: Border.all(color: bgColor, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
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
