import 'package:flutter/material.dart';
import '../../data/profiles_data.dart';

class DatePlanDetailsScreen extends StatefulWidget {
  const DatePlanDetailsScreen({super.key});

  @override
  State<DatePlanDetailsScreen> createState() => _DatePlanDetailsScreenState();
}

class _DatePlanDetailsScreenState extends State<DatePlanDetailsScreen> {
  DateTime _currentMonth = DateTime(2026, 11);
  bool _stickerCreated = false;

  void _prevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final d = demoScheduledDate;

    return Scaffold(
      backgroundColor: const Color(0xFF0D070C),
      body: SafeArea(
        child: Column(
          children: [
            // Header: < Back, "Date Plan Details" (Confirmed Itinerary), Share icon
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF140A12),
                border: Border(bottom: BorderSide(color: Color(0xFF2E1E2B), width: 1)),
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
                          'Date Plan Details',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Confirmed Itinerary',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFEC4899),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Date Plan link copied to clipboard! 📋')),
                      );
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0x1AFFFFFF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0x26FFFFFF)),
                      ),
                      child: const Icon(Icons.share_outlined, size: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Partner Card: "Date with Ananya", "7-Day Connection Streak 🔥", "98% Compatibility Vibe", Call and Chat buttons
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B1119),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF2E1E2B)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x40000000),
                            blurRadius: 18,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFEC4899), width: 2),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(28),
                                  child: SafeProfileImage(imageUrl: d.avatar, width: 56, height: 56),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Date with ${d.nickname}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Icon(Icons.verified, size: 16, color: Color(0xFF38BDF8)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0x26F59E0B),
                                            borderRadius: BorderRadius.circular(999),
                                            border: Border.all(color: const Color(0x80F59E0B)),
                                          ),
                                          child: const Row(
                                            children: [
                                              Icon(Icons.local_fire_department, size: 12, color: Color(0xFFF59E0B)),
                                              SizedBox(width: 3),
                                              Text(
                                                '7-Day Streak 🔥',
                                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFF59E0B)),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0x2622C55E),
                                            borderRadius: BorderRadius.circular(999),
                                            border: Border.all(color: const Color(0x8022C55E)),
                                          ),
                                          child: const Text(
                                            '98% Compatibility',
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF22C55E)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Calling ${d.nickname}...')),
                                    );
                                  },
                                  child: Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF241822),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFF2E1E2B)),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.call, size: 16, color: Color(0xFF22C55E)),
                                        SizedBox(width: 6),
                                        Text('Call', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Opening chat with ${d.nickname}...')),
                                    );
                                  },
                                  child: Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFE11D48), Color(0xFFEC4899)],
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.chat_bubble_outline, size: 16, color: Colors.white),
                                        SizedBox(width: 6),
                                        Text('Chat', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // "Make Memories 📸" banner with "Create Sticker" pink button
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF251020), Color(0xFF1B1119)],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0x66EC4899)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0x33EC4899),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text('📸', style: TextStyle(fontSize: 22)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Make Memories 📸',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Generate custom avatar date stickers',
                                  style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() => _stickerCreated = true);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('✨ Custom Date Sticker created & saved to your pack!')),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFE11D48), Color(0xFFEC4899)],
                                ),
                              ),
                              child: Text(
                                _stickerCreated ? '✓ Sticker Added' : 'Create Sticker',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Single clean Monthly Calendar (Nov 2026 with < > month arrows, 16 highlighted in pink as "Date with Ananya", 13 outlined as "Today")
                    _buildMonthlyCalendar(),
                    const SizedBox(height: 14),

                    // PLANNED DATE ITINERARY timeline
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B1119),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF2E1E2B)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.schedule, size: 16, color: Color(0xFFEC4899)),
                              SizedBox(width: 8),
                              Text(
                                'PLANNED DATE ITINERARY',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: Color(0xFFEC4899),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _timelineItem('07:00 PM', 'Arrival & Welcome Drinks', 'Meet by the vintage vinyl display lounge', isFirst: true),
                          _timelineItem('07:30 PM', 'Artisan Dinner & Appetisers', 'Woodfired sourdough flatbreads & gourmet mocktails'),
                          _timelineItem('08:30 PM', 'Specialty Coffee Tasting & Vinyls', 'Explore curated subko brews while browsing jazz classics'),
                          _timelineItem('09:30 PM', 'Promenade Stroll & Goodnight Spark', 'Cozy seaside promenade walk with warm cinnamon buns', isLast: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // DATE & DURATION Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B1119),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF2E1E2B)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.calendar_month, color: Color(0xFFEC4899), size: 22),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'DATE & DURATION',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF9CA3AF), letterSpacing: 0.5),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Monday, Nov 16, 05:15 PM',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
                                ),
                                Text(
                                  'Reserved for 120 minutes',
                                  style: TextStyle(fontSize: 11, color: Color(0xFF22C55E)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // CONFIRMED VENUE Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B1119),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF2E1E2B)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: Color(0xFF38BDF8), size: 22),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'CONFIRMED VENUE',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF9CA3AF), letterSpacing: 0.5),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  d.venue,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
                                ),
                                Text(
                                  d.tableReservation,
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // VIBE & EXPERIENCE Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B1119),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF2E1E2B)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'VIBE & EXPERIENCE',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF9CA3AF), letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.palette_outlined, size: 14, color: Color(0xFFF59E0B)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text('Activity: ${d.activityType}', style: const TextStyle(fontSize: 11.5, color: Colors.white)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.checkroom_outlined, size: 14, color: Color(0xFFEC4899)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text('Dress Code: ${d.dressCode}', style: const TextStyle(fontSize: 11.5, color: Colors.white)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.music_note, size: 14, color: Color(0xFF38BDF8)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text('Curated Soundtrack: ${d.sharedPlaylist}', style: const TextStyle(fontSize: 11.5, color: Colors.white)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyCalendar() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1119),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2E1E2B)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white),
                onPressed: _prevMonth,
              ),
              Text(
                'Nov 2026',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white),
                onPressed: _nextMonth,
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Day names
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((d) {
              return SizedBox(
                width: 32,
                child: Text(d, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF))),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          // Days grid for Nov 2026 (Nov 1 is Sunday)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 30,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1.1,
            ),
            itemBuilder: (context, index) {
              final day = index + 1;
              final isDatePlanDay = day == 16;
              final isToday = day == 13;

              BoxDecoration decoration;
              TextStyle textStyle;

              if (isDatePlanDay) {
                decoration = BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE11D48), Color(0xFFEC4899)],
                  ),
                  boxShadow: const [
                    BoxShadow(color: Color(0x66EC4899), blurRadius: 8, offset: Offset(0, 2)),
                  ],
                );
                textStyle = const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white);
              } else if (isToday) {
                decoration = BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFEC4899), width: 1.5),
                  color: const Color(0x26EC4899),
                );
                textStyle = const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFEC4899));
              } else {
                decoration = BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0x0AFFFFFF),
                );
                textStyle = const TextStyle(fontSize: 12, color: Color(0xFFE2E8F0));
              }

              return Container(
                alignment: Alignment.center,
                decoration: decoration,
                child: Text('$day', style: textStyle),
              );
            },
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFEC4899))),
              const SizedBox(width: 6),
              const Text('16: Date with Ananya', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFFEC4899))),
              const SizedBox(width: 14),
              Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFEC4899)))),
              const SizedBox(width: 6),
              const Text('13: Today', style: TextStyle(fontSize: 10.5, color: Color(0xFF9CA3AF))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timelineItem(String time, String title, String subtitle, {bool isFirst = false, bool isLast = false}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              time,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFEC4899)),
            ),
          ),
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFEC4899),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: const Color(0xFF2E1E2B),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
