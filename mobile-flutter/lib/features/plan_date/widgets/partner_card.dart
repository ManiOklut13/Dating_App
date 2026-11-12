// ─────────────────────────────────────────────────────────────────────────────
// Partner Card - YOUR DATE PAIR
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../../../services/app_data_service.dart';

class PartnerCard extends StatelessWidget {
  final String? partnerName;
  final bool isOnline;
  final String? avatarUrl;
  final VoidCallback onChangePartner;
  final ValueChanged<String> onSearch;

  const PartnerCard({
    super.key,
    this.partnerName,
    required this.isOnline,
    this.avatarUrl,
    required this.onChangePartner,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = AppDataService.instance.userProfile;
    final currentUserPhoto =
        currentUser.photos.isNotEmpty ? currentUser.photos[0] : null;
    final currentUserOnline = currentUser.isOnline;

    return Column(
      children: [
        // YOUR DATE PAIR label
        const Text(
          'YOUR DATE PAIR',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFFF0318B),
            letterSpacing: 4.0,
          ),
        ),
        const SizedBox(height: 16),
        // Match pair cards
        SizedBox(
          height: 210,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Left card - current user "You"
              Positioned(
                left: (MediaQuery.of(context).size.width - 32 - 320) / 2,
                child: _PressableCard(
                  onTap: onChangePartner,
                  child: Transform.rotate(
                    angle: -6 * 3.14159 / 180,
                    child: _ProfileCard(
                      photoUrl: currentUserPhoto,
                      label: 'You',
                      isOnline: currentUserOnline,
                      isCurrentUser: true,
                    ),
                  ),
                ),
              ),
              // Right card - partner
              Positioned(
                right: (MediaQuery.of(context).size.width - 32 - 320) / 2,
                child: _PressableCard(
                  onTap: onChangePartner,
                  child: Transform.rotate(
                    angle: 6 * 3.14159 / 180,
                    child: _ProfileCard(
                      photoUrl: avatarUrl,
                      label: partnerName ?? 'Partner',
                      isOnline: isOnline,
                      isCurrentUser: false,
                    ),
                  ),
                ),
              ),
              // Heart badge in the middle with pulse animation
              const _PulsingHeartBadge(),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Search field
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF16121F),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, size: 18, color: Color(0xFF8E88A3)),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  onChanged: onSearch,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Colors.white,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Search for partner...',
                    hintStyle: TextStyle(
                      color: Color(0xFF8E88A3),
                      fontSize: 13,
                      fontFamily: 'Inter',
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PressableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _PressableCard({required this.child, required this.onTap});

  @override
  State<_PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<_PressableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

class _PulsingHeartBadge extends StatefulWidget {
  const _PulsingHeartBadge();

  @override
  State<_PulsingHeartBadge> createState() => _PulsingHeartBadgeState();
}

class _PulsingHeartBadgeState extends State<_PulsingHeartBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFF0318B), Color(0xFFA21CAF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: const Color(0xFF0D0A17),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF0318B).withValues(alpha: 0.6),
                  blurRadius: 16,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: const Icon(
              Icons.favorite,
              color: Colors.white,
              size: 32,
            ),
          ),
        );
      },
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String? photoUrl;
  final String label;
  final bool isOnline;
  final bool isCurrentUser;

  const _ProfileCard({
    required this.photoUrl,
    required this.label,
    required this.isOnline,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Photo or placeholder
            if (isCurrentUser)
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6B3FA0), Color(0xFF3B1F66)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.person,
                    color: Colors.white70,
                    size: 60,
                  ),
                ),
              )
            else if (photoUrl != null)
              Image.asset(
                photoUrl!,
                fit: BoxFit.cover,
              )
            else
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6B3FA0), Color(0xFF3B1F66)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.person,
                    color: Colors.white70,
                    size: 60,
                  ),
                ),
              ),
            // Gradient overlay at bottom for name
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 80,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black87,
                    ],
                  ),
                ),
              ),
            ),
            // Name label at bottom-left
            Positioned(
              bottom: 14,
              left: 14,
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Green online dot at top-right
            if (isOnline)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF0D0A17),
                      width: 2,
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
