import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationModel {
  final String id;
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color iconColor;
  bool isUnread;

  _NotificationModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.iconColor,
    this.isUnread = true,
  });
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final String _filter = 'All'; // 'All' | 'Unread'

  final List<_NotificationModel> _notifications = [
    _NotificationModel(
      id: 'n1',
      title: 'Daily Connection Streak Active',
      subtitle: 'You are on a 4-day streak! Claim your +40 Rubies before midnight.',
      time: '10m ago',
      icon: Icons.local_fire_department,
      iconColor: const Color(0xFFF59E0B),
      isUnread: true,
    ),
    _NotificationModel(
      id: 'n2',
      title: 'Secret Admirer',
      subtitle: 'Someone in Bandra just sent you a Mega Crush.',
      time: '25m ago',
      icon: Icons.favorite,
      iconColor: const Color(0xFFEC4899),
      isUnread: true,
    ),
    _NotificationModel(
      id: 'n3',
      title: 'Upcoming Specialty Coffee Date',
      subtitle: 'Confirmed with Ananya for Mon, Nov 16 at Olive Bistro.',
      time: '1h ago',
      icon: Icons.calendar_month,
      iconColor: const Color(0xFF38BDF8),
      isUnread: false,
    ),
    _NotificationModel(
      id: 'n4',
      title: 'New Audio Prompt',
      subtitle: 'Kavya updated her voice introduction in Telugu & Hindi.',
      time: '3h ago',
      icon: Icons.mic,
      iconColor: const Color(0xFF22C55E),
      isUnread: false,
    ),
    _NotificationModel(
      id: 'n5',
      title: '500 Rubies Credited',
      subtitle: 'Popular Flame bundle payment processed successfully.',
      time: 'Yesterday',
      icon: Icons.diamond,
      iconColor: const Color(0xFFFB7185),
      isUnread: false,
    ),
  ];

  int get _unreadCount => _notifications.where((n) => n.isUnread).length;

  void _markAllRead() {
    setState(() {
      for (var n in _notifications) {
        n.isUnread = false;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications marked as read ✓')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == 'Unread'
        ? _notifications.where((n) => n.isUnread).toList()
        : _notifications;

    return Scaffold(
      backgroundColor: const Color(0xFF0D070C),
      body: SafeArea(
        child: Column(
          children: [
            // Header: < Back, "Notifications" (Activity & updates), "✓ Mark all read" button
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
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notifications',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Activity & updates',
                          style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                        ),
                      ],
                    ),
                  ),
                  if (_unreadCount > 0)
                    TextButton(
                      onPressed: _markAllRead,
                      child: const Text(
                        'Mark all read',
                        style: TextStyle(
                          color: Color(0xFFFB7185),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Notification Cards clean list
            Expanded(
              child: _notifications.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_none, size: 48, color: Color(0xFF6B7280)),
                          SizedBox(height: 12),
                          Text(
                            'No notifications yet',
                            style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: _notifications.length,
                      itemBuilder: (context, i) {
                        final n = filtered[i];
                        return GestureDetector(
                          onTap: () {
                            setState(() => n.isUnread = false);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B1119),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: n.isUnread ? const Color(0x66EC4899) : const Color(0xFF2E1E2B),
                              ),
                              boxShadow: n.isUnread
                                  ? const [
                                      BoxShadow(color: Color(0x26EC4899), blurRadius: 10, offset: Offset(0, 2)),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: n.iconColor.withValues(alpha: 0.15),
                                    border: Border.all(color: n.iconColor.withValues(alpha: 0.4)),
                                  ),
                                  child: Icon(n.icon, size: 20, color: n.iconColor),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            n.title,
                                            style: const TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                            ),
                                          ),
                                          if (n.isUnread)
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Color(0xFFEC4899),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        n.subtitle,
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          color: Color(0xFF9CA3AF),
                                          height: 1.35,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        n.time,
                                        style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
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
          ],
        ),
      ),
    );
  }
}
