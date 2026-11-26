import 'package:flutter/material.dart';

/// Compact "Available Live Profiles" header + horizontal strip where tapping
/// an avatar toggles Audio Call and Video Call buttons underneath it.
class LiveProfilesStrip extends StatefulWidget {
  final List<Map<String, dynamic>> liveProfiles;
  final void Function(Map<String, dynamic> user, {required bool isVideo})
      onStartCall;

  const LiveProfilesStrip({
    super.key,
    required this.liveProfiles,
    required this.onStartCall,
  });

  @override
  State<LiveProfilesStrip> createState() => _LiveProfilesStripState();
}

class _LiveProfilesStripState extends State<LiveProfilesStrip> {
  String? _selectedUserKey;

  String _keyForUser(Map<String, dynamic> user, int index) {
    return (user['id'] as String?) ?? '${user['name']}_$index';
  }

  void _toggleSelection(String userKey) {
    setState(() {
      _selectedUserKey = (_selectedUserKey == userKey) ? null : userKey;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final headingColor =
        isDark ? Colors.white : (theme.textTheme.titleMedium?.color ?? Colors.black87);
    final hintColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.greenAccent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                'Available Live Profiles',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: headingColor,
                ),
              ),
              const Spacer(),
              Text(
                'Tap avatar to call',
                style: TextStyle(
                  fontSize: 11.5,
                  color: hintColor,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: widget.liveProfiles.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final liveUser = widget.liveProfiles[index];
              final userKey = _keyForUser(liveUser, index);
              final isSelected = _selectedUserKey == userKey;

              return GestureDetector(
                onTap: () => _toggleSelection(userKey),
                child: SizedBox(
                  width: 64,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFE94057)
                                    : Colors.greenAccent,
                                width: isSelected ? 2.4 : 2.0,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFFE94057)
                                            .withOpacity(0.35),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (liveUser['avatarBgColor'] as Color?) ??
                                    primary.withOpacity(0.15),
                              ),
                              child: Icon(
                                (liveUser['avatarIcon'] as IconData?) ??
                                    Icons.face_rounded,
                                size: 22,
                                color:
                                    (liveUser['avatarAccentColor'] as Color?) ??
                                        primary,
                              ),
                            ),
                          ),
                          if (!isSelected)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 11,
                                height: 11,
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: theme.scaffoldBackgroundColor,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (isSelected)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Tooltip(
                              message: 'Audio Call',
                              child: InkWell(
                                onTap: () => widget.onStartCall(
                                  liveUser,
                                  isVideo: false,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2563EB)
                                        .withOpacity(0.22),
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
                            ),
                            const SizedBox(width: 6),
                            Tooltip(
                              message: 'Video Call',
                              child: InkWell(
                                onTap: () => widget.onStartCall(
                                  liveUser,
                                  isVideo: true,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE94057)
                                        .withOpacity(0.22),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFE94057),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.videocam_rounded,
                                    size: 13,
                                    color: Color(0xFFE94057),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          liveUser['name'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white70 : Colors.black87,
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
      ],
    );
  }
}
