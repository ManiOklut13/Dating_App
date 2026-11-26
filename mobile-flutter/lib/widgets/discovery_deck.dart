import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/discovery_connect_models.dart';
import '../data/profiles_data.dart';
import 'mega_crush_celebration.dart';
import 'match_modal.dart';
import '../screens/home/full_profile_screen.dart';
import '../screens/home/message_request_screen.dart';

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

class _SwipeHistoryEntry {
  final int candidateIndex;
  final bool wasLiked; // true: exited right, false: exited left

  _SwipeHistoryEntry({required this.candidateIndex, required this.wasLiked});
}

class _DiscoveryDeckState extends State<DiscoveryDeck> with TickerProviderStateMixin {
  late final PageController _reelsPageController;
  int _currentIndex = 0;
  int _photoIndex = 0;
  Offset _dragOffset = Offset.zero;

  // 3-step animated directional revert history stack (up to 3 swipes)
  final List<_SwipeHistoryEntry> _swipeHistory = [];
  bool _isReverting = false;
  late final AnimationController _revertAnimCtrl;
  late Animation<Offset> _revertSlideAnim;

  // Smooth directional card exit animation (Left for Reject, Right for Like)
  bool _isExiting = false;
  int _exitDirection = 0; // -1 for Left, +1 for Right
  late final AnimationController _cardExitAnimCtrl;

  // WhatsApp-style status auto-advance controller (4.0s per segment)
  late final AnimationController _photoStatusCtrl;

  @override
  void initState() {
    super.initState();
    _reelsPageController = PageController();

    // 4-second photo cycle in sync with status timeline
    _photoStatusCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _photoStatusCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!mounted) return;
        final candidate = kDemoProfiles[_currentIndex % kDemoProfiles.length];
        setState(() {
          _photoIndex = (_photoIndex + 1) % candidate.photoUrls.length;
        });
        _photoStatusCtrl.forward(from: 0.0);
      }
    });

    // Revert animation controller (slow & smooth return from exit side)
    _revertAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _revertSlideAnim = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _revertAnimCtrl, curve: Curves.easeOutCubic));

    // Directional Exit animation controller (Left / Right slide out)
    _cardExitAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _photoStatusCtrl.forward();
  }

  @override
  void dispose() {
    _reelsPageController.dispose();
    _photoStatusCtrl.dispose();
    _revertAnimCtrl.dispose();
    _cardExitAnimCtrl.dispose();
    super.dispose();
  }

  void _onCandidateChanged(int newIndex) {
    setState(() {
      _currentIndex = newIndex;
      _photoIndex = 0;
      _dragOffset = Offset.zero;
    });
    _photoStatusCtrl.forward(from: 0.0);
  }

  // Smooth directional Like (slides exiting to the RIGHT)
  void _swipeRight({bool animated = true}) {
    if (_isExiting || _isReverting) return;
    if (!animated) {
      _applyAction(wasLiked: true);
      return;
    }
    setState(() {
      _isExiting = true;
      _exitDirection = 1;
    });
    _cardExitAnimCtrl.forward(from: 0.0).then((_) {
      if (mounted) {
        _applyAction(wasLiked: true);
        _cardExitAnimCtrl.reset();
        setState(() => _isExiting = false);
      }
    });
  }

  // Smooth directional Reject (slides exiting to the LEFT)
  void _swipeLeft({bool animated = true}) {
    if (_isExiting || _isReverting) return;
    if (!animated) {
      _applyAction(wasLiked: false);
      return;
    }
    setState(() {
      _isExiting = true;
      _exitDirection = -1;
    });
    _cardExitAnimCtrl.forward(from: 0.0).then((_) {
      if (mounted) {
        _applyAction(wasLiked: false);
        _cardExitAnimCtrl.reset();
        setState(() => _isExiting = false);
      }
    });
  }

  void _applyAction({required bool wasLiked}) {
    final candidate = kDemoProfiles[_currentIndex % kDemoProfiles.length];
    _swipeHistory.add(_SwipeHistoryEntry(candidateIndex: _currentIndex, wasLiked: wasLiked));
    if (_swipeHistory.length > 3) {
      _swipeHistory.removeAt(0);
    }

    final nextIndex = _currentIndex + 1;
    if (_reelsPageController.hasClients && nextIndex < kDemoProfiles.length) {
      _reelsPageController.jumpToPage(nextIndex);
    }
    _onCandidateChanged(nextIndex);

    // 25% chance of triggering mutual match celebration modal on Like
    if (wasLiked && (DateTime.now().millisecond % 4 == 0)) {
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

  void _triggerMegaCrush() {
    final candidate = kDemoProfiles[_currentIndex % kDemoProfiles.length];
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => MegaCrushCelebration(recipientName: candidate.nickname),
    );

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        _swipeRight(animated: true);
      }
    });
  }

  // 3-step animated directional revert: slides back in from the exact side it exited
  void _handleRevert() {
    if (_swipeHistory.isEmpty || _isReverting || _isExiting) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No swiped profiles to revert in history.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final entry = _swipeHistory.removeLast();
    final prevCandidate = kDemoProfiles[entry.candidateIndex % kDemoProfiles.length];

    // If wasLiked (exited right), slide in from right (+Offset(1.5, 0) -> 0)
    // If wasRejected (exited left), slide in from left (-Offset(1.5, 0) -> 0)
    final startOffset = entry.wasLiked ? const Offset(1.5, 0.0) : const Offset(-1.5, 0.0);
    _revertSlideAnim = Tween<Offset>(
      begin: startOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _revertAnimCtrl, curve: Curves.easeOutCubic));

    setState(() {
      _isReverting = true;
      _currentIndex = entry.candidateIndex;
      _photoIndex = 0;
      _dragOffset = Offset.zero;
    });

    if (_reelsPageController.hasClients) {
      _reelsPageController.jumpToPage(_currentIndex);
    }

    _revertAnimCtrl.forward(from: 0.0).then((_) {
      if (mounted) {
        setState(() => _isReverting = false);
      }
    });

    _photoStatusCtrl.forward(from: 0.0);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('↺ Reverted ${prevCandidate.nickname}! (${_swipeHistory.length} of 3 rewinds remaining)'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openFullProfile(CandidateCard candidate) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullProfileScreen(
          profile: candidate,
          onLike: () => _swipeRight(animated: true),
          onPass: () => _swipeLeft(animated: true),
          onMegaCrush: _triggerMegaCrush,
          onDirectMessage: () => _openMessageRequest(candidate),
        ),
      ),
    );
  }

  void _openMessageRequest(CandidateCard candidate) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MessageRequestScreen(profile: candidate),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = _currentIndex >= kDemoProfiles.length;

    if (isCompleted) {
      return Container(
        height: 560,
        margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF131620),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0x1FFFFFFF)),
        ),
        child: _buildAllCaughtUpState(),
      );
    }

    return Container(
      height: 560,
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
        child: Stack(
          children: [
            // Vertical PageView (Reels scrolling with mouse-wheel & touch enabled)
            ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.trackpad,
                  PointerDeviceKind.stylus,
                },
              ),
              child: PageView.builder(
                controller: _reelsPageController,
                scrollDirection: Axis.vertical,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: kDemoProfiles.length,
                onPageChanged: (idx) {
                  _onCandidateChanged(idx);
                },
                itemBuilder: (ctx, index) {
                  final candidate = kDemoProfiles[index];
                  final isCurrent = index == _currentIndex;

                  Widget cardWidget = _buildCandidateCard(candidate, isTopCard: isCurrent);

                  if (isCurrent) {
                    if (_isExiting) {
                      final double endX = _exitDirection == 1 ? 1.5 : -1.5;
                      final double rotate = _exitDirection == 1 ? 0.15 : -0.15;
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset.zero,
                          end: Offset(endX, 0.05),
                        ).animate(
                          CurvedAnimation(parent: _cardExitAnimCtrl, curve: Curves.easeInOut),
                        ),
                        child: RotationTransition(
                          turns: Tween<double>(begin: 0.0, end: rotate).animate(
                            CurvedAnimation(parent: _cardExitAnimCtrl, curve: Curves.easeInOut),
                          ),
                          child: FadeTransition(
                            opacity: Tween<double>(begin: 1.0, end: 0.0).animate(
                              CurvedAnimation(parent: _cardExitAnimCtrl, curve: Curves.easeIn),
                            ),
                            child: cardWidget,
                          ),
                        ),
                      );
                    }
                    if (_isReverting) {
                      return SlideTransition(
                        position: _revertSlideAnim,
                        child: cardWidget,
                      );
                    }
                  }

                  return cardWidget;
                },
              ),
            ),

            // Fixed 5-Button Bottom Action Dock at bottom: 12
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
              onTap: () {
                _swipeHistory.clear();
                if (_reelsPageController.hasClients) {
                  _reelsPageController.jumpToPage(0);
                }
                _onCandidateChanged(0);
              },
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

  Widget _buildCandidateCard(CandidateCard candidate, {required bool isTopCard}) {
    final photoCount = candidate.photoUrls.length;
    final activePhoto = candidate.photoUrls[_photoIndex % photoCount];

    return Transform.translate(
      offset: isTopCard ? _dragOffset : Offset.zero,
      child: GestureDetector(
        onDoubleTap: isTopCard ? _triggerMegaCrush : null,
        onPanUpdate: isTopCard
            ? (d) {
                // Horizontal drag for Like / Nope gestures
                setState(() => _dragOffset += Offset(d.delta.dx, 0));
              }
            : null,
        onPanEnd: isTopCard
            ? (d) {
                if (_dragOffset.dx > 80) {
                  _swipeRight(animated: true);
                } else if (_dragOffset.dx < -80) {
                  _swipeLeft(animated: true);
                } else {
                  setState(() => _dragOffset = Offset.zero);
                }
              }
            : null,
        child: Stack(
          children: [
            // Full-bleed Profile Photo
            Positioned.fill(
              child: SafeProfileImage(
                imageUrl: activePhoto,
              ),
            ),

            // Left & Right tap zones for instant photo flipping
            Positioned.fill(
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        setState(() {
                          _photoIndex = (_photoIndex - 1 + photoCount) % photoCount;
                        });
                        _photoStatusCtrl.forward(from: 0.0);
                      },
                      child: const SizedBox.expand(),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        setState(() {
                          _photoIndex = (_photoIndex + 1) % photoCount;
                        });
                        _photoStatusCtrl.forward(from: 0.0);
                      },
                      child: const SizedBox.expand(),
                    ),
                  ),
                ],
              ),
            ),

            // WhatsApp-style Multi-photo Status Timeline Bars across top
            Positioned(
              top: 12,
              left: 14,
              right: 14,
              child: Row(
                children: List.generate(photoCount, (pIdx) {
                  final isPast = pIdx < (_photoIndex % photoCount);
                  final isCurrent = pIdx == (_photoIndex % photoCount);

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _photoIndex = pIdx);
                        _photoStatusCtrl.forward(from: 0.0);
                      },
                      child: Container(
                        height: 3.5,
                        margin: const EdgeInsets.symmetric(horizontal: 2.5),
                        decoration: BoxDecoration(
                          color: const Color(0x66FFFFFF),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: isPast
                            ? Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              )
                            : (isCurrent && isTopCard)
                                ? AnimatedBuilder(
                                    animation: _photoStatusCtrl,
                                    builder: (ctx, _) {
                                      return FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: _photoStatusCtrl.value,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : const SizedBox.shrink(),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Dark gradient overlay for text readability
            Positioned.fill(
              child: IgnorePointer(
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
            ),

            // Drag stamps: Like (Green) / Nope (Red)
            if (isTopCard && _dragOffset.dx > 40)
              Positioned(
                top: 26,
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
                top: 26,
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

            // Profile info overlay with Right Arrow Icon beside name to Full Profile Page
            Positioned(
              bottom: 82,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                      Expanded(
                        child: Column(
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
                                const SizedBox(width: 8),
                                // Clickable arrow icon immediately to the right of profile name
                                GestureDetector(
                                  onTap: () => _openFullProfile(candidate),
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: const Color(0x33FFFFFF),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0x4DFFFFFF)),
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 13,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '📍 ${candidate.city} • ${candidate.distanceKm} km away',
                              style: const TextStyle(fontSize: 11, color: Color(0xFFE2E8F0)),
                            ),
                          ],
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
    );
  }

  // 5-Button Bottom Action Bar:
  // 1) Revert ↺
  // 2) Reject ✕ (Close)
  // 3) Mega Crush 🔥
  // 4) Like 💚 (Heart)
  // 5) Message Request 💬
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
          // 1. Revert (Directional 3-step animated rewind)
          _actionBtn(
            size: 42,
            bgColor: const Color(0xFF191C24),
            borderColor: _swipeHistory.isNotEmpty ? const Color(0xFFFACC15) : const Color(0x33FFFFFF),
            icon: Icons.replay,
            iconColor: _swipeHistory.isNotEmpty ? const Color(0xFFFACC15) : const Color(0xFF64748B),
            iconSize: 20,
            badgeCount: _swipeHistory.isNotEmpty ? _swipeHistory.length : null,
            onTap: _handleRevert,
          ),

          // 2. Reject (Close/X) -> animates card exiting to the LEFT
          _actionBtn(
            size: 48,
            bgColor: const Color(0xFF191C24),
            borderColor: const Color(0xFFEF4444),
            icon: Icons.close,
            iconColor: const Color(0xFFEF4444),
            iconSize: 24,
            onTap: () => _swipeLeft(animated: true),
          ),

          // 3. Mega Crush (Fire / Ruby animation)
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

          // 4. Like (Heart) -> animates card exiting to the RIGHT
          _actionBtn(
            size: 48,
            bgColor: const Color(0xFF191C24),
            borderColor: const Color(0xFF22C55E),
            icon: Icons.favorite,
            iconColor: const Color(0xFF22C55E),
            iconSize: 24,
            onTap: () => _swipeRight(animated: true),
          ),

          // 5. Message Request -> navigates to dedicated MessageRequestScreen
          _actionBtn(
            size: 42,
            bgColor: const Color(0xFF191C24),
            borderColor: const Color(0x3338BDF8),
            icon: Icons.chat_bubble_outline,
            iconColor: const Color(0xFF38BDF8),
            iconSize: 20,
            onTap: () => _openMessageRequest(candidate),
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
    int? badgeCount,
  }) {
    return GestureDetector(
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
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: iconSize),
          ),
          if (badgeCount != null)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFFFACC15),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
