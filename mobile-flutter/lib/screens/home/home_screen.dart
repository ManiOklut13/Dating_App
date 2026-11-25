import 'package:flutter/material.dart';
import '../calls/live_interactive_call_screen.dart';

class RandomCallUser {
  final String id;
  final String name;
  final int age;
  final String city;
  final String status; // e.g. "Online", "In Lounge"
  final IconData avatarIcon;
  final Color avatarBgColor;
  final Color avatarAccentColor;

  const RandomCallUser({
    required this.id,
    required this.name,
    required this.age,
    required this.city,
    required this.status,
    required this.avatarIcon,
    required this.avatarBgColor,
    required this.avatarAccentColor,
  });
}

class LiveProfileUser {
  final String id;
  final String name;
  final int age;
  final String city;
  final IconData avatarIcon;
  final Color avatarBgColor;
  final Color avatarAccentColor;

  const LiveProfileUser({
    required this.id,
    required this.name,
    required this.age,
    required this.city,
    required this.avatarIcon,
    required this.avatarBgColor,
    required this.avatarAccentColor,
  });
}

class HomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToConnect;

  const HomeScreen({super.key, this.onNavigateToConnect});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Tracks which profile card currently has its Audio/Video buttons popped out
  String? _selectedUserId;

  // Tracks which live profile currently has Audio & Video buttons popped out
  String? _selectedLiveUserId;

  // Available Live Profiles using Avatars (No real photos)
  final List<LiveProfileUser> _liveProfiles = const [
    LiveProfileUser(
      id: 'live_1',
      name: 'Ananya',
      age: 24,
      city: 'Hyderabad',
      avatarIcon: Icons.face_4_rounded,
      avatarBgColor: Color(0xFFFFE5EC),
      avatarAccentColor: Color(0xFFE94057),
    ),
    LiveProfileUser(
      id: 'live_2',
      name: 'Meera',
      age: 23,
      city: 'Bengaluru',
      avatarIcon: Icons.face_3_rounded,
      avatarBgColor: Color(0xFFE8F0FE),
      avatarAccentColor: Color(0xFF3B82F6),
    ),
    LiveProfileUser(
      id: 'live_3',
      name: 'Kavya',
      age: 25,
      city: 'Secunderabad',
      avatarIcon: Icons.face_retouching_natural,
      avatarBgColor: Color(0xFFFEF3C7),
      avatarAccentColor: Color(0xFFD97706),
    ),
    LiveProfileUser(
      id: 'live_4',
      name: 'Riya',
      age: 22,
      city: 'Chennai',
      avatarIcon: Icons.face_2_rounded,
      avatarBgColor: Color(0xFFDCFCE7),
      avatarAccentColor: Color(0xFF16A34A),
    ),
    LiveProfileUser(
      id: 'live_5',
      name: 'Sneha',
      age: 24,
      city: 'Pune',
      avatarIcon: Icons.face_rounded,
      avatarBgColor: Color(0xFFF3E8FF),
      avatarAccentColor: Color(0xFF9333EA),
    ),
  ];

  void _onTapLiveProfile(String userId) {
    setState(() {
      _selectedLiveUserId = (_selectedLiveUserId == userId) ? null : userId;
    });
  }

  void _startLiveCall(LiveProfileUser user, {required bool isVideo}) {
    final callType = isVideo ? 'Video Call' : 'Audio Call';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting $callType with ${user.name}...'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LiveInteractiveCallScreen(
          userName: user.name,
          avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb',
          isVideo: isVideo,
        ),
      ),
    );
  }

  // Sample avatar-only profiles (no real photos)
  final List<RandomCallUser> _randomCallUsers = const [
    RandomCallUser(
      id: 'usr_1',
      name: 'Aarav',
      age: 24,
      city: 'Hyderabad',
      status: 'Online',
      avatarIcon: Icons.face_retouching_natural,
      avatarBgColor: Color(0xFFFFE5EC),
      avatarAccentColor: Color(0xFFE94057),
    ),
    RandomCallUser(
      id: 'usr_2',
      name: 'Meera',
      age: 23,
      city: 'Bengaluru',
      status: 'Online',
      avatarIcon: Icons.face_3,
      avatarBgColor: Color(0xFFE8F0FE),
      avatarAccentColor: Color(0xFF3B82F6),
    ),
    RandomCallUser(
      id: 'usr_3',
      name: 'Rohan',
      age: 26,
      city: 'Visakhapatnam',
      status: 'Available',
      avatarIcon: Icons.face_6,
      avatarBgColor: Color(0xFFFEF3C7),
      avatarAccentColor: Color(0xFFD97706),
    ),
    RandomCallUser(
      id: 'usr_4',
      name: 'Ananya',
      age: 22,
      city: 'Chennai',
      status: 'Online',
      avatarIcon: Icons.face_4,
      avatarBgColor: Color(0xFFDCFCE7),
      avatarAccentColor: Color(0xFF16A34A),
    ),
  ];

  void _toggleProfileSelection(String userId) {
    setState(() {
      _selectedUserId = (_selectedUserId == userId) ? null : userId;
    });
  }

  void _startCall(RandomCallUser user, {required bool isVideo}) {
    final callType = isVideo ? 'Video Call' : 'Audio Call';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting $callType with ${user.name}...'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LiveInteractiveCallScreen(
          userName: user.name,
          avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb',
          isVideo: isVideo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const Color primaryColor = Color(0xFFE94057);

    final bgColor = isDark ? const Color(0xFF0D070C) : const Color(0xFFF9FAFB);
    final cardBgColor = isDark ? const Color(0xFF16161D) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF111318) : Colors.white,
        elevation: 0,
        title: Text(
          'Discover',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- AVAILABLE LIVE PROFILES SECTION ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Available Live Profiles',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Tap avatar to call',
                    style: TextStyle(
                      fontSize: 12,
                      color: subTextColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 104,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _liveProfiles.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final user = _liveProfiles[index];
                  final isSelected = _selectedLiveUserId == user.id;

                  return GestureDetector(
                    onTap: () => _onTapLiveProfile(user.id),
                    child: SizedBox(
                      width: 68,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.all(2.5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? primaryColor
                                        : Colors.green,
                                    width: isSelected ? 2.5 : 2.0,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: primaryColor.withOpacity(0.35),
                                            blurRadius: 10,
                                            spreadRadius: 1,
                                          )
                                        ]
                                      : null,
                                ),
                                child: Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: user.avatarBgColor,
                                  ),
                                  child: Icon(
                                    user.avatarIcon,
                                    color: user.avatarAccentColor,
                                    size: 28,
                                  ),
                                ),
                              ),
                              if (!isSelected)
                                Positioned(
                                  bottom: 1,
                                  right: 1,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: cardBgColor,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          if (isSelected)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () => _startLiveCall(user, isVideo: false),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.all(4.5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2563EB).withOpacity(0.2),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF3B82F6),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.call_rounded,
                                      size: 13,
                                      color: Color(0xFF60A5FA),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                InkWell(
                                  onTap: () => _startLiveCall(user, isVideo: true),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.all(4.5),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: primaryColor,
                                        width: 1,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.videocam_rounded,
                                      size: 13,
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            Text(
                              user.name,
                              style: TextStyle(
                                color: subTextColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // --- RANDOM CALLS SECTION (Replaces Date Planning) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Random Calls',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tap an avatar to start an audio or video call',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: subTextColor,
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: widget.onNavigateToConnect ?? () {},
                    icon: const Icon(Icons.shuffle_rounded,
                        size: 18, color: primaryColor),
                    label: const Text(
                      'Connect Tab',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Grid of Avatar-Only Random Call Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _randomCallUsers.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.86,
              ),
              itemBuilder: (context, index) {
                final user = _randomCallUsers[index];
                final isSelected = _selectedUserId == user.id;

                return GestureDetector(
                  onTap: () => _toggleProfileSelection(user.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected
                            ? primaryColor
                            : (isDark ? Colors.white12 : Colors.grey.shade200),
                        width: isSelected ? 1.8 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? primaryColor.withOpacity(0.25)
                              : Colors.black.withOpacity(isDark ? 0.3 : 0.04),
                          blurRadius: isSelected ? 12 : 6,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Avatar + Status Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: user.avatarBgColor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                user.avatarIcon,
                                color: user.avatarAccentColor,
                                size: 26,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: user.status == 'Online'
                                    ? const Color(0xFFDCFCE7).withOpacity(isDark ? 0.2 : 1)
                                    : const Color(0xFFFEF3C7).withOpacity(isDark ? 0.2 : 1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: user.status == 'Online'
                                          ? const Color(0xFF16A34A)
                                          : const Color(0xFFD97706),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    user.status,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: user.status == 'Online'
                                          ? (isDark ? Colors.greenAccent : const Color(0xFF15803D))
                                          : (isDark ? Colors.amberAccent : const Color(0xFFB45309)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Name, Age, City
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${user.name}, ${user.age}',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined,
                                    size: 13, color: subTextColor),
                                const SizedBox(width: 2),
                                Text(
                                  user.city,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: subTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Action: Pop out Audio & Video buttons when selected, or prompt button
                        if (isSelected)
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => _startCall(user, isVideo: false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F0FE).withOpacity(isDark ? 0.2 : 1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.call_rounded,
                                        size: 18, color: Color(0xFF2563EB)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: InkWell(
                                  onTap: () => _startCall(user, isVideo: true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFE5EC).withOpacity(isDark ? 0.2 : 1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.videocam_rounded,
                                        size: 18, color: primaryColor),
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 7),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF22222C) : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.touch_app_rounded,
                                    size: 14, color: subTextColor),
                                const SizedBox(width: 4),
                                Text(
                                  'Tap to Call',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: subTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
  }
}
