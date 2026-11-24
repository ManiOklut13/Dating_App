import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/profiles_data.dart';
import '../../features/plan_date/plan_date_theme.dart';
import '../../models/chat_profile_models.dart';
import '../../services/app_data_service.dart';
import '../../services/chat_list_provider.dart';
import 'date_plan_models.dart';
import 'plan_date_chooser_sheet.dart';
import 'plan_date_provider.dart';

/// Full-screen Plan a Date planner opened from the chat tab.
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

  late ChatConversationModel _partner;
  late DateTime _dateTime;
  late DateTime _month;
  DateMode _mode = DateMode.virtual;
  DateTypeOption _type = DateTypeOption.movie;
  int _duration = 60;
  late List<TodoItem> _todos;
  bool _todosEdited = false;
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _partner = widget.partner;
    _dateTime = _nextSlot();
    _month = DateTime(_dateTime.year, _dateTime.month);
    _todos = defaultDateTodos(_mode, _type);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _todoCtrl.dispose();
    super.dispose();
  }

  // ── Draft helpers ────────────────────────────────────────────────────────
  DateTime _nextSlot() {
    final now = DateTime.now();
    final soon = now.add(const Duration(minutes: 30));
    final roundedMinute = ((soon.minute + 4) ~/ 5) * 5;
    final adjusted = soon.add(Duration(minutes: roundedMinute - soon.minute));
    return DateTime(
      adjusted.year,
      adjusted.month,
      adjusted.day,
      adjusted.hour,
      adjusted.minute,
    );
  }

  DateTime _clamp(DateTime value) =>
      value.isAfter(DateTime.now()) ? value : _nextSlot();

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
      _dateTime = _clamp(value);
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

  void _stepHour(int amount) =>
      _setDateTime(_dateTime.add(Duration(hours: amount)));

  void _stepMinute(int amount) =>
      _setDateTime(_dateTime.add(Duration(minutes: amount * 5)));

  void _toggleAmPm() => _setDateTime(_dateTime.add(const Duration(hours: 12)));

  void _setDuration(int minutes) =>
      setState(() => _duration = minutes.clamp(15, 480));

  void _toggleTodo(TodoItem todo) {
    setState(() {
      _todos = _todos
          .map((item) => item.id == todo.id
              ? item.copyWith(done: !item.done)
              : item)
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
        ),
      ];
      _todosEdited = true;
    });
    _todoCtrl.clear();
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

  bool get _canSend => _dateTime.isAfter(DateTime.now());

  String get _summary {
    final formatted = DateFormat('EEE, d MMM · h:mm a').format(_dateTime);
    final modeLabel = _mode == DateMode.virtual ? 'Virtual' : 'Offline';
    return '$formatted · $_duration min · $modeLabel';
  }

  void _sendInvite() {
    if (!_canSend) {
      _showMessage('Pick a future date and time first.');
      return;
    }
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
    _showMessage('Date invite sent to ${_partner.name}');
    Navigator.of(context).pop();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF2A1230),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chats = ref.watch(chatConversationsProvider);

    return Scaffold(
      backgroundColor: PDColors.bg,
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
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 160),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _PlannerHeader(
                        onClose: () => Navigator.of(context).maybePop(),
                        onCalendar: _openPartnerChooser,
                      ),
                      const SizedBox(height: 18),
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
                      _DateModeCard(
                        mode: _mode,
                        onModeChanged: _setMode,
                      ),
                      const SizedBox(height: 22),
                      _DateTypeCarousel(
                        mode: _mode,
                        selected: _type,
                        onSelected: _setType,
                      ),
                      const SizedBox(height: 20),
                      _TimeAndCalendarCard(
                        dateTime: _dateTime,
                        month: _month,
                        duration: _duration,
                        onStepHour: _stepHour,
                        onStepMinute: _stepMinute,
                        onToggleAmPm: _toggleAmPm,
                        onStepDuration: (amount) =>
                            _setDuration(_duration + amount * 15),
                        onDurationPreset: _setDuration,
                        onMonthChanged: (delta) => setState(
                          () => _month =
                              DateTime(_month.year, _month.month + delta),
                        ),
                        onDateSelected: _setDate,
                      ),
                      const SizedBox(height: 18),
                      _TodoCard(
                        todos: _todos,
                        controller: _todoCtrl,
                        onToggle: _toggleTodo,
                        onAdd: () => _addTodo(_todoCtrl.text),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _SendBar(
              summary: _summary,
              enabled: _canSend,
              onPressed: _sendInvite,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Background
// ─────────────────────────────────────────────────────────────────────────────
class _BackgroundGlows extends StatelessWidget {
  const _BackgroundGlows();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -140,
            left: -80,
            width: 320,
            height: 320,
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [Color(0x3DE91E8C), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            top: -100,
            right: -90,
            width: 300,
            height: 300,
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [Color(0x2EA21CAF), Colors.transparent],
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
// Header
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
          label: 'Close Plan a Date',
          child: GestureDetector(
            onTap: onClose,
            child: const _HeaderButton(
              icon: Icons.close_outlined,
              color: PDColors.textPrimary,
            ),
          ),
        ),
        const Expanded(
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Plan a ',
                  style: TextStyle(
                    color: PDColors.textPrimary,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                _GradientText('Date'),
              ],
            ),
          ),
        ),
        Semantics(
          button: true,
          label: 'Choose another partner',
          child: GestureDetector(
            onTap: onCalendar,
            child: const _HeaderButton(
              icon: Icons.calendar_month_outlined,
              color: PDColors.textAccent,
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
        color: PDColors.card,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: PDColors.cardBorder),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _GradientText extends StatelessWidget {
  const _GradientText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xFFFF5C9A), Color(0xFFC77DFF)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(bounds),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 21,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Date pair + partner search
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
      decoration: const BoxDecoration(
        color: PDColors.card,
        borderRadius: BorderRadius.all(Radius.circular(PDRadius.card)),
        border: Border.fromBorderSide(BorderSide(color: PDColors.cardBorder)),
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
                color: PDColors.chooserPink,
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 172,
            child: Stack(
              children: [
                Row(
                  children: [
                    Expanded(child: _YouCard(userPhoto: userPhoto)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _PartnerCard(partner: partner, onSwap: onSwap),
                    ),
                  ],
                ),
                const Positioned(
                  left: 0,
                  right: 0,
                  top: 54,
                  child: Center(child: _HeartBadge()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            clipBehavior: Clip.none,
            children: [
              TextField(
                controller: searchController,
                focusNode: searchFocus,
                onChanged: (_) => onSearchChanged(),
                onTap: onSearchChanged,
                style: const TextStyle(
                  color: PDColors.textPrimary,
                  fontSize: 13.5,
                ),
                decoration: InputDecoration(
                  hintText: 'Search for partner...',
                  hintStyle: const TextStyle(
                    color: PDColors.textMuted,
                    fontSize: 13.5,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: PDColors.textMuted,
                    size: 19,
                  ),
                  filled: true,
                  fillColor: PDColors.inputFill,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(PDRadius.input),
                    borderSide: const BorderSide(color: PDColors.inputBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(PDRadius.input),
                    borderSide: const BorderSide(color: PDColors.inputBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(PDRadius.input),
                    borderSide: const BorderSide(
                      color: PDColors.gradientPink,
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
                    color: PDColors.controlFill,
                    borderRadius: BorderRadius.circular(PDRadius.control),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 210),
                      child: matches.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'No matching chats',
                                style: PDTextStyles.muted,
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              itemCount: matches.length,
                              itemBuilder: (context, index) {
                                final chat = matches[index];
                                return ListTile(
                                  minLeadingWidth: 32,
                                  leading: ClipOval(
                                    child: SizedBox(
                                      width: 32,
                                      height: 32,
                                      child: _Avatar(
                                        name: chat.name,
                                        asset: chat.avatarAsset,
                                        size: 32,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    chat.name,
                                    style: const TextStyle(
                                      color: PDColors.textPrimary,
                                      fontSize: 13,
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

class _YouCard extends StatelessWidget {
  const _YouCard({required this.userPhoto});

  final String userPhoto;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6D3BFF), Color(0xFF2A1454)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            left: 10,
            top: 10,
            child: ClipOval(
              child: SizedBox(
                width: 32,
                height: 32,
                child: SafeProfileImage(
                  imageUrl: userPhoto,
                  width: 32,
                  height: 32,
                ),
              ),
            ),
          ),
          const Positioned(
            left: 12,
            bottom: 12,
            child: Text(
              'You',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PartnerCard extends StatelessWidget {
  const _PartnerCard({required this.partner, required this.onSwap});

  final ChatConversationModel partner;
  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSwap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _Avatar(
              name: partner.name,
              asset: partner.avatarAsset,
              size: double.infinity,
              fontSize: 34,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Color(0xCC08040E)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color:
                      partner.isOnline ? PDColors.online : PDColors.offline,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
            Positioned(
              left: 10,
              right: 8,
              bottom: 10,
              child: Text(
                partner.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.name,
    required this.asset,
    required this.size,
    this.fontSize = 15,
  });

  final String name;
  final String? asset;
  final double size;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    if (asset != null) {
      return SafeProfileImage(
        imageUrl: asset!,
        width: size == double.infinity ? double.infinity : size,
        height: size == double.infinity ? double.infinity : size,
      );
    }
    return Container(
      width: size == double.infinity ? null : size,
      height: size == double.infinity ? null : size,
      color: PDColors.controlFill,
      alignment: Alignment.center,
      child: Text(
        name.isEmpty ? '?' : name.substring(0, 1).toUpperCase(),
        style: TextStyle(
          color: PDColors.textPrimary,
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _HeartBadge extends StatelessWidget {
  const _HeartBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: PDGradients.selection,
          boxShadow: [
            BoxShadow(
              color: Color(0x66E91E8C),
              blurRadius: 16,
              spreadRadius: 1,
            ),
          ],
        ),
        child: const Icon(Icons.favorite, color: Colors.white, size: 26),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Date mode
// ─────────────────────────────────────────────────────────────────────────────
class _DateModeCard extends StatelessWidget {
  const _DateModeCard({required this.mode, required this.onModeChanged});

  final DateMode mode;
  final ValueChanged<DateMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final hint = mode == DateMode.virtual
        ? 'Video call from anywhere'
        : 'Meet in person';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: PDColors.card,
        borderRadius: BorderRadius.all(Radius.circular(PDRadius.card)),
        border: Border.fromBorderSide(BorderSide(color: PDColors.cardBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text('Date Mode', style: PDTextStyles.sectionTitle),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hint,
                  textAlign: TextAlign.end,
                  style: PDTextStyles.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: PDColors.inputFill,
              borderRadius: BorderRadius.circular(PDRadius.control),
              border: Border.all(color: PDColors.inputBorder),
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
                    icon: Icons.place_outlined,
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
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 13),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: selected ? PDGradients.selection : null,
            color: selected ? null : PDColors.controlFill,
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x55E91E8C),
                      blurRadius: 16,
                      offset: Offset(0, 4),
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
                color: selected ? Colors.white : PDColors.textMuted,
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? Colors.white : PDColors.textMuted,
                    fontSize: 13.5,
                    fontWeight:
                        selected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Date type carousel
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
          children: [
            const Text('Date Type', style: PDTextStyles.sectionTitle),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Swipe for more >',
                textAlign: TextAlign.end,
                style: PDTextStyles.muted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 108,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            itemCount: options.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final option = options[index];
              final isSelected = option.id == selected.id;
              return Semantics(
                button: true,
                selected: isSelected,
                label: option.label,
                child: GestureDetector(
                  onTap: () => onSelected(option),
                  child: AnimatedScale(
                    scale: isSelected ? 1.04 : 1,
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutBack,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: 84,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: isSelected ? PDGradients.selection : null,
                        color: isSelected ? null : PDColors.card,
                        borderRadius:
                            BorderRadius.circular(PDRadius.control),
                        border: Border.all(
                          color: isSelected
                              ? PDColors.gradientPink
                              : PDColors.cardBorder,
                        ),
                        boxShadow: isSelected
                            ? const [
                                BoxShadow(
                                  color: Color(0x55E91E8C),
                                  blurRadius: 18,
                                  offset: Offset(0, 5),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            option.icon,
                            size: 24,
                            color: isSelected
                                ? Colors.white
                                : PDColors.textMuted,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            option.label,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : PDColors.textPrimary,
                              fontSize: 11.5,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
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
// Time, duration and calendar
// ─────────────────────────────────────────────────────────────────────────────
class _TimeAndCalendarCard extends StatelessWidget {
  const _TimeAndCalendarCard({
    required this.dateTime,
    required this.month,
    required this.duration,
    required this.onStepHour,
    required this.onStepMinute,
    required this.onToggleAmPm,
    required this.onStepDuration,
    required this.onDurationPreset,
    required this.onMonthChanged,
    required this.onDateSelected,
  });

  final DateTime dateTime;
  final DateTime month;
  final int duration;
  final ValueChanged<int> onStepHour;
  final ValueChanged<int> onStepMinute;
  final VoidCallback onToggleAmPm;
  final ValueChanged<int> onStepDuration;
  final ValueChanged<int> onDurationPreset;
  final ValueChanged<int> onMonthChanged;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: PDColors.card,
        borderRadius: BorderRadius.all(Radius.circular(PDRadius.card)),
        border: Border.fromBorderSide(BorderSide(color: PDColors.cardBorder)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final left = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TimePicker(
                dateTime: dateTime,
                onStepHour: onStepHour,
                onStepMinute: onStepMinute,
                onToggleAmPm: onToggleAmPm,
              ),
              const SizedBox(height: 22),
              _DurationPicker(
                duration: duration,
                onStep: onStepDuration,
                onPreset: onDurationPreset,
              ),
            ],
          );
          final right = _MiniCalendar(
            selected: dateTime,
            month: month,
            onMonthChanged: onMonthChanged,
            onDateSelected: onDateSelected,
          );

          if (constraints.maxWidth < 420) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                left,
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Divider(color: PDColors.divider, height: 1),
                ),
                right,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: left),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 320,
                  child: VerticalDivider(color: PDColors.divider, width: 1),
                ),
              ),
              Expanded(child: right),
            ],
          );
        },
      ),
    );
  }
}

class _TimePicker extends StatelessWidget {
  const _TimePicker({
    required this.dateTime,
    required this.onStepHour,
    required this.onStepMinute,
    required this.onToggleAmPm,
  });

  final DateTime dateTime;
  final ValueChanged<int> onStepHour;
  final ValueChanged<int> onStepMinute;
  final VoidCallback onToggleAmPm;

  @override
  Widget build(BuildContext context) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final isPm = dateTime.hour >= 12;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'TIME',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: PDColors.textMuted,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _TimeStepper(
              value: hour.toString().padLeft(2, '0'),
              onUp: () => onStepHour(1),
              onDown: () => onStepHour(-1),
              upLabel: 'Increase hour',
              downLabel: 'Decrease hour',
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                ':',
                style: TextStyle(
                  color: PDColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            _TimeStepper(
              value: dateTime.minute.toString().padLeft(2, '0'),
              onUp: () => onStepMinute(1),
              onDown: () => onStepMinute(-1),
              upLabel: 'Increase minute',
              downLabel: 'Decrease minute',
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: onToggleAmPm,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: PDColors.controlFill,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: PDColors.controlBorder),
                ),
                child: Text(
                  isPm ? 'PM' : 'AM',
                  style: const TextStyle(
                    color: PDColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TimeStepper extends StatelessWidget {
  const _TimeStepper({
    required this.value,
    required this.onUp,
    required this.onDown,
    required this.upLabel,
    required this.downLabel,
  });

  final String value;
  final VoidCallback onUp;
  final VoidCallback onDown;
  final String upLabel;
  final String downLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepperButton(
          icon: Icons.keyboard_arrow_up,
          label: upLabel,
          onTap: onUp,
        ),
        Container(
          width: 58,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: PDColors.inputFill,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: PDColors.inputBorder),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: PDColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        _StepperButton(
          icon: Icons.keyboard_arrow_down,
          label: downLabel,
          onTap: onDown,
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 28,
          child: Icon(icon, size: 20, color: PDColors.textMuted),
        ),
      ),
    );
  }
}

class _DurationPicker extends StatelessWidget {
  const _DurationPicker({
    required this.duration,
    required this.onStep,
    required this.onPreset,
  });

  final int duration;
  final ValueChanged<int> onStep;
  final ValueChanged<int> onPreset;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'DURATION',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: PDColors.textMuted,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StepperButton(
              icon: Icons.remove_circle_outline,
              label: 'Decrease duration',
              onTap: () => onStep(-1),
            ),
            Container(
              constraints: const BoxConstraints(minWidth: 96),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: PDColors.inputFill,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: PDColors.inputBorder),
              ),
              child: Text(
                '$duration min',
                style: const TextStyle(
                  color: PDColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            _StepperButton(
              icon: Icons.add_circle_outline,
              label: 'Increase duration',
              onTap: () => onStep(1),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            for (final preset in const [30, 60, 90, 120])
              GestureDetector(
                onTap: () => onPreset(preset),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    gradient: duration == preset
                        ? PDGradients.selection
                        : null,
                    color: duration == preset ? null : PDColors.controlFill,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: duration == preset
                          ? PDColors.gradientPink
                          : PDColors.controlBorder,
                    ),
                  ),
                  child: Text(
                    '${preset}m',
                    style: TextStyle(
                      color: duration == preset
                          ? Colors.white
                          : PDColors.textMuted,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _MiniCalendar extends StatelessWidget {
  const _MiniCalendar({
    required this.selected,
    required this.month,
    required this.onMonthChanged,
    required this.onDateSelected,
  });

  final DateTime selected;
  final DateTime month;
  final ValueChanged<int> onMonthChanged;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingBlanks = DateTime(month.year, month.month, 1).weekday % 7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                DateFormat('MMMM yyyy').format(month),
                style: const TextStyle(
                  color: PDColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            _CalendarArrow(
              icon: Icons.chevron_left,
              label: 'Previous month',
              onTap: () => onMonthChanged(-1),
            ),
            const SizedBox(width: 4),
            _CalendarArrow(
              icon: Icons.chevron_right,
              label: 'Next month',
              onTap: () => onMonthChanged(1),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (final label in const ['S', 'M', 'T', 'W', 'T', 'F', 'S'])
              Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: PDColors.textMuted,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: leadingBlanks + daysInMonth,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemBuilder: (context, index) {
            if (index < leadingBlanks) return const SizedBox.shrink();
            final day = index - leadingBlanks + 1;
            final date = DateTime(month.year, month.month, day);
            final isPast = date.isBefore(today);
            final isToday = date == today;
            final isSelected = date.year == selected.year &&
                date.month == selected.month &&
                date.day == selected.day;

            return GestureDetector(
              onTap: isPast ? null : () => onDateSelected(date),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: isSelected ? PDGradients.selection : null,
                  shape: BoxShape.circle,
                  border: isToday && !isSelected
                      ? Border.all(color: PDColors.gradientPink)
                      : null,
                ),
                child: Text(
                  '$day',
                  style: TextStyle(
                    color: isPast
                        ? PDColors.disabledText
                        : isSelected
                            ? Colors.white
                            : PDColors.textPrimary,
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _CalendarArrow extends StatelessWidget {
  const _CalendarArrow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, size: 20, color: PDColors.textMuted),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// To-do checklist
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
      decoration: const BoxDecoration(
        color: PDColors.card,
        borderRadius: BorderRadius.all(Radius.circular(PDRadius.card)),
        border: Border.fromBorderSide(BorderSide(color: PDColors.cardBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text("To Do's", style: PDTextStyles.sectionTitle),
              const SizedBox(width: 8),
              Text(
                '$done of ${todos.length} done',
                style: const TextStyle(
                  color: PDColors.textMuted,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final todo in todos)
            GestureDetector(
              onTap: () => onToggle(todo),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        gradient: todo.done ? PDGradients.selection : null,
                        color: todo.done ? null : PDColors.inputFill,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: todo.done
                              ? PDColors.gradientPink
                              : PDColors.inputBorder,
                        ),
                      ),
                      child: todo.done
                          ? const Icon(Icons.check,
                              size: 15, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        todo.text,
                        style: TextStyle(
                          color: todo.done
                              ? PDColors.textMuted
                              : PDColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          decoration:
                              todo.done ? TextDecoration.lineThrough : null,
                          decorationColor: PDColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => onAdd(),
                  style: const TextStyle(
                    color: PDColors.textPrimary,
                    fontSize: 13,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Add a to-do...',
                    hintStyle: const TextStyle(
                      color: PDColors.textMuted,
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: PDColors.inputFill,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(PDRadius.input),
                      borderSide:
                          const BorderSide(color: PDColors.inputBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(PDRadius.input),
                      borderSide:
                          const BorderSide(color: PDColors.inputBorder),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: PDGradients.selection,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
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
// Send bar
// ─────────────────────────────────────────────────────────────────────────────
class _SendBar extends StatelessWidget {
  const _SendBar({
    required this.summary,
    required this.enabled,
    required this.onPressed,
  });

  final String summary;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: PDColors.bg,
        border: Border(top: BorderSide(color: PDColors.cardBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                summary,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: PDColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Semantics(
                button: true,
                label: 'Send Date Invite',
                child: GestureDetector(
                  onTap: enabled ? onPressed : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: enabled ? PDGradients.selection : null,
                      color: enabled ? null : PDColors.controlFill,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: enabled
                          ? const [
                              BoxShadow(
                                color: Color(0x55E91E8C),
                                blurRadius: 20,
                                offset: Offset(0, 6),
                              ),
                            ]
                          : null,
                    ),
                    child: const Text(
                      'Send Date Invite',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
