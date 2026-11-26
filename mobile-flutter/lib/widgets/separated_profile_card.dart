import 'package:flutter/material.dart';

/// Full-width separated profile card with WhatsApp-style status photo bar,
/// left/right ✔ and ✕ swipe stamps, and compact bio/interests overlay.
class SeparatedProfileCard extends StatelessWidget {
  final Map<String, dynamic> profile;
  final double swipeProgressDx;
  final int activePhotoIndex;
  final Animation<double>? photoProgress;
  final bool isFrontCard;
  final VoidCallback? onPrevPhoto;
  final VoidCallback? onNextPhoto;
  final ValueChanged<int>? onSelectPhoto;
  final VoidCallback? onOpenProfile;

  const SeparatedProfileCard({
    super.key,
    required this.profile,
    required this.swipeProgressDx,
    this.activePhotoIndex = 0,
    this.photoProgress,
    this.isFrontCard = false,
    this.onPrevPhoto,
    this.onNextPhoto,
    this.onSelectPhoto,
    this.onOpenProfile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final likeOpacity = (swipeProgressDx / 110).clamp(0.0, 1.0);
    final passOpacity = (-swipeProgressDx / 110).clamp(0.0, 1.0);

    final photos = (profile['imageUrls'] as List<dynamic>?)
            ?.cast<String>()
            .where((u) => u.isNotEmpty)
            .toList() ??
        const [];
    final resolvedPhotos = photos.isNotEmpty
        ? photos
        : <String>[profile['imageUrl'] as String? ?? ''];
    final safePhotoIndex = activePhotoIndex % resolvedPhotos.length;
    final activePhotoUrl = resolvedPhotos[safePhotoIndex];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: theme.colorScheme.surface,
        border: Border.all(
          color: Colors.white.withOpacity(0.18),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            activePhotoUrl,
            key: ValueKey(activePhotoUrl),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey.shade800,
              child: const Icon(Icons.person, size: 72, color: Colors.white54),
            ),
          ),

          // Left / right tap zones to cycle through photos like WhatsApp Status
          if (isFrontCard)
            Positioned.fill(
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: onPrevPhoto,
                      child: const SizedBox.expand(),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: onNextPhoto,
                      child: const SizedBox.expand(),
                    ),
                  ),
                ],
              ),
            ),

          // Bottom gradient overlay for crisp text readability
          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.45, 1.0],
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.88),
                  ],
                ),
              ),
            ),
          ),

          // WhatsApp-style segmented status progress bars across top
          Positioned(
            top: 10,
            left: 12,
            right: 12,
            child: Row(
              children: List.generate(resolvedPhotos.length, (pIdx) {
                final isPast = pIdx < safePhotoIndex;
                final isCurrent = pIdx == safePhotoIndex;

                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: isFrontCard && onSelectPhoto != null
                        ? () => onSelectPhoto!(pIdx)
                        : null,
                    child: Container(
                      height: 3.5,
                      margin: const EdgeInsets.symmetric(horizontal: 2.5),
                      decoration: BoxDecoration(
                        color: const Color(0x59FFFFFF),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: isPast
                          ? Container(color: Colors.white)
                          : (isCurrent && isFrontCard && photoProgress != null)
                              ? AnimatedBuilder(
                                  animation: photoProgress!,
                                  builder: (context, _) {
                                    return FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: photoProgress!.value,
                                      child: Container(color: Colors.white),
                                    );
                                  },
                                )
                              : (isCurrent
                                  ? Container(color: Colors.white)
                                  : const SizedBox.shrink()),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Right swipe ✔ stamp (replaces LIKE)
          if (likeOpacity > 0.05)
            Positioned(
              top: 28,
              left: 20,
              child: Opacity(
                opacity: likeOpacity,
                child: Transform.rotate(
                  angle: -0.16,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.greenAccent, width: 3.5),
                      shape: BoxShape.circle,
                      color: Colors.black38,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.greenAccent,
                      size: 34,
                    ),
                  ),
                ),
              ),
            ),

          // Left swipe ✕ stamp (replaces PASS)
          if (passOpacity > 0.05)
            Positioned(
              top: 28,
              right: 20,
              child: Opacity(
                opacity: passOpacity,
                child: Transform.rotate(
                  angle: 0.16,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.redAccent, width: 3.5),
                      shape: BoxShape.circle,
                      color: Colors.black38,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.redAccent,
                      size: 34,
                    ),
                  ),
                ),
              ),
            ),

          // Top Distance Pill (positioned neatly below status bars)
          Positioned(
            top: 22,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.45),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: Colors.white,
                    size: 13,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    profile['distance'] as String,
                    style: const TextStyle(color: Colors.white, fontSize: 11.5),
                  ),
                ],
              ),
            ),
          ),

          // Profile Info compactly positioned above the bottom 5-button dock
          Positioned(
            left: 14,
            right: 14,
            bottom: 82,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2.5,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.90),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    profile['goal'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '${profile['name']}, ${profile['age']}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (profile['verified'] == true) ...[
                      const SizedBox(width: 5),
                      const Icon(
                        Icons.verified_rounded,
                        color: Colors.lightBlueAccent,
                        size: 18,
                      ),
                    ],
                    if (onOpenProfile != null) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onOpenProfile,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.35),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  profile['role'] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 11.5,
                  ),
                ),
                if (profile['bio'] != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    profile['bio'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.82),
                      fontSize: 11,
                      height: 1.2,
                    ),
                  ),
                ],
                const SizedBox(height: 5),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: (profile['interests'] as List<String>)
                      .map((tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.16),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.24),
                              ),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
