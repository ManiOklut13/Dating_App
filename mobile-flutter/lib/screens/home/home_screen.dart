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
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}