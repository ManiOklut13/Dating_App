import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'discovery_filters_screen.dart';

class DatingProfile {
  final String id;
  final String name;
  final int age;
  final String role;
  final String city;
  final String distance;
  final String bio;
  final List<String> interests;
  final List<Color> cardGradient;
  final IconData avatarIcon;

  const DatingProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.role,
    required this.city,
    required this.distance,
    required this.bio,
    required this.interests,
    required this.cardGradient,
    required this.avatarIcon,
  });
}

class ProfileSwipeDeckScreen extends StatefulWidget {
  const ProfileSwipeDeckScreen({super.key});

  @override
  State<ProfileSwipeDeckScreen> createState() => _ProfileSwipeDeckScreenState();
}

class _ProfileSwipeDeckScreenState extends State<ProfileSwipeDeckScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  // Current drag offset for both horizontal (left/right) and vertical (up/down) gestures
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;

  late AnimationController _animController;
  Animation<Offset>? _slideAnimation;

  // Sample profiles (replace with your backend API stream)
  final List<DatingProfile> _profiles = const [
    DatingProfile(
      id: 'p1',
      name: 'Ananya',
      age: 24,
      role: 'Product Designer',
      city: 'Hyderabad',
      distance: '3 km away',
      bio: 'Coffee enthusiast, weekend hiker, and always down for late-night filter coffee runs.',
      interests: ['Design', 'Travel', 'Badminton', 'Music'],
      cardGradient: [Color(0xFF2B1055), Color(0xFF7597DE)],
      avatarIcon: Icons.face_4_rounded,
    ),
    DatingProfile(
      id: 'p2',
      name: 'Meera',
      age: 23,
      role: 'Software Developer',
      city: 'Hyderabad',
      distance: '5 km away',
      bio: 'Building apps by day, exploring hidden biryani spots by night.',
      interests: ['Coding', 'Foodie', 'Movies', 'Fitness'],
      cardGradient: [Color(0xFF1F1C2C), Color(0xFF928DAB)],
      avatarIcon: Icons.face_3_rounded,
    ),
    DatingProfile(
      id: 'p3',
      name: 'Kavya',
      age: 25,
      role: 'Architect',
      city: 'Secunderabad',
      distance: '7 km away',
      bio: 'Sketchbooks, sunsets, and long drives with good Telugu melodies.',
      interests: ['Architecture', 'Photography', 'Art', 'Road Trips'],
      cardGradient: [Color(0xFF3A1C71), Color(0xFFD76D77)],
      avatarIcon: Icons.face_retouching_natural,
    ),
    DatingProfile(
      id: 'p4',
      name: 'Riya',
      age: 22,
      role: 'Marketing Strategist',
      city: 'Gachibowli',
      distance: '2 km away',
      bio: 'Dog lover, gym regular, and competitive board game player.',
      interests: ['Dogs', 'Gym', 'Books', 'Board Games'],
      cardGradient: [Color(0xFF0F2027), Color(0xFF2C5364)],
      avatarIcon: Icons.face_2_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )..addListener(() {
        if (_slideAnimation != null) {
          setState(() {
            _dragOffset = _slideAnimation!.value;
          });
        }
      });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    if (_animController.isAnimating) return;
    setState(() {
      _isDragging = true;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_animController.isAnimating) return;
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details, Size cardSize) {
    setState(() {
      _isDragging = false;
    });

    final dx = _dragOffset.dx;
    final dy = _dragOffset.dy;
    final velocity = details.velocity.pixelsPerSecond;

    final horizontalThreshold = cardSize.width * 0.28;
    final verticalThreshold = cardSize.height * 0.20;

    // 1. Horizontal Swipe (Left = Pass, Right = Like)
    if (dx.abs() > dy.abs() &&
        (dx.abs() > horizontalThreshold || velocity.dx.abs() > 700)) {
      final isRight = dx > 0;
      final targetX = isRight ? cardSize.width * 1.4 : -cardSize.width * 1.4;
      _animateCardOut(
        targetOffset: Offset(targetX, dy * 0.4),
        onComplete: () => _advanceToNextProfile(liked: isRight),
      );
      return;
    }

    // 2. Vertical Scroll/Swipe Up -> Next Card rises from underneath
    if (dy < -verticalThreshold || velocity.dy < -700) {
      _animateCardOut(
        targetOffset: Offset(dx * 0.2, -cardSize.height * 1.25),
        onComplete: () => _advanceToNextProfile(),
      );
      return;
    }

    // 3. Vertical Scroll/Swipe Down -> Bring back Previous Card if available
    if ((dy > verticalThreshold || velocity.dy > 700) && _currentIndex > 0) {
      _animateCardOut(
        targetOffset: Offset(dx * 0.2, cardSize.height * 1.25),
        onComplete: () {
          setState(() {
            _currentIndex = (_currentIndex - 1).clamp(0, _profiles.length - 1);
            _dragOffset = Offset.zero;
          });
        },
      );
      return;
    }

    // Snap back smoothly if threshold wasn't reached
    _animateReset();
  }

  void _animateCardOut({
    required Offset targetOffset,
    required VoidCallback onComplete,
  }) {
    _slideAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: targetOffset,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _animController.forward(from: 0).then((_) {
      onComplete();
    });
  }

  void _animateReset() {
    _slideAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _animController.forward(from: 0);
  }

  void _advanceToNextProfile({bool? liked}) {
    setState(() {
      if (_currentIndex < _profiles.length - 1) {
        _currentIndex++;
      } else {
        // Loop back or show end-of-deck state
        _currentIndex = 0;
      }
      _dragOffset = Offset.zero;
    });

    if (liked != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(liked ? 'Liked profile!' : 'Passed profile'),
          duration: const Duration(milliseconds: 600),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _swipeProgrammatically({required bool isLike}) {
    if (_animController.isAnimating) return;
    final size = MediaQuery.of(context).size;
    final targetX = isLike ? size.width * 1.3 : -size.width * 1.3;
    _animateCardOut(
      targetOffset: Offset(targetX, 0),
      onComplete: () => _advanceToNextProfile(liked: isLike),
    );
  }

  void _rewindProgrammatically() {
    if (_currentIndex > 0 && !_animController.isAnimating) {
      final size = MediaQuery.of(context).size;
      setState(() {
        _dragOffset = Offset(0, size.height * 0.8);
        _currentIndex--;
      });
      _animateReset();
    }
  }

  void _swipeUpProgrammatically() {
    if (_animController.isAnimating) return;
    final size = MediaQuery.of(context).size;
    _animateCardOut(
      targetOffset: Offset(0, -size.height * 1.2),
      onComplete: () => _advanceToNextProfile(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0D070C) : const Color(0xFFF9FAFB);
    final currentProfile = _profiles[_currentIndex];
    final nextProfile = _currentIndex < _profiles.length - 1
        ? _profiles[_currentIndex + 1]
        : _profiles[0];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDark ? Colors.white : Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'Discover Deck',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: FilledButton.tonalIcon(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final updatedFilters = await Navigator.push<Map<String, dynamic>>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DiscoveryFiltersScreen(),
                  ),
                );
                if (updatedFilters != null && mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        'Filters applied: Age ${updatedFilters['minAge']}-${updatedFilters['maxAge']} • ${updatedFilters['radiusKm']} km',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              icon: Icon(
                Icons.tune_rounded,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              label: Text(
                'Filters',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = constraints.maxWidth * 0.92;
          final cardHeight = constraints.maxHeight * 0.76;
          final cardSize = Size(cardWidth, cardHeight);

          final rotationAngle = (_dragOffset.dx / cardWidth) * (math.pi / 16);

          // Stamp Opacities
          final likeOpacity = (_dragOffset.dx > 40)
              ? ((_dragOffset.dx - 40) / 100).clamp(0.0, 1.0)
              : 0.0;
          final nopeOpacity = (_dragOffset.dx < -40)
              ? ((-_dragOffset.dx - 40) / 100).clamp(0.0, 1.0)
              : 0.0;
          final nextOpacity = (_dragOffset.dy < -40)
              ? ((-_dragOffset.dy - 40) / 100).clamp(0.0, 1.0)
              : 0.0;

          return Column(
            children: [
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: cardWidth,
                    height: cardHeight,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Card Underneath (Next Card Preview with slight scale)
                        Positioned.fill(
                          child: Transform.scale(
                            scale: 0.94,
                            child: _buildProfileCard(
                              nextProfile,
                              isInteractive: false,
                            ),
                          ),
                        ),

                        // Active Card on Top with Drag Gestures
                        Positioned.fill(
                          child: GestureDetector(
                            onPanStart: _onPanStart,
                            onPanUpdate: _onPanUpdate,
                            onPanEnd: (details) => _onPanEnd(details, cardSize),
                            child: Transform.translate(
                              offset: _dragOffset,
                              child: Transform.rotate(
                                angle: rotationAngle,
                                child: Stack(
                                  children: [
                                    _buildProfileCard(
                                      currentProfile,
                                      isInteractive: true,
                                    ),

                                    // LIKE Stamp (Swipe Right)
                                    if (likeOpacity > 0)
                                      Positioned(
                                        top: 36,
                                        left: 28,
                                        child: Transform.rotate(
                                          angle: -0.2,
                                          child: Opacity(
                                            opacity: likeOpacity,
                                            child: _buildStamp(
                                              label: 'LIKE',
                                              color: Colors.greenAccent,
                                            ),
                                          ),
                                        ),
                                      ),

                                    // NOPE Stamp (Swipe Left)
                                    if (nopeOpacity > 0)
                                      Positioned(
                                        top: 36,
                                        right: 28,
                                        child: Transform.rotate(
                                          angle: 0.2,
                                          child: Opacity(
                                            opacity: nopeOpacity,
                                            child: _buildStamp(
                                              label: 'NOPE',
                                              color: const Color(0xFFFF2E55),
                                            ),
                                          ),
                                        ),
                                      ),

                                    // NEXT Stamp (Swipe Up)
                                    if (nextOpacity > 0)
                                      Positioned(
                                        bottom: 120,
                                        left: 0,
                                        right: 0,
                                        child: Center(
                                          child: Opacity(
                                            opacity: nextOpacity,
                                            child: _buildStamp(
                                              label: 'NEXT',
                                              color: Colors.amberAccent,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Action Buttons
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0, top: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Rewind
                    _buildActionButton(
                      icon: Icons.replay_rounded,
                      color: const Color(0xFFF59E0B),
                      size: 46,
                      iconSize: 22,
                      onTap: _currentIndex > 0 ? _rewindProgrammatically : null,
                    ),

                    // Pass (Dislike)
                    _buildActionButton(
                      icon: Icons.close_rounded,
                      color: const Color(0xFFEF4444),
                      size: 58,
                      iconSize: 28,
                      onTap: () => _swipeProgrammatically(isLike: false),
                    ),

                    // Super Like / Next Up
                    _buildActionButton(
                      icon: Icons.star_rounded,
                      color: const Color(0xFF3B82F6),
                      size: 48,
                      iconSize: 24,
                      onTap: _swipeUpProgrammatically,
                    ),

                    // Like
                    _buildActionButton(
                      icon: Icons.favorite_rounded,
                      color: const Color(0xFF10B981),
                      size: 58,
                      iconSize: 28,
                      onTap: () => _swipeProgrammatically(isLike: true),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileCard(DatingProfile profile, {required bool isInteractive}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: profile.cardGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(_isDragging ? 0.45 : 0.35),
                          blurRadius: _isDragging ? 24 : 18,
                          offset: Offset(0, _isDragging ? 14 : 10),
                        ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Center Profile Illustration / Avatar
            Center(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.12),
                  border: Border.all(color: Colors.white24, width: 2),
                ),
                child: Icon(
                  profile.avatarIcon,
                  size: 88,
                  color: Colors.white.withOpacity(0.92),
                ),
              ),
            ),

            // Top Badges Row
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on_rounded,
                            size: 14, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          '${profile.city} • ${profile.distance}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.greenAccent, width: 1),
                    ),
                    child: const Text(
                      'Online',
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Profile Info Sheet
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.75),
                      Colors.black.withOpacity(0.92),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name & Age
                    Row(
                      children: [
                        Text(
                          '${profile.name}, ${profile.age}',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.verified_rounded,
                          color: Color(0xFF38BDF8),
                          size: 22,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Role
                    Text(
                      profile.role,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Bio
                    Text(
                      profile.bio,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),

                    // Interests Chips
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: profile.interests.map((interest) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.2), width: 1),
                          ),
                          child: Text(
                            interest,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStamp({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 3),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 24,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required double size,
    required double iconSize,
    required VoidCallback? onTap,
  }) {
    final isEnabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isEnabled ? color.withOpacity(0.15) : Colors.white10,
          shape: BoxShape.circle,
          border: Border.all(
            color: isEnabled ? color.withOpacity(0.5) : Colors.white12,
            width: 1.8,
          ),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: isEnabled ? color : Colors.white24,
          size: iconSize,
        ),
      ),
    );
  }
}
