import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/app_data_service.dart';
import 'plan_date_chooser_sheet.dart';
import 'plan_date_theme.dart';
import 'providers/plan_date_provider.dart';
import 'widgets/date_mode_selector.dart';
import 'widgets/date_pair_card.dart';
import 'widgets/date_type_carousel.dart';
import 'widgets/duration_selector.dart';
import 'widgets/mini_calendar.dart';
import 'widgets/time_picker_box.dart';
import 'widgets/todo_list_card.dart';

/// Full-screen Plan a Date planner seeded with the chat selected in the chooser.
class PlanDateScreen extends ConsumerStatefulWidget {
  const PlanDateScreen({super.key, required this.chatId});

  final String chatId;

  @override
  ConsumerState<PlanDateScreen> createState() => _PlanDateScreenState();
}

class _PlanDateScreenState extends ConsumerState<PlanDateScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(planDateProvider(widget.chatId).notifier).reset();
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _openPartnerChooser() {
    showPlanDateChooser(
      context: context,
      onPick: (chat) {
        ref.read(planDateProvider(widget.chatId).notifier).setPartner(chat);
      },
    );
  }

  void _sendInvite() {
    final notifier = ref.read(planDateProvider(widget.chatId).notifier);
    final invite = notifier.buildInvite();
    if (invite == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choose a partner and a future time first.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ref.read(dateInvitesProvider.notifier).add(invite);
    AppDataService.instance.sendMessage(
      invite.partner.id,
      'Date invite: ${invite.type.label} · ${invite.modeLabel}',
      type: 'date_plan',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Date invite sent to ${invite.partner.name}'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF2A1230),
      ),
    );
    _close();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(planDateProvider(widget.chatId));

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
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 150),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _PlannerHeader(
                        onClose: _close,
                        onCalendar: _openPartnerChooser,
                      ),
                      const SizedBox(height: 20),
                      DatePairCard(chatId: widget.chatId),
                      const SizedBox(height: 18),
                      DateModeSelector(chatId: widget.chatId),
                      const SizedBox(height: 22),
                      DateTypeCarousel(chatId: widget.chatId),
                      const SizedBox(height: 20),
                      _TimeAndCalendarCard(chatId: widget.chatId),
                      const SizedBox(height: 18),
                      TodoListCard(chatId: widget.chatId),
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
              summary: draft.summary,
              enabled: draft.canSend,
              onPressed: _sendInvite,
            ),
          ),
        ],
      ),
    );
  }
}

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
            child: const _HeaderButton(icon: Icons.close_outlined),
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
                    fontSize: 20,
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
            child: const _HeaderButton(icon: Icons.calendar_month_outlined),
          ),
        ),
      ],
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: PDColors.controlFill,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: PDColors.controlBorder),
      ),
      child: Icon(icon, color: PDColors.textPrimary, size: 20),
    );
  }
}

class _GradientText extends StatelessWidget {
  const _GradientText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) =>
          PDGradients.selection.createShader(bounds),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
      ),
    );
  }
}

class _TimeAndCalendarCard extends StatelessWidget {
  const _TimeAndCalendarCard({required this.chatId});

  final String chatId;

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
              TimePickerBox(chatId: chatId),
              const SizedBox(height: 22),
              DurationSelector(chatId: chatId),
            ],
          );
          final right = MiniCalendar(chatId: chatId);

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
        border: Border(
          top: BorderSide(color: PDColors.cardBorder, width: 1),
        ),
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
