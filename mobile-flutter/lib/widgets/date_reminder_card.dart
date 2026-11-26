import 'package:flutter/material.dart';
import '../models/discovery_connect_models.dart';

Widget buildScheduledDateCard({
  required String partnerName,
  required int partnerAge,
  required String avatarUrl,
  required String dateTimeText,
  required String venueName,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.pinkAccent.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundImage: NetworkImage(avatarUrl),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date with $partnerName, $partnerAge',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$dateTimeText • $venueName',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Colors.pinkAccent,
          ),
        ],
      ),
    ),
  );
}

class DateReminderCard extends StatelessWidget {
  final ScheduledDateModel scheduledDate;
  final VoidCallback? onTap;

  const DateReminderCard({
    super.key,
    required this.scheduledDate,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return buildScheduledDateCard(
      partnerName: scheduledDate.nickname,
      partnerAge: 23,
      avatarUrl: scheduledDate.avatar,
      dateTimeText: 'Mon, 6:30 PM',
      venueName: scheduledDate.venue,
      onTap: onTap ?? () {},
    );
  }
}
