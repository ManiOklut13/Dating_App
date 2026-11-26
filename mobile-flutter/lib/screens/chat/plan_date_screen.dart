import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../data/profiles_data.dart';
import '../../models/chat_profile_models.dart';
import '../../services/app_data_service.dart';
import '../../services/chat_list_provider.dart';
import 'date_plan_models.dart';
import 'plan_date_chooser_sheet.dart';
import 'plan_date_provider.dart';
import 'date_proposed_screen.dart';

/// Full-screen Plan a Date planner matching Images 1-4 with full Offline Dating flow.
class PlanDateScreen extends ConsumerStatefulWidget {
  const PlanDateScreen({super.key, required this.partner});

  final ChatConversationModel partner;

  @override
  ConsumerState<PlanDateScreen> createState() => _PlanDateScreenState();
}

class _PlanDateScreenState extends ConsumerState<PlanDateScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final TextEditingController _todoCtrl = TextEditingController();
  final TextEditingController _proposalNotesCtrl = TextEditingController();
  final TextEditingController _partnerNotesCtrl = TextEditingController();
  final TextEditingController _meetupSpotCtrl = TextEditingController();

  late ChatConversationModel _partner;
  late DateTime _dateTime;
  late DateTime _month;
  DateMode _mode = DateMode.offline; // Default to Offline mode as shown in screenshots
  DateTypeOption _type = DateTypeOption.movie;
  int _duration = 60;
  late List<TodoItem> _todos;
  bool _todosEdited = false;
  int _proposerPercent = 50;
  String _selectedSplitPreset = '50/50';
  bool _showResults = false;
  String _selectedDressCode = 'Smart casual';
  String _selectedSpot = '';

  @override
  void initState() {
    super.initState();
    _partner = widget.partner;
    // Default to Thursday, 26 November 2026, 19:30 (7:30 PM) matching Screenshots 1, 2, 3
    _dateTime = DateTime(2026, 11, 26, 19, 30);
    _month = DateTime(2026, 11, 1);
    _todos = defaultDateTodos(_mode, _type);
    _proposalNotesCtrl.addListener(() => setState(() {}));
    _partnerNotesCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _todoCtrl.dispose();
    _proposalNotesCtrl.dispose();
    _partnerNotesCtrl.dispose();
    _meetupSpotCtrl.dispose();
    super.dispose();
  }

  void _setMode(DateMode mode) {
    var type = _type;
    if (!type.modes.contains(mode)) {
      type = DateTypeOption.optionsFor(mode).first;
    }
    setState(() {
      _mode = mode;
      _type = type;
      if (!_todosEdited) _todos = defaultDateTodos(mode, type);
    });
  }

  void _setType(DateTypeOption type) {
    setState(() {
      _type = type;
      if (!_todosEdited) _todos = defaultDateTodos(_mode, type);
    });
  }

  void _setDateTime(DateTime value) {
    setState(() {
      _dateTime = value;
      _month = DateTime(_dateTime.year, _dateTime.month);
    });
  }

  void _setDate(DateTime day) {
    _setDateTime(DateTime(
      day.year,
      day.month,
      day.day,
      _dateTime.hour,
      _dateTime.minute,
    ));
  }

  void _setTimeSlot(int hour, int minute) {
    _setDateTime(DateTime(
      _dateTime.year,
      _dateTime.month,
      _dateTime.day,
      hour,
      minute,
    ));
  }

  void _jumpToToday() {
    _setDate(DateTime(2026, 11, 26));
    setState(() {
      _month = DateTime(2026, 11, 1);
    });
  }

  void _onMonthChanged(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta);
    });
  }

  void _setDuration(int minutes) =>
      setState(() => _duration = minutes.clamp(15, 480));

  void _toggleTodo(TodoItem todo) {
    setState(() {
      _todos = _todos
          .map((item) =>
              item.id == todo.id ? item.copyWith(done: !item.done) : item)
          .toList();
      _todosEdited = true;
    });
  }

  void _addTodo(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    setState(() {
      _todos = [
        ..._todos,
        TodoItem(
          id: 'todo-${DateTime.now().microsecondsSinceEpoch}',
          text: trimmed,
          done: false,
        ),
      ];
      _todosEdited = true;
    });
    _todoCtrl.clear();
  }

  void _setSplitPreset(String label) {
    setState(() {
      _selectedSplitPreset = label;
      switch (label) {
        case '50/50':
          _proposerPercent = 50;
          break;
        case '70/30':
          _proposerPercent = 70;
          break;
        case '30/70':
          _proposerPercent = 30;
          break;
        case 'I pay all':
          _proposerPercent = 100;
          break;
      }
    });
  }

  Future<void> _openPartnerChooser() async {
    final picked = await showPlanDateChooser(context);
    if (picked == null || !mounted) return;
    setState(() {
      _partner = picked;
      _showResults = false;
    });
    _searchCtrl.clear();
    _searchFocus.unfocus();
  }

  void _selectPartner(ChatConversationModel chat) {
    setState(() {
      _partner = chat;
      _showResults = false;
    });
    _searchCtrl.clear();
    _searchFocus.unfocus();
  }

  void _selectSpot(String spot) {
    setState(() {
      _selectedSpot = spot;
      _meetupSpotCtrl.text = spot;
    });
  }

  void _sendInvite() {
    final now = DateTime.now();
    final invite = DateInvite(
      id: 'invite-${now.microsecondsSinceEpoch}',
      partner: _partner,
      mode: _mode,
      type: _type,
      dateTime: _dateTime,
      durationMinutes: _duration,
      todos: List<TodoItem>.from(_todos),
      createdAt: now,
    );
    ref.read(dateInvitesProvider.notifier).add(invite);
    AppDataService.instance.sendMessage(
      _partner.id,
      'Date invite: ${_type.label} · ${invite.modeLabel}',
      type: 'date_plan',
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DateProposedScreen(
          partnerName: _partner.name,
          dateTitle: _type.label,
          dateTime: _dateTime,
          duration: _duration,
          splitLabel: '$_proposerPercent% / ${100 - _proposerPercent}%',
          coinCost: 150,
          proposalNotes: _proposalNotesCtrl.text,
          partnerNotes: _partnerNotesCtrl.text,
          todos: List<TodoItem>.from(_todos),
          mode: _mode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chats = ref.watch(chatConversationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0711),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const Positioned.fill(child: _BackgroundGlows()),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // 0. Top Header Bar
                      _PlannerHeader(
                        onClose: () => Navigator.of(context).maybePop(),
                        onCalendar: _openPartnerChooser,
                      ),
                      const SizedBox(height: 18),

                      // 1. "YOUR DATE PAIR" Card
                      _DatePairCard(
                        partner: _partner,
                        chats: chats,
                        searchController: _searchCtrl,
                        searchFocus: _searchFocus,
                        showResults: _showResults,
                        onSearchChanged: () =>
                            setState(() => _showResults = true),
                        onPick: _selectPartner,
                        onSwap: _openPartnerChooser,
                      ),
                      const SizedBox(height: 18),

                      // 2. "Date Mode" Card
                      _DateModeCard(
                        mode: _mode,
                        onModeChanged: _setMode,
                      ),
                      const SizedBox(height: 22),

                      // 3. "Date Type" Horizontal Selector
                      _DateTypeCarousel(
                        mode: _mode,
                        selected: _type,
                        onSelected: _setType,
                      ),
                      const SizedBox(height: 20),

                      // 4. "Meetup Spot" Card (Displayed for Offline mode)
                      if (_mode == DateMode.offline) ...[
                        _MeetupSpotCard(
                          searchController: _meetupSpotCtrl,
                          selectedSpot: _selectedSpot,
                          onSpotSelected: _selectSpot,
                        ),
                        const SizedBox(height: 20),
                      ],

                      // 5. "Date & Time" Calendar & "Preferred Time" Card
                      _DateTimeAndPreferredTimeCard(
                        dateTime: _dateTime,
                        month: _month,
                        onMonthChanged: _onMonthChanged,
                        onDateSelected: _setDate,
                        onToday: _jumpToToday,
                        onTimeSlotSelected: _setTimeSlot,
                      ),
                      const SizedBox(height: 18),

                      // 5b. "Duration" Card
                      _DurationCard(
                        duration: _duration,
                        onDurationPreset: _setDuration,
                      ),
                      const SizedBox(height: 18),

                      // 6. "Dress Code & Notes" Card
                      _DressCodeAndNotesCard(
                        selectedDressCode: _selectedDressCode,
                        onDressCodeChanged: (val) =>
                            setState(() => _selectedDressCode = val),
                        proposalController: _proposalNotesCtrl,
                        partnerController: _partnerNotesCtrl,
                      ),
                      const SizedBox(height: 18),

                      // 7. "To Do's" Card
                      _TodoCard(
                        todos: _todos,
                        controller: _todoCtrl,
                        onToggle: _toggleTodo,
                        onAdd: () => _addTodo(_todoCtrl.text),
                      ),
                      const SizedBox(height: 18),

                      // 8. "Split Bill" Card
                      _SplitBillCard(
                        proposerPercent: _proposerPercent,
                        partnerName: _partner.name,
                        selectedPreset: _selectedSplitPreset,
                        onPreset: _setSplitPreset,
                      ),
                      const SizedBox(height: 24),
                    ]),
                  ),
                ),
              ],
            ),
          ),

          // Sticky Bottom CTA Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _PlanDateBottomBar(
              partnerName: _partner.name,
              enabled: true,
              onPressed: _sendInvite,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Background Glows
// ─────────────────────────────────────────────────────────────────────────────
class _BackgroundGlows extends StatelessWidget {
  const _BackgroundGlows();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -60,
            width: 320,
            height: 320,
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [Color(0x35E9297B), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            top: 280,
            left: -80,
            width: 260,
            height: 260,
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [Color(0x228B5CF6), Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 0. Top Header Bar
// ─────────────────────────────────────────────────────────────────────────────
class _PlannerHeader extends StatelessWidget {
  const _PlannerHeader({required this.onClose, required this.onCalendar});

  final VoidCallback onClose;
  final VoidCallback onCalendar;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Semantics(
          button: true,
          label: 'Back',
          child: GestureDetector(
            onTap: onClose,
            child: const _HeaderButton(
              icon: Icons.chevron_left,
              color: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Plan a ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  'Date',
                  style: TextStyle(
                    color: Color(0xFFDF1B7C),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
          ),
        ),
        Semantics(
          button: true,
          label: 'Partner options',
          child: GestureDetector(
            onTap: onCalendar,
            child: const _HeaderButton(
              icon: Icons.favorite_border,
              color: Color(0xFFDF1B7C),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF180F24),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2D1D42)),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. "YOUR DATE PAIR" Card
// ─────────────────────────────────────────────────────────────────────────────
class _DatePairCard extends StatelessWidget {
  const _DatePairCard({
    required this.partner,
    required this.chats,
    required this.searchController,
    required this.searchFocus,
    required this.showResults,
    required this.onSearchChanged,
    required this.onPick,
    required this.onSwap,
  });

  final ChatConversationModel partner;
  final List<ChatConversationModel> chats;
  final TextEditingController searchController;
  final FocusNode searchFocus;
  final bool showResults;
  final VoidCallback onSearchChanged;
  final ValueChanged<ChatConversationModel> onPick;
  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) {
    final userPhoto = AppDataService.instance.userProfile.photos.first;
    final query = searchController.text.trim().toLowerCase();
    final matches = query.isEmpty
        ? chats
        : chats.where((c) => c.name.toLowerCase().contains(query)).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1526),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2C233C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: Text(
              'YOUR DATE PAIR',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                color: Color(0xFFF0548B),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Overlapping card pair matching Image 1
          SizedBox(
            height: 170,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final totalWidth = constraints.maxWidth;
                final cardWidth = totalWidth * 0.58;

                return Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Left "You" Card
                    Positioned(
                      left: 10,
                      top: 4,
                      bottom: 4,
                      width: cardWidth,
                      child: Transform.rotate(
                        angle: -0.05,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFA96BFF), Color(0xFF7E38F3)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFA96BFF).withValues(alpha: 0.25),
                                blurRadius: 16,
                                offset: const Offset(-2, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Stack(
                            children: [
                              Positioned(
                                left: 4,
                                top: 4,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  padding: const EdgeInsets.all(2),
                                  child: ClipOval(
                                    child: SafeProfileImage(
                                      imageUrl: userPhoto,
                                      width: 28,
                                      height: 28,
                                    ),
                                  ),
                                ),
                              ),
                              const Positioned(
                                left: 8,
                                bottom: 8,
                                child: Text(
                                  'You',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Right Partner Photo Card (Overlapping)
                    Positioned(
                      right: 10,
                      top: 4,
                      bottom: 4,
                      width: cardWidth,
                      child: GestureDetector(
                        onTap: onSwap,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.45),
                                blurRadius: 18,
                                offset: const Offset(4, 6),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                _PartnerImage(partner: partner),
                                const DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Color(0xCC000000),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      stops: [0.45, 1.0],
                                    ),
                                  ),
                                ),
                                // Online indicator
                                Positioned(
                                  right: 12,
                                  top: 12,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF22C55E),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                                // Partner Name
                                Positioned(
                                  left: 12,
                                  right: 8,
                                  bottom: 12,
                                  child: Text(
                                    partner.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Centered Heart Badge
                    Center(
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFC41E72),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFC41E72).withValues(alpha: 0.5),
                              blurRadius: 14,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.favorite_border,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Search bar
          Stack(
            clipBehavior: Clip.none,
            children: [
              TextField(
                controller: searchController,
                focusNode: searchFocus,
                onChanged: (_) => onSearchChanged(),
                onTap: onSearchChanged,
                style: const TextStyle(color: Colors.white, fontSize: 13.5),
                decoration: InputDecoration(
                  hintText: 'Search for partner...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF9A91A8),
                    fontSize: 13.5,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF9A91A8),
                    size: 20,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF130E1C),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF2C233C)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF2C233C)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFFE9297B),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              if (showResults && searchFocus.hasFocus)
                Positioned(
                  left: 0,
                  right: 0,
                  top: 54,
                  child: Material(
                    elevation: 12,
                    color: const Color(0xFF1B1526),
                    borderRadius: BorderRadius.circular(14),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 210),
                      child: matches.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'No matching chats',
                                style: TextStyle(color: Color(0xFF9A91A8)),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              itemCount: matches.length,
                              itemBuilder: (context, index) {
                                final chat = matches[index];
                                return ListTile(
                                  leading: ClipOval(
                                    child: SizedBox(
                                      width: 32,
                                      height: 32,
                                      child: _PartnerImage(partner: chat),
                                    ),
                                  ),
                                  title: Text(
                                    chat.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  onTap: () => onPick(chat),
                                );
                              },
                            ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PartnerImage extends StatelessWidget {
  const _PartnerImage({required this.partner});

  final ChatConversationModel partner;

  @override
  Widget build(BuildContext context) {
    if (partner.avatarAsset != null) {
      return Image.asset(
        partner.avatarAsset!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackAvatar(),
      );
    }
    return _fallbackAvatar();
  }

  Widget _fallbackAvatar() {
    return Container(
      color: const Color(0xFF2B1D3D),
      alignment: Alignment.center,
      child: Text(
        partner.name.isEmpty ? '?' : partner.name.substring(0, 1).toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. "Date Mode" Card
// ─────────────────────────────────────────────────────────────────────────────
class _DateModeCard extends StatelessWidget {
  const _DateModeCard({required this.mode, required this.onModeChanged});

  final DateMode mode;
  final ValueChanged<DateMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final hint = mode == DateMode.offline ? 'Meet in person' : 'Video call from anywhere';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1526),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2C233C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Date Mode',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                hint,
                style: const TextStyle(
                  color: Color(0xFF9A91A8),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF130E1C),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2C233C)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ModeSegment(
                    label: 'Virtual',
                    icon: Icons.videocam_outlined,
                    selected: mode == DateMode.virtual,
                    onTap: () => onModeChanged(DateMode.virtual),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _ModeSegment(
                    label: 'Offline',
                    icon: Icons.location_on_outlined,
                    selected: mode == DateMode.offline,
                    onTap: () => onModeChanged(DateMode.offline),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeSegment extends StatelessWidget {
  const _ModeSegment({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFC81D77) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: selected ? Border.all(color: Colors.white, width: 1.5) : null,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFFC81D77).withValues(alpha: 0.45),
                    blurRadius: 14,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? Colors.white : const Color(0xFF9A91A8),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF9A91A8),
                fontSize: 14,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. "Date Type" Horizontal Selector
// ─────────────────────────────────────────────────────────────────────────────
class _DateTypeCarousel extends StatelessWidget {
  const _DateTypeCarousel({
    required this.mode,
    required this.selected,
    required this.onSelected,
  });

  final DateMode mode;
  final DateTypeOption selected;
  final ValueChanged<DateTypeOption> onSelected;

  @override
  Widget build(BuildContext context) {
    final options = DateTypeOption.optionsFor(mode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Date Type',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Swipe for more >',
              style: TextStyle(
                color: Color(0xFF9A91A8),
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 112,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: options.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final option = options[index];
              final isSelected = option.id == selected.id;

              return GestureDetector(
                onTap: () => onSelected(option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 102,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFD8227C) : const Color(0xFF1B1526),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFD8227C) : const Color(0xFF2C233C),
                      width: 1.2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFFD8227C).withValues(alpha: 0.4),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        option.icon,
                        size: 30,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        option.label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. "Meetup Spot" Card (Image 2)
// ─────────────────────────────────────────────────────────────────────────────
class _MeetupSpotCard extends StatefulWidget {
  const _MeetupSpotCard({
    required this.searchController,
    required this.selectedSpot,
    required this.onSpotSelected,
  });

  final TextEditingController searchController;
  final String selectedSpot;
  final ValueChanged<String> onSpotSelected;

  @override
  State<_MeetupSpotCard> createState() => _MeetupSpotCardState();
}

class _MeetupSpotCardState extends State<_MeetupSpotCard> {
  double _zoom = 1.0;

  static const List<String> _kSpotChips = [
    'Blue Bottle C...',
    'Central Park',
    'Sushi Palace',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1526),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2C233C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Meetup Spot',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'View on map',
                style: TextStyle(
                  color: Color(0xFF9A91A8),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Search input
          TextField(
            controller: widget.searchController,
            style: const TextStyle(color: Colors.white, fontSize: 13.5),
            decoration: InputDecoration(
              hintText: 'Search a cafe, restaurant or park...',
              hintStyle: const TextStyle(
                color: Color(0xFF9A91A8),
                fontSize: 13.5,
              ),
              prefixIcon: const Icon(
                Icons.location_on_outlined,
                color: Color(0xFF9A91A8),
                size: 20,
              ),
              filled: true,
              fillColor: const Color(0xFF130E1C),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF2C233C)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF2C233C)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE9297B), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Map preview container matching Image 2
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFFE4E2DC),
                border: Border.all(color: const Color(0xFF2C233C)),
              ),
              child: Stack(
                children: [
                  // Styled map background with streets & labels
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _MapPainter(zoom: _zoom),
                    ),
                  ),

                  // Top-Right zoom controls (+ / -) in dark circle with white inner pill
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      width: 44,
                      height: 84,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E172B).withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        width: 32,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () => setState(() => _zoom = math.min(1.6, _zoom + 0.15)),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.add,
                                  size: 18,
                                  color: Color(0xFF1E172B),
                                ),
                              ),
                            ),
                            const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
                            GestureDetector(
                              onTap: () => setState(() => _zoom = math.max(0.7, _zoom - 0.15)),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.remove,
                                  size: 18,
                                  color: Color(0xFF1E172B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Center Pin
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE9297B),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE9297B).withValues(alpha: 0.4),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom-Center Attribution Strip
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 12,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              '© OpenStreetMap contributors | MapLibre',
                              style: TextStyle(
                                color: Color(0xFF1F2937),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.info,
                              size: 12,
                              color: Color(0xFF1F2937),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Quick-pick spot chips row below map
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _kSpotChips.map((chip) {
              final isSelected = widget.selectedSpot == chip ||
                  widget.searchController.text.contains(chip.replaceAll('...', ''));

              return GestureDetector(
                onTap: () => widget.onSpotSelected(chip),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF130E1C),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFE9297B) : const Color(0xFF2C233C),
                      width: isSelected ? 1.4 : 1.0,
                    ),
                  ),
                  child: Text(
                    chip,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF9A91A8),
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  final double zoom;
  _MapPainter({required this.zoom});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFE4E2DC);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 28 * zoom
      ..style = PaintingStyle.stroke;

    final roadBorder = Paint()
      ..color = const Color(0xFFD1CECE)
      ..strokeWidth = 32 * zoom
      ..style = PaintingStyle.stroke;

    // Draw main diagonal boulevard
    final path = Path()
      ..moveTo(size.width * 0.45, -20)
      ..lineTo(size.width * 0.40, size.height + 20);

    canvas.drawPath(path, roadBorder);
    canvas.drawPath(path, roadPaint);

    // Cross street
    final path2 = Path()
      ..moveTo(-20, size.height * 0.65)
      ..lineTo(size.width + 20, size.height * 0.60);

    canvas.drawPath(path2, roadBorder);
    canvas.drawPath(path2, roadPaint);

    // Minor path
    final minorPaint = Paint()
      ..color = const Color(0xFFF3F2EF)
      ..strokeWidth = 14 * zoom
      ..style = PaintingStyle.stroke;

    final path3 = Path()
      ..moveTo(-20, size.height * 0.25)
      ..lineTo(size.width * 0.45, size.height * 0.22);
    canvas.drawPath(path3, minorPaint);

    // Road label text "o vard"
    const textSpan = TextSpan(
      text: 'o vard',
      style: TextStyle(
        color: Color(0xFF9CA3AF),
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.save();
    canvas.translate(size.width * 0.40, size.height * 0.48);
    canvas.rotate(-math.pi / 2.1);
    textPainter.paint(canvas, Offset.zero);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) => oldDelegate.zoom != zoom;
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. "Date & Time" Calendar & "Preferred Time" Card (Neon Planning Interface)
// ─────────────────────────────────────────────────────────────────────────────
class _DateTimeAndPreferredTimeCard extends StatelessWidget {
  const _DateTimeAndPreferredTimeCard({
    required this.dateTime,
    required this.month,
    required this.onMonthChanged,
    required this.onDateSelected,
    required this.onToday,
    required this.onTimeSlotSelected,
  });

  final DateTime dateTime;
  final DateTime month;
  final ValueChanged<int> onMonthChanged;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onToday;
  final void Function(int hour, int minute) onTimeSlotSelected;

  static const List<_TimeSlotData> _slots = [
    _TimeSlotData(label: '6:00 PM', hour: 18, minute: 0),
    _TimeSlotData(label: '7:30 PM', hour: 19, minute: 30),
    _TimeSlotData(label: '8:00 PM', hour: 20, minute: 0),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF180F24),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF2D1D42)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // A. Card Header Row: "Date & Time" + "Today"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.calendar_month_outlined,
                    color: Color(0xFFD5CEE2),
                    size: 22,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Date & Time',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onToday,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    'Today',
                    style: TextStyle(
                      color: Color(0xFFE9297B),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // B. Inner Calendar Container
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            decoration: BoxDecoration(
              color: const Color(0xFF120B1C),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF291B3C)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Month Navigation Row: <  November 2026  >
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => onMonthChanged(-1),
                      child: Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.chevron_left,
                          color: Color(0xFFDF1B7C),
                          size: 24,
                        ),
                      ),
                    ),
                    Text(
                      DateFormat('MMMM yyyy').format(month),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => onMonthChanged(1),
                      child: Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.chevron_right,
                          color: Color(0xFFDF1B7C),
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Weekday Row: S M T W T F S
                Row(
                  children: [
                    for (final day in ['S', 'M', 'T', 'W', 'T', 'F', 'S'])
                      Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: const TextStyle(
                              color: Color(0xFFA69BB5),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                // Calendar Dates Grid
                _CalendarDaysGrid(
                  month: month,
                  selected: dateTime,
                  onDateSelected: onDateSelected,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // C. "Preferred Time" Section
          Row(
            children: const [
              Icon(
                Icons.access_time_rounded,
                color: Color(0xFFD5CEE2),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Preferred Time',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 3 Time Slot Pills (6:00 PM | 7:30 PM | 8:00 PM)
          Row(
            children: [
              for (int i = 0; i < _slots.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _TimeSlotPill(
                    slot: _slots[i],
                    isSelected: dateTime.hour == _slots[i].hour &&
                        dateTime.minute == _slots[i].minute,
                    onTap: () => onTimeSlotSelected(
                      _slots[i].hour,
                      _slots[i].minute,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeSlotData {
  const _TimeSlotData({
    required this.label,
    required this.hour,
    required this.minute,
  });

  final String label;
  final int hour;
  final int minute;
}

class _TimeSlotPill extends StatelessWidget {
  const _TimeSlotPill({
    required this.slot,
    required this.isSelected,
    required this.onTap,
  });

  final _TimeSlotData slot;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFDF1B7C) : const Color(0xFF170F23),
          borderRadius: BorderRadius.circular(24),
          border: isSelected
              ? null
              : Border.all(color: const Color(0xFF2D1E42)),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFDF1B7C).withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          slot.label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFFD5CEE2),
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _CalendarDaysGrid extends StatelessWidget {
  const _CalendarDaysGrid({
    required this.month,
    required this.selected,
    required this.onDateSelected,
  });

  final DateTime month;
  final DateTime selected;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingBlanks = DateTime(month.year, month.month, 1).weekday % 7;
    final totalCells = leadingBlanks + daysInMonth;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalCells,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 6,
        crossAxisSpacing: 4,
        childAspectRatio: 1.05,
      ),
      itemBuilder: (context, index) {
        if (index < leadingBlanks) {
          return const SizedBox.shrink();
        }
        final day = index - leadingBlanks + 1;
        final isSelected = selected.year == month.year &&
            selected.month == month.month &&
            selected.day == day;

        return GestureDetector(
          onTap: () => onDateSelected(DateTime(month.year, month.month, day)),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFDF1B7C) : Colors.transparent,
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFFDF1B7C).withValues(alpha: 0.45),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                '$day',
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.95),
                  fontSize: 14.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 5b. "Duration" Card (Neon Planning Interface)
// ─────────────────────────────────────────────────────────────────────────────
class _DurationCard extends StatelessWidget {
  const _DurationCard({
    required this.duration,
    required this.onDurationPreset,
  });

  final int duration;
  final ValueChanged<int> onDurationPreset;

  static const List<MapEntry<int, String>> _presets = [
    MapEntry(30, '30m'),
    MapEntry(60, '60m'),
    MapEntry(90, '90m'),
    MapEntry(120, '120m'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF180F24),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF2D1D42)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row: Hourglass + "Duration" on left, "$duration minutes" on right
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.hourglass_empty,
                    color: Color(0xFFA97DF5),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Duration',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              Text(
                '$duration minutes',
                style: const TextStyle(
                  color: Color(0xFFE9297B),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 4 Duration Preset Pills Row: 30m | 60m | 90m | 120m
          Row(
            children: [
              for (int i = 0; i < _presets.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _DurationPresetPill(
                    minutes: _presets[i].key,
                    label: _presets[i].value,
                    isSelected: duration == _presets[i].key,
                    onTap: () => onDurationPreset(_presets[i].key),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _DurationPresetPill extends StatelessWidget {
  const _DurationPresetPill({
    required this.minutes,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final int minutes;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFDF1B7C) : const Color(0xFF170F23),
          borderRadius: BorderRadius.circular(22),
          border: isSelected
              ? null
              : Border.all(color: const Color(0xFF2D1E42)),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFDF1B7C).withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFFD5CEE2),
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 6. "Dress Code & Notes" Card (Image 3)
// ─────────────────────────────────────────────────────────────────────────────
class _DressCodeAndNotesCard extends StatelessWidget {
  const _DressCodeAndNotesCard({
    required this.selectedDressCode,
    required this.onDressCodeChanged,
    required this.proposalController,
    required this.partnerController,
  });

  final String selectedDressCode;
  final ValueChanged<String> onDressCodeChanged;
  final TextEditingController proposalController;
  final TextEditingController partnerController;

  static const List<String> _kDressCodes = [
    'Casual',
    'Smart casual',
    'Formal',
    'Cozy',
    'Theme night',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1526),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2C233C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row: "Dress Code & Notes" + "Edit" button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Dress Code & Notes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF231932),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF36274B)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.edit_outlined,
                      size: 14,
                      color: Color(0xFFE9297B),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Edit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'DRESS CODE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: Color(0xFF9A91A8),
            ),
          ),
          const SizedBox(height: 10),

          // Selectable chips: Casual, Smart casual, Formal, Cozy, Theme night
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _kDressCodes.map((code) {
              final isSelected = selectedDressCode == code;
              return GestureDetector(
                onTap: () => onDressCodeChanged(code),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF130E1C),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFE9297B) : const Color(0xFF2C233C),
                      width: isSelected ? 1.4 : 1.0,
                    ),
                  ),
                  child: Text(
                    code,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF9A91A8),
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Bottom 2-column notes area
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _NoteColumn(
                  label: 'Proposal Notes',
                  labelColor: const Color(0xFFF0548B),
                  controller: proposalController,
                  hint: 'Add notes...',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _NoteColumn(
                  label: 'Partner Notes',
                  labelColor: const Color(0xFFA96BFF),
                  controller: partnerController,
                  hint: "Partner's notes...",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NoteColumn extends StatelessWidget {
  const _NoteColumn({
    required this.label,
    required this.labelColor,
    required this.controller,
    required this.hint,
  });

  final String label;
  final Color labelColor;
  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF130E1C),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2C233C)),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: controller,
                minLines: 4,
                maxLines: 4,
                maxLength: 200,
                buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(
                    color: Color(0xFF9A91A8),
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  '${controller.text.length}/200',
                  style: const TextStyle(
                    color: Color(0xFF9A91A8),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 7. "To Do's" Card (Image 4)
// ─────────────────────────────────────────────────────────────────────────────
class _TodoCard extends StatelessWidget {
  const _TodoCard({
    required this.todos,
    required this.controller,
    required this.onToggle,
    required this.onAdd,
  });

  final List<TodoItem> todos;
  final TextEditingController controller;
  final ValueChanged<TodoItem> onToggle;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final done = todos.where((todo) => todo.done).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1526),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2C233C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row: "To Do's" + "X of Y done" + "Edit" button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    "To Do's",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$done of ${todos.length} done',
                    style: const TextStyle(
                      color: Color(0xFFF03888),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF231932),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF36274B)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.edit_outlined,
                      size: 14,
                      color: Color(0xFFE9297B),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Edit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Checklist rows
          for (final todo in todos)
            GestureDetector(
              onTap: () => onToggle(todo),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: todo.done ? const Color(0xFFD8227C) : const Color(0xFF130E1C),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: todo.done ? const Color(0xFFD8227C) : const Color(0xFF2C233C),
                          width: 1.2,
                        ),
                      ),
                      child: todo.done
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        todo.text,
                        style: TextStyle(
                          color: todo.done ? const Color(0xFF9A91A8) : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          decoration: todo.done ? TextDecoration.lineThrough : null,
                          decorationColor: const Color(0xFF9A91A8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 10),

          // Add new to-do row
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF130E1C),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2C233C)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.add,
                        color: Color(0xFFE9297B),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: controller,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => onAdd(),
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: const InputDecoration(
                            hintText: '+ Add a new to-do note...',
                            hintStyle: TextStyle(
                              color: Color(0xFF9A91A8),
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF130E1C),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2C233C)),
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    color: Color(0xFF9A91A8),
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 8. "Split Bill" Card (Image 4)
// ─────────────────────────────────────────────────────────────────────────────
class _SplitBillCard extends StatelessWidget {
  const _SplitBillCard({
    required this.proposerPercent,
    required this.partnerName,
    required this.selectedPreset,
    required this.onPreset,
  });

  final int proposerPercent;
  final String partnerName;
  final String selectedPreset;
  final ValueChanged<String> onPreset;

  @override
  Widget build(BuildContext context) {
    final partnerPercent = 100 - proposerPercent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1526),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2C233C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Split Bill',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          // Dual color bar
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  Expanded(
                    flex: proposerPercent == 0 ? 1 : proposerPercent,
                    child: Container(color: const Color(0xFFE9297B)),
                  ),
                  Expanded(
                    flex: partnerPercent == 0 ? 1 : partnerPercent,
                    child: Container(
                      color: partnerPercent == 0
                          ? Colors.transparent
                          : const Color(0xFFB47AEA),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$proposerPercent%',
                    style: const TextStyle(
                      color: Color(0xFFE9297B),
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'You (Proposer)',
                    style: TextStyle(
                      color: Color(0xFF9A91A8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$partnerPercent%',
                    style: const TextStyle(
                      color: Color(0xFFB47AEA),
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    partnerName,
                    style: const TextStyle(
                      color: Color(0xFF9A91A8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final option in const ['50/50', '70/30', '30/70', 'I pay all'])
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: GestureDetector(
                      onTap: () => onPreset(option),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFF130E1C),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selectedPreset == option
                                ? const Color(0xFFE9297B)
                                : const Color(0xFF2C233C),
                            width: selectedPreset == option ? 1.4 : 1.0,
                          ),
                        ),
                        child: Text(
                          option,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: selectedPreset == option
                                ? Colors.white
                                : const Color(0xFF9A91A8),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 9. Sticky bottom CTA bar
// ─────────────────────────────────────────────────────────────────────────────
class _PlanDateBottomBar extends StatelessWidget {
  const _PlanDateBottomBar({
    required this.partnerName,
    required this.enabled,
    required this.onPressed,
  });

  final String partnerName;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0B0711),
        border: Border(top: BorderSide(color: Color(0xFF2C233C))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          child: Semantics(
            button: true,
            label: 'Plan date with $partnerName',
            child: GestureDetector(
              onTap: enabled ? onPressed : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9297B),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE9297B).withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Plan date with',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            partnerName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.monetization_on,
                            color: Color(0xFFFFC94D),
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '150 coins',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
