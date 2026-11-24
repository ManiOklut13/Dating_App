import 'package:flutter/material.dart';
import '../models/discovery_connect_models.dart';
import '../data/profiles_data.dart';

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1119),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF2E1E2B)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left: Partner's circular profile avatar (Ananya DP)
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFEC4899), width: 1.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: SafeProfileImage(
                  imageUrl: scheduledDate.avatar,
                  width: 44,
                  height: 44,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Middle: "Date Reminder" + "Mon, 6:30 PM" pill + subtitle "Olive Bistro, Jubilee Hills • Ananya"
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Date Reminder',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0x33EC4899),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: const Color(0x66EC4899)),
                        ),
                        child: const Text(
                          'Mon, 6:30 PM',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFFB7185),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${scheduledDate.venue} • ${scheduledDate.nickname}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9CA3AF),
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Right: Calendar icon button + NOV 16 pill badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF241822),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0x33EC4899)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_month, color: Color(0xFFEC4899), size: 16),
                  SizedBox(width: 4),
                  Text(
                    'NOV 16',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
