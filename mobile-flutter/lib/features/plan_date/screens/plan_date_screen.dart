// ─────────────────────────────────────────────────────────────────────────────
// Plan Date Screen — Virtual + Offline modes
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/plan_date_model.dart';
import '../providers/plan_date_providers.dart';
import '../widgets/plan_date_header.dart';
import '../widgets/partner_card.dart';
import '../widgets/mode_toggle.dart';
import '../widgets/date_type_row.dart';
import '../widgets/date_time_picker.dart';
import '../widgets/duration_picker.dart';
import '../widgets/todo_list.dart';
import '../widgets/split_bill.dart';
import '../widgets/about_plan_date.dart';
import '../widgets/plan_date_cta.dart';
import '../widgets/notes_section.dart';
import '../widgets/meetup_spot_card.dart';
import '../widgets/dress_code_notes.dart';
import '../widgets/safety_tip.dart';
import '../plan_date_theme.dart';
import 'date_proposed_screen.dart';

class PlanDateScreen extends ConsumerWidget {
  /// Pre-filled partner from the chat context.
  final String? initialPartnerId;
  final String? initialPartnerName;
  final String? initialPartnerAvatar;
  final bool initialPartnerOnline;

  const PlanDateScreen({
    super.key,
    this.initialPartnerId,
    this.initialPartnerName,
    this.initialPartnerAvatar,
    this.initialPartnerOnline = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Seed partner if provided from calling screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (initialPartnerId != null) {
        ref.read(planDateFormProvider.notifier).setPartner(
              id: initialPartnerId!,
              name: initialPartnerName ?? '',
              isOnline: initialPartnerOnline,
              avatar: initialPartnerAvatar,
            );
      }
    });

    final form = ref.watch(planDateFormProvider);
    final notifier = ref.read(planDateFormProvider.notifier);

    return Scaffold(
      backgroundColor: PDColors.bg,
      body: Stack(
        children: [
          // ── Background radial glows ──────────────────────────────────
          const _BgGlows(),
          // ── Scrollable content ───────────────────────────────────────
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      _buildSections(context, ref, form, notifier),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ── Sticky CTA at bottom ─────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _StickyCtaBar(
              form: form,
              onPressed: () => _onSubmit(context, ref),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSections(
    BuildContext context,
    WidgetRef ref,
    PlanDateFormState form,
    PlanDateFormNotifier notifier,
  ) {
    final divider = const SizedBox(height: 20);

    return [
      // Header
      PlanDateHeader(
        onClose: () => Navigator.of(context).pop(),
        onMyDates: () => _showSnack(context, 'My Dates coming soon'),
      ),
      const SizedBox(height: 20),

      // Partner card (YOUR DATE PAIR)
      PartnerCard(
        partnerName: form.partnerName,
        isOnline: form.isPartnerOnline,
        avatarUrl: form.partnerAvatar,
        onChangePartner: () => _showPartnerPicker(context, notifier),
        onSearch: (q) => _showPartnerPicker(context, notifier, query: q),
      ),
      divider,

      // Mode toggle
      ModeToggle(
        mode: form.mode,
        onChanged: notifier.setMode,
      ),
      divider,

      // Date type (outside card)
      _DateTypeSection(form: form, notifier: notifier),
      divider,

      // Date & Time
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: PDColors.card,
          borderRadius: BorderRadius.circular(PDRadius.card),
          border: Border.all(color: PDColors.cardBorder),
        ),
        child: DateTimePicker(
          selectedDate: form.selectedDate,
          hour: form.selectedHour,
          minute: form.selectedMinute,
          isAm: form.isAm,
          durationMin: form.durationMin,
          onDateChanged: notifier.setDate,
          onHourChanged: notifier.setHour,
          onMinuteChanged: notifier.setMinute,
          onAmPmChanged: notifier.setAmPm,
        ),
      ),
      divider,

      // Duration
      _SectionCard(
        title: 'Duration',
        child: DurationPicker(
          durationMin: form.durationMin,
          mode: form.mode,
          onIncrement: notifier.incrementDuration,
          onDecrement: notifier.decrementDuration,
          onQuickSelect: notifier.setDuration,
        ),
      ),
      divider,

      // Virtual-only: Notes
      if (form.mode == DateMode.virtual) ...[
        NotesSection(
          proposalNote: form.proposalNote,
          partnerNote: form.partnerNote,
          onProposalChanged: notifier.setProposalNote,
          onPartnerChanged: notifier.setPartnerNote,
        ),
        divider,
      ],

      // Offline-only: Meetup Spot + Dress Code + Safety tip
      if (form.mode == DateMode.offline) ...[
        MeetupSpotCard(
          spot: form.meetupSpot,
          onSpotSelected: notifier.setMeetupSpot,
          onClearSpot: notifier.clearMeetupSpot,
        ),
        divider,
        DressCodeNotes(
          selectedCode: form.dressCode,
          dressNote: form.dressNote,
          partnerNote: form.partnerDressNote,
          editMode: form.dressCodeEditMode,
          onCodeChanged: notifier.setDressCode,
          onDressNoteChanged: notifier.setDressNote,
          onPartnerNoteChanged: notifier.setPartnerDressNote,
          onToggleEditMode: () => notifier.setDressCodeEditMode(!form.dressCodeEditMode),
        ),
        divider,
        const SafetyTip(),
        divider,
      ],

      // To Do's
      TodoList(
        todos: form.todos,
        editMode: form.todoEditMode,
        onAdd: notifier.addTodo,
        onToggle: notifier.toggleTodo,
        onDelete: notifier.deleteTodo,
        onToggleEditMode: () => notifier.setTodoEditMode(!form.todoEditMode),
      ),
      divider,

      // Split Bill
      _SectionCard(
        title: 'Split Bill',
        child: SplitBillWidget(
          proposerPct: form.splitProposerPct,
          onPresetSelected: notifier.setSplit,
          onSliderChanged: notifier.setSplit,
        ),
      ),
      divider,

      // About
      const AboutPlanDate(),
    ];
  }

  Future<void> _onSubmit(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(planDateFormProvider.notifier);
    final result = await notifier.submit();
    if (result != null && context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => DateProposedScreen(plan: result),
        ),
      );
    } else if (context.mounted) {
      final error = ref.read(planDateFormProvider).submissionError;
      _showSnack(context, error ?? 'Something went wrong');
    }
  }

  void _showPartnerPicker(
    BuildContext context,
    PlanDateFormNotifier notifier, {
    String? query,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16121F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _PartnerPickerSheet(
        initialQuery: query,
        onSelected: ({required id, required name, isOnline, avatar}) {
          notifier.setPartner(
            id: id,
            name: name,
            isOnline: isOnline ?? true,
            avatar: avatar,
          );
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF16121F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Background radial glows
// ─────────────────────────────────────────────────────────────────────────────
class _BgGlows extends StatelessWidget {
  const _BgGlows();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            // Pink glow top right
            Positioned(
              top: -80,
              right: -60,
              width: 300,
              height: 300,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    colors: [
                      Color(0x4DE8226F),
                      Colors.transparent,
                    ],
                    radius: 0.7,
                  ),
                ),
              ),
            ),
            // Violet glow top left
            Positioned(
              top: 40,
              left: -80,
              width: 280,
              height: 280,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    colors: [
                      Color(0x2E8B5CF6),
                      Colors.transparent,
                    ],
                    radius: 0.7,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section label card wrapper
// ─────────────────────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PDColors.card,
        borderRadius: BorderRadius.circular(PDRadius.card),
        border: Border.all(color: PDColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: PDColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Date type section with loading / error / data states
// ─────────────────────────────────────────────────────────────────────────────
class _DateTypeSection extends ConsumerWidget {
  final PlanDateFormState form;
  final PlanDateFormNotifier notifier;

  const _DateTypeSection({required this.form, required this.notifier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typesAsync = ref.watch(dateTypesProvider(form.mode));
    return typesAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: CircularProgressIndicator(color: Color(0xFFF0318B)),
        ),
      ),
      error: (e, _) => const Text(
        'Failed to load date types',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          color: Color(0xFF8E88A3),
        ),
      ),
      data: (types) => DateTypeRow(
        types: types,
        selectedId: form.dateTypeId,
        onSelect: notifier.setDateType,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sticky CTA bar
// ─────────────────────────────────────────────────────────────────────────────
class _StickyCtaBar extends StatelessWidget {
  final PlanDateFormState form;
  final VoidCallback onPressed;

  const _StickyCtaBar({required this.form, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            PDColors.bg.withValues(alpha: 0),
            PDColors.bg,
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        child: PlanDateCta(
          enabled: form.isCtaEnabled,
          isLoading: form.isSubmitting,
          partnerName: form.partnerName,
          onPressed: onPressed,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Partner picker bottom sheet (mock partners)
// ─────────────────────────────────────────────────────────────────────────────
class _PartnerPickerSheet extends StatefulWidget {
  final String? initialQuery;
  final void Function({
    required String id,
    required String name,
    bool? isOnline,
    String? avatar,
  }) onSelected;

  const _PartnerPickerSheet({this.initialQuery, required this.onSelected});

  @override
  State<_PartnerPickerSheet> createState() => _PartnerPickerSheetState();
}

class _PartnerPickerSheetState extends State<_PartnerPickerSheet> {
  late final TextEditingController _ctrl;
  String _query = '';

  static final _mockPartners = [
    {'id': 'p1', 'name': 'Priya Nair', 'avatar': 'assets/images/ananya.jpg', 'online': true},
    {'id': 'p2', 'name': 'Sana Iyer', 'avatar': 'assets/images/riya.jpg', 'online': false},
    {'id': 'p3', 'name': 'Kabir Singh', 'avatar': 'assets/images/rohit.jpg', 'online': true},
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialQuery ?? '');
    _query = _ctrl.text;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _mockPartners.where((p) {
      return _query.isEmpty ||
          (p['name'] as String).toLowerCase().contains(_query.toLowerCase());
    }).toList();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose a partner',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: PDColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: PDColors.inputFill,
                  borderRadius: BorderRadius.circular(PDRadius.input),
                  border: Border.all(color: PDColors.cardBorder),
                ),
                child: TextField(
                  controller: _ctrl,
                  autofocus: true,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    color: PDColors.textPrimary,
                  ),
                  onChanged: (q) => setState(() => _query = q),
                  decoration: const InputDecoration(
                    hintText: 'Search...',
                    hintStyle: TextStyle(color: PDColors.textMuted),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    prefixIcon: Icon(Icons.search, color: PDColors.textMuted, size: 18),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...filtered.map((p) {
                final name = p['name'] as String;
                final avatar = p['avatar'] as String;
                final online = p['online'] as bool;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage(avatar),
                    radius: 22,
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      color: PDColors.textPrimary,
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: online ? PDColors.online : PDColors.offline,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        online ? 'Online' : 'Offline',
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11,
                          color: PDColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  onTap: () => widget.onSelected(
                    id: p['id'] as String,
                    name: name,
                    isOnline: online,
                    avatar: avatar,
                  ),
                );
              }),
              if (filtered.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No matches',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Color(0xFF8E88A3),
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
