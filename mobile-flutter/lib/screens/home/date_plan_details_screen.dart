import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/profiles_data.dart';
import '../../features/plan_date/models/memory_model.dart';
import '../../features/plan_date/models/plan_date_model.dart';
import '../../features/plan_date/providers/plan_date_providers.dart';
import '../../features/plan_date/screens/after_date_memories_screen.dart';
import '../../features/plan_date/screens/plan_date_screen.dart';
import '../../services/app_state_provider.dart';

class DatePlanDetailsScreen extends ConsumerStatefulWidget {
  const DatePlanDetailsScreen({super.key});

  @override
  ConsumerState<DatePlanDetailsScreen> createState() =>
      _DatePlanDetailsScreenState();
}

class _DatePlanDetailsScreenState extends ConsumerState<DatePlanDetailsScreen> {
  late DateTime _currentMonth;
  bool _stickerCreated = false;
  bool _monthInitialized = false;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(2026, 11);
  }

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

  Future<void> _openPlanNewDate() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PlanDateScreen()),
    );
  }

  Future<void> _openAddMemories(String dateId, DateMode mode) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AfterDateMemoriesScreen(
          dateId: dateId,
          mode: mode,
          popBackOnly: true,
        ),
      ),
    );
  }

  void _clearDatePlan() {
    ref.read(appStateProvider.notifier).clearDatePlans();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Date plan removed. Plan a new date anytime!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appStateProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final scaffoldBg =
        isDark ? const Color(0xFF0D070C) : theme.scaffoldBackgroundColor;
    final headerBg = isDark ? const Color(0xFF140A12) : Colors.white;
    final cardBg = isDark ? const Color(0xFF1B1119) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF2E1E2B) : Colors.grey.shade200;
    final primaryText = isDark ? Colors.white : const Color(0xFF181A24);
    final mutedText = isDark ? const Color(0xFF9CA3AF) : Colors.grey.shade600;
    final iconBtnBg =
        isDark ? const Color(0x1AFFFFFF) : const Color(0xFFF1F5F9);
    final iconBtnBorder =
        isDark ? const Color(0x26FFFFFF) : Colors.grey.shade300;
    final subtleBtnBg =
        isDark ? const Color(0xFF241822) : const Color(0xFFF8FAFC);

    if (!appState.hasDatePlan) {
      return Scaffold(
        backgroundColor: scaffoldBg,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(
                headerBg: headerBg,
                borderColor: borderColor,
                iconBtnBg: iconBtnBg,
                iconBtnBorder: iconBtnBorder,
                primaryText: primaryText,
                subtitle: 'No Active Plan',
                hasPlan: false,
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEC4899).withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.calendar_month_rounded,
                            size: 40,
                            color: Color(0xFFEC4899),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'No Date Plan Scheduled',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: primaryText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Plan a virtual or in-person date to view your full schedule, venue, and date memories here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: mutedText,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 22),
                        ElevatedButton.icon(
                          onPressed: _openPlanNewDate,
                          icon: const Icon(Icons.add_circle_outline_rounded),
                          label: const Text('Plan a Date'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final PlanDate? custom = appState.plannedDate;
    final scheduled = appState.scheduledDate ?? kDemoScheduledDate;

    final String dateId = custom?.id ?? scheduled.id;
    final DateMode dateMode = custom?.mode ?? DateMode.offline;
    final String partnerName =
        custom != null ? custom.partnerId : scheduled.nickname;
    final String avatarUrl = scheduled.avatar;
    final DateTime dateTime = custom?.startAt ?? scheduled.scheduledAt;
    final int durationMins = custom?.durationMin ?? scheduled.durationMins;
    final String venueTitle = custom != null
        ? (custom.spot?.name ??
            (custom.mode == DateMode.virtual
                ? 'Virtual YoUnMe Date Lounge'
                : 'Custom Meetup Spot'))
        : scheduled.venue;
    final String venueSubtitle = custom != null
        ? (custom.spot?.address ??
            (custom.notes.proposal.isNotEmpty
                ? custom.notes.proposal
                : 'Confirmed reservation for $partnerName'))
        : scheduled.tableReservation;
    final String activityLabel = custom != null
        ? '${custom.typeId.replaceAll('_', ' ')} (${custom.mode.name})'
        : scheduled.activityType;
    final String dressCodeLabel =
        custom?.dressCode ?? scheduled.dressCode;
    final String soundtrackLabel = scheduled.sharedPlaylist;

    if (!_monthInitialized) {
      _currentMonth = DateTime(dateTime.year, dateTime.month);
      _monthInitialized = true;
    }

    final Memory memory = ref.watch(memoryFormProvider(dateId));
    final bool hasSavedMemory = memory.rating > 0 ||
        memory.photoPaths.isNotEmpty ||
        memory.tags.isNotEmpty ||
        memory.note.trim().isNotEmpty;

    final List<_ScheduleStep> scheduleSteps = _buildScheduleSteps(
      dateTime: dateTime,
      durationMins: durationMins,
      custom: custom,
      venueTitle: venueTitle,
    );

    final formattedDateTime =
        DateFormat('EEEE, MMM d, hh:mm a').format(dateTime);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(
              headerBg: headerBg,
              borderColor: borderColor,
              iconBtnBg: iconBtnBg,
              iconBtnBorder: iconBtnBorder,
              primaryText: primaryText,
              subtitle: custom != null ? 'Scheduled Date Plan' : 'Confirmed Itinerary',
              hasPlan: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Partner Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? const Color(0x40000000)
                                : const Color(0x12000000),
                            blurRadius: 18,
                            offset: const Offset(0, 4),
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
                                  border: Border.all(
                                    color: const Color(0xFFEC4899),
                                    width: 2,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(28),
                                  child: SafeProfileImage(
                                    imageUrl: avatarUrl,
                                    width: 56,
                                    height: 56,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            'Date with $partnerName',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                              color: primaryText,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Icon(
                                          Icons.verified,
                                          size: 16,
                                          color: Color(0xFF38BDF8),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0x26F59E0B),
                                            borderRadius:
                                                BorderRadius.circular(999),
                                            border: Border.all(
                                              color: const Color(0x80F59E0B),
                                            ),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.local_fire_department,
                                                size: 12,
                                                color: Color(0xFFF59E0B),
                                              ),
                                              SizedBox(width: 3),
                                              Text(
                                                '7-Day Streak 🔥',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFFF59E0B),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0x2622C55E),
                                            borderRadius:
                                                BorderRadius.circular(999),
                                            border: Border.all(
                                              color: const Color(0x8022C55E),
                                            ),
                                          ),
                                          child: Text(
                                            custom != null
                                                ? '${dateMode == DateMode.virtual ? 'Virtual' : 'In-Person'} Date'
                                                : '98% Compatibility',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF16A34A),
                                            ),
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
                                      SnackBar(
                                        content: Text('Calling $partnerName...'),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: subtleBtnBg,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: borderColor),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.call,
                                          size: 16,
                                          color: Color(0xFF22C55E),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Call',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: primaryText,
                                          ),
                                        ),
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
                                      SnackBar(
                                        content: Text(
                                          'Opening chat with $partnerName...',
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFE11D48),
                                          Color(0xFFEC4899),
                                        ],
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.chat_bubble_outline,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'Chat',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
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

                    // DATE & TIME Card (prominent at top so user sees Date & Time right away)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_month,
                            color: Color(0xFFEC4899),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'DATE & TIME • DURATION',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: mutedText,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  formattedDateTime,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: primaryText,
                                  ),
                                ),
                                Text(
                                  'Reserved for $durationMins minutes',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF16A34A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Monthly Calendar highlighting the scheduled date day
                    _buildMonthlyCalendar(
                      scheduledAt: dateTime,
                      partnerName: partnerName,
                      cardBg: cardBg,
                      borderColor: borderColor,
                      primaryText: primaryText,
                      mutedText: mutedText,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 14),

                    // FULL SCHEDULE (PLANNED DATE ITINERARY)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 16,
                                color: Color(0xFFEC4899),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'FULL SCHEDULE & ITINERARY',
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
                          ...List.generate(scheduleSteps.length, (i) {
                            final step = scheduleSteps[i];
                            return _timelineItem(
                              step.time,
                              step.title,
                              step.subtitle,
                              primaryText: primaryText,
                              mutedText: mutedText,
                              lineColor: borderColor,
                              isFirst: i == 0,
                              isLast: i == scheduleSteps.length - 1,
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ADD MEMORIES DETAILS SECTION
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? const [Color(0xFF251020), Color(0xFF1B1119)]
                              : const [Color(0xFFFFF1F5), Color(0xFFFFF8FA)],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0x66EC4899)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0x33EC4899),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Text(
                                    '📸',
                                    style: TextStyle(fontSize: 22),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Date Memories & Stickers',
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w800,
                                        color: primaryText,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Add photos, vibe rating, notes & custom date stickers',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: mutedText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (hasSavedMemory) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      if (memory.rating > 0) ...[
                                        ...List.generate(
                                          5,
                                          (idx) => Icon(
                                            idx < memory.rating
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            size: 14,
                                            color: const Color(0xFFE11D48),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${memory.rating}/5 Rating',
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w700,
                                            color: primaryText,
                                          ),
                                        ),
                                      ],
                                      const Spacer(),
                                      if (memory.photoPaths.isNotEmpty)
                                        Text(
                                          '${memory.photoPaths.length} photo(s)',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: mutedText,
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (memory.tags.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: memory.tags
                                          .map(
                                            (t) => Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0x1AEC4899),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                t,
                                                style: const TextStyle(
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFFE11D48),
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ],
                                  if (memory.note.trim().isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      memory.note.trim(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: primaryText,
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      _openAddMemories(dateId, dateMode),
                                  child: Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFE11D48),
                                          Color(0xFFEC4899),
                                        ],
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      hasSavedMemory
                                          ? 'Edit Memories'
                                          : '+ Add Memories',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  setState(() => _stickerCreated = true);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        '✨ Custom Date Sticker created & saved to your pack!',
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  height: 40,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0x66EC4899),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    _stickerCreated
                                        ? '✓ Sticker Added'
                                        : 'Create Sticker',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFE11D48),
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

                    // CONFIRMED VENUE Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Color(0xFF38BDF8),
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CONFIRMED VENUE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: mutedText,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  venueTitle,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: primaryText,
                                  ),
                                ),
                                Text(
                                  venueSubtitle,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: mutedText,
                                  ),
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
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'VIBE & EXPERIENCE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: mutedText,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.palette_outlined,
                                size: 14,
                                color: Color(0xFFF59E0B),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Activity: $activityLabel',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: primaryText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.checkroom_outlined,
                                size: 14,
                                color: Color(0xFFEC4899),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Dress Code: $dressCodeLabel',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: primaryText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.music_note,
                                size: 14,
                                color: Color(0xFF38BDF8),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Curated Soundtrack: $soundtrackLabel',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: primaryText,
                                  ),
                                ),
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

  Widget _buildHeader({
    required Color headerBg,
    required Color borderColor,
    required Color iconBtnBg,
    required Color iconBtnBorder,
    required Color primaryText,
    required String subtitle,
    required bool hasPlan,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: headerBg,
        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBtnBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: iconBtnBorder),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 16,
                color: primaryText,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date Plan Details',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: primaryText,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFEC4899),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _openPlanNewDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: iconBtnBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: iconBtnBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.add_rounded,
                    size: 16,
                    color: Color(0xFFEC4899),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    'Plan',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: primaryText,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (hasPlan) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _clearDatePlan,
              child: Tooltip(
                message: 'Cancel Date Plan',
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconBtnBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: iconBtnBorder),
                  ),
                  child: const Icon(
                    Icons.event_busy_outlined,
                    size: 17,
                    color: Color(0xFFEF4444),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<_ScheduleStep> _buildScheduleSteps({
    required DateTime dateTime,
    required int durationMins,
    required PlanDate? custom,
    required String venueTitle,
  }) {
    final fmt = DateFormat('hh:mm a');
    if (custom != null && custom.todos.isNotEmpty) {
      final stepMins = (durationMins / custom.todos.length).round().clamp(15, 60);
      return List.generate(custom.todos.length, (i) {
        final t = dateTime.add(Duration(minutes: i * stepMins));
        return _ScheduleStep(
          time: fmt.format(t),
          title: custom.todos[i].text,
          subtitle: 'Planned activity at $venueTitle',
        );
      });
    }

    final t1 = dateTime;
    final t2 = dateTime.add(Duration(minutes: (durationMins * 0.25).round()));
    final t3 = dateTime.add(Duration(minutes: (durationMins * 0.6).round()));
    final t4 = dateTime.add(Duration(minutes: durationMins));
    return [
      _ScheduleStep(
        time: fmt.format(t1),
        title: 'Arrival & Welcome Drinks',
        subtitle: 'Meet at $venueTitle entrance lounge',
      ),
      _ScheduleStep(
        time: fmt.format(t2),
        title: 'Artisan Dinner & Appetisers',
        subtitle: 'Woodfired sourdough flatbreads & gourmet mocktails',
      ),
      _ScheduleStep(
        time: fmt.format(t3),
        title: 'Specialty Coffee Tasting & Vinyls',
        subtitle: 'Explore curated brews while browsing jazz classics',
      ),
      _ScheduleStep(
        time: fmt.format(t4),
        title: 'Promenade Stroll & Goodnight Spark',
        subtitle: 'Cozy evening walk with warm cinnamon buns',
      ),
    ];
  }

  Widget _buildMonthlyCalendar({
    required DateTime scheduledAt,
    required String partnerName,
    required Color cardBg,
    required Color borderColor,
    required Color primaryText,
    required Color mutedText,
    required bool isDark,
  }) {
    final daysInMonth =
        DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month);
    final firstWeekdayOffset =
        DateTime(_currentMonth.year, _currentMonth.month, 1).weekday % 7;
    final totalCells = firstWeekdayOffset + daysInMonth;
    final now = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, color: primaryText),
                onPressed: _prevMonth,
              ),
              Text(
                DateFormat('MMM yyyy').format(_currentMonth),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: primaryText,
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, color: primaryText),
                onPressed: _nextMonth,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((d) {
              return SizedBox(
                width: 32,
                child: Text(
                  d,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: mutedText,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalCells,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1.1,
            ),
            itemBuilder: (context, index) {
              if (index < firstWeekdayOffset) {
                return const SizedBox.shrink();
              }
              final day = index - firstWeekdayOffset + 1;
              final isDatePlanDay =
                  _currentMonth.year == scheduledAt.year &&
                      _currentMonth.month == scheduledAt.month &&
                      day == scheduledAt.day;
              final isToday = _currentMonth.year == now.year &&
                  _currentMonth.month == now.month &&
                  day == now.day;

              BoxDecoration decoration;
              TextStyle textStyle;

              if (isDatePlanDay) {
                decoration = BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE11D48), Color(0xFFEC4899)],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x66EC4899),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                );
                textStyle = const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                );
              } else if (isToday) {
                decoration = BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFEC4899),
                    width: 1.5,
                  ),
                  color: const Color(0x26EC4899),
                );
                textStyle = const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFEC4899),
                );
              } else {
                decoration = BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: isDark
                      ? const Color(0x0AFFFFFF)
                      : const Color(0xFFF8FAFC),
                );
                textStyle = TextStyle(
                  fontSize: 12,
                  color: primaryText,
                );
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
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFEC4899),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${DateFormat('MMM d').format(scheduledAt)}: Date with $partnerName',
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFEC4899),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timelineItem(
    String time,
    String title,
    String subtitle, {
    required Color primaryText,
    required Color mutedText,
    required Color lineColor,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 64,
            child: Text(
              time,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFFEC4899),
              ),
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
                    color: lineColor,
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
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: primaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: mutedText),
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

class _ScheduleStep {
  final String time;
  final String title;
  final String subtitle;

  const _ScheduleStep({
    required this.time,
    required this.title,
    required this.subtitle,
  });
}
