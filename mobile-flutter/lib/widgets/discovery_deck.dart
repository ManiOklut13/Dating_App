import 'package:flutter/material.dart';
import '../models/discovery_connect_models.dart';
import '../data/profiles_data.dart';
import 'mega_crush_celebration.dart';
import 'match_modal.dart';
import 'full_profile_modal.dart';
import 'coin_store_modal.dart';

class DiscoveryDeck extends StatefulWidget {
  final VoidCallback? onOpenStore;
  final Function(String convId)? onOpenChat;

  const DiscoveryDeck({
    super.key,
    this.onOpenStore,
    this.onOpenChat,
  });

  @override
  State<DiscoveryDeck> createState() => _DiscoveryDeckState();
}

class _DiscoveryDeckState extends State<DiscoveryDeck> {
  int _currentIndex = 0;
  Offset _dragOffset = Offset.zero;
  int _photoIndex = 0;

  // Revert tracking (1 most recent swipe undo, max 5/day)
  int? _lastSwipedIndex;
  int _revertsUsedToday = 0;

  void _swipeRight() {
    final candidate = kDemoProfiles[_currentIndex % kDemoProfiles.length];
    setState(() {
      _lastSwipedIndex = _currentIndex;
      _currentIndex++;
      _dragOffset = Offset.zero;
      _photoIndex = 0;
    });

    // 25% chance of triggering mutual match celebration modal
    if (DateTime.now().millisecond % 4 == 0) {
      showDialog(
        context: context,
        builder: (_) => MatchModal(
          matchedName: candidate.nickname,
          matchedAvatar: candidate.photoUrls.first,
          onStartChat: () => widget.onOpenChat?.call('chat-${candidate.userId}'),
        ),
      );
    }
  }

  void _swipeLeft() {
    setState(() {
      _lastSwipedIndex = _currentIndex;
      _currentIndex++;
      _dragOffset = Offset.zero;
      _photoIndex = 0;
    });
  }

  void _triggerMegaCrush() {
    final candidate = kDemoProfiles[_currentIndex % kDemoProfiles.length];
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => MegaCrushCelebration(recipientName: candidate.nickname),
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        setState(() {
          _lastSwipedIndex = _currentIndex;
          _currentIndex++;
          _dragOffset = Offset.zero;
          _photoIndex = 0;
        });
      }
    });
  }

  void _handleRevert() {
    if (_lastSwipedIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can only undo the 1 most recent swipe.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_revertsUsedToday >= 5) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const CoinStoreModal(),
      );
      return;
    }

    setState(() {
      _currentIndex = _lastSwipedIndex!;
      _lastSwipedIndex = null;
      _revertsUsedToday++;
      _dragOffset = Offset.zero;
      _photoIndex = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Swipe undone! (${5 - _revertsUsedToday} free daily rewinds left)'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openDirectMessageModal(CandidateCard candidate) {
    final TextEditingController msgCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF161923),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(top: BorderSide(color: Color(0x33FFFFFF))),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFFF4D88)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: SafeProfileImage(imageUrl: candidate.photoUrls.first),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Direct Message to ${candidate.nickname}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF94A3B8), size: 18),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131620),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0x26FFFFFF)),
                  ),
                  child: TextField(
                    controller: msgCtrl,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Say something witty about ${candidate.sharedInterests.firstOrNull ?? 'their profile'}...',
                      hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Direct message sent to ${candidate.nickname} ✨')),
                    );
                  },
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF8DA1), Color(0xFFFF4D88)],
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send, size: 15, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Send Message Request', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openFullProfile(CandidateCard candidate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FullProfileModal(
        profile: candidate,
        onLike: _swipeRight,
        onPass: _swipeLeft,
        onMegaCrush: _triggerMegaCrush,
        onDirectMessage: () => _openDirectMessageModal(candidate),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = _currentIndex >= kDemoProfiles.length;

    return Container(
      height: 530,
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF131620),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x1FFFFFFF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x80000000),
            blurRadius: 28,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: isCompleted
            ? _buildAllCaughtUpState()
            : Stack(
                children: [
                  // Up to 3 Cards in Stack
                  for (int i = 2; i >= 0; i--)
                    if (_currentIndex + i < kDemoProfiles.length)
                      _buildCandidateCard(
                        kDemoProfiles[_currentIndex + i],
                        isTopCard: i == 0,
                        cardStackDepth: i,
                      ),

                  // Fixed 5-Button Bottom Dock at bottom: 12
                  Positioned(
                    bottom: 12,
                    left: 14,
                    right: 14,
                    child: _buildBottomDock(kDemoProfiles[_currentIndex % kDemoProfiles.length]),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildAllCaughtUpState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0x1AF43F5E),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, size: 36, color: Color(0xFFFF8DA1)),
            ),
            const SizedBox(height: 16),
            const Text(
              "You're All Caught Up!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'You have reviewed all available nearby profiles for today.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8), height: 1.4),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => setState(() => _currentIndex = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF8DA1), Color(0xFFFF4D88)],
                  ),
                ),
                child: const Text(
                  'Reshuffle Feed',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCandidateCard(CandidateCard candidate, {required bool isTopCard, required int cardStackDepth}) {
    final double scale = 1.0 - (cardStackDepth * 0.04);
    final double translateY = cardStackDepth * 10.0;

    return Positioned.fill(
      child: Transform.translate(
        offset: isTopCard ? _dragOffset : Offset(0, translateY),
        child: Transform.scale(
          scale: scale,
          child: GestureDetector(
            onDoubleTap: isTopCard ? _triggerMegaCrush : null,
            onPanUpdate: isTopCard
                ? (d) => setState(() => _dragOffset += d.delta)
                : null,
            onPanEnd: isTopCard
                ? (d) {
                    if (_dragOffset.dx > 100) {
                      _swipeRight();
                    } else if (_dragOffset.dx < -100) {
                      _swipeLeft();
                    } else if (_dragOffset.dy < -100) {
                      _triggerMegaCrush();
                    } else {
                      setState(() => _dragOffset = Offset.zero);
                    }
                  }
                : null,
            child: Stack(
              children: [
                // Full-bleed Profile Image
                Positioned.fill(
                  child: SafeProfileImage(
                    imageUrl: candidate.photoUrls[_photoIndex % candidate.photoUrls.length],
                  ),
                ),

                // Top Multi-photo Indicator Bars
                if (candidate.photoUrls.length > 1)
                  Positioned(
                    top: 10,
                    left: 14,
                    right: 14,
                    child: Row(
                      children: List.generate(candidate.photoUrls.length, (pIdx) {
                        final active = pIdx == (_photoIndex % candidate.photoUrls.length);
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _photoIndex = pIdx),
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

                // Bottom Dark Gradient for Text Legibility
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Color(0x66000000), Color(0xF2090C14)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.4, 0.65, 1.0],
                      ),
                    ),
                  ),
                ),

                // Drag Visual Stamps: Green Heart (Left) / Red Cross (Right)
                if (isTopCard && _dragOffset.dx > 40)
                  Positioned(
                    top: 24,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xE622C55E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Text('💚 LIKE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
                    ),
                  ),
                if (isTopCard && _dragOffset.dx < -40)
                  Positioned(
                    top: 24,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xE6EF4444),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Text('✕ NOPE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
                    ),
                  ),

                // Profile Info Overlay at bottom: 82
                Positioned(
                  bottom: 82,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFFF4D88), width: 1.5),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(19),
                                  child: SafeProfileImage(imageUrl: candidate.photoUrls.first),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '${candidate.nickname} ${candidate.age}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      const Icon(Icons.verified, size: 16, color: Color(0xFF38BDF8)),
                                    ],
                                  ),
                                  Text(
                                    '📍 ${candidate.city} • ${candidate.distanceKm} km away',
                                    style: const TextStyle(fontSize: 11, color: Color(0xFFE2E8F0)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => _openFullProfile(candidate),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0x33FFFFFF),
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0x4DFFFFFF)),
                              ),
                              child: const Icon(Icons.arrow_forward_ios, size: 13, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        candidate.bio,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFFCBD5E1), height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Fixed 5-Button Bottom Dock at bottom: 12
  Widget _buildBottomDock(CandidateCard candidate) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xCC0D101A),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x26FFFFFF)),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 18, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 1. Revert ↺ (44x44 #191C24)
          _actionBtn(
            size: 42,
            bgColor: const Color(0xFF191C24),
            borderColor: const Color(0x33FFFFFF),
            icon: Icons.replay,
            iconColor: const Color(0xFFFACC15),
            iconSize: 20,
            onTap: _handleRevert,
          ),

          // 2. Reject ✕ (50x50 #191C24, red border)
          _actionBtn(
            size: 48,
            bgColor: const Color(0xFF191C24),
            borderColor: const Color(0xFFEF4444),
            icon: Icons.close,
            iconColor: const Color(0xFFEF4444),
            iconSize: 24,
            onTap: _swipeLeft,
          ),

          // 3. Mega Crush 🔥 (60x60 glowing red/orange circle)
          GestureDetector(
            onTap: _triggerMegaCrush,
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF4D88), Color(0xFFF97316)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x80F97316),
                    blurRadius: 20,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.local_fire_department, size: 32, color: Colors.white),
            ),
          ),

          // 4. Like 💚 (50x50 #191C24, green border)
          _actionBtn(
            size: 48,
            bgColor: const Color(0xFF191C24),
            borderColor: const Color(0xFF22C55E),
            icon: Icons.favorite,
            iconColor: const Color(0xFF22C55E),
            iconSize: 24,
            onTap: _swipeRight,
          ),

          // 5. Direct Message 💬 (42x42 #191C24)
          _actionBtn(
            size: 42,
            bgColor: const Color(0xFF191C24),
            borderColor: const Color(0x33FFFFFF),
            icon: Icons.chat_bubble_outline,
            iconColor: const Color(0xFF38BDF8),
            iconSize: 20,
            onTap: () => _openDirectMessageModal(candidate),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn({
    required double size,
    required Color bgColor,
    required Color borderColor,
    required IconData icon,
    required Color iconColor,
    required double iconSize,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: iconColor, size: iconSize),
      ),
    );
  }
}
