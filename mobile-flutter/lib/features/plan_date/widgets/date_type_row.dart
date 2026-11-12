// ─────────────────────────────────────────────────────────────────────────────
// Date Type Row — horizontally scrollable chips - Restyled
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../models/plan_date_model.dart';

class DateTypeRow extends StatelessWidget {
  final List<DateType> types;
  final String? selectedId;
  final ValueChanged<String> onSelect;

  const DateTypeRow({
    super.key,
    required this.types,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Date Type',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              'Swipe for more >',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF8E88A3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ScrollConfiguration(
            behavior: const _NoGlowBehavior(),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 16),
              physics: const BouncingScrollPhysics(),
              itemCount: types.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final type = types[i];
                final selected = type.id == selectedId;
                return _TypeCard(
                  type: type,
                  selected: selected,
                  onTap: () => onSelect(type.id),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _TypeCard extends StatefulWidget {
  final DateType type;
  final bool selected;
  final VoidCallback onTap;

  const _TypeCard({required this.type, required this.selected, required this.onTap});

  @override
  State<_TypeCard> createState() => _TypeCardState();
}

class _TypeCardState extends State<_TypeCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${widget.type.label} date type',
      selected: widget.selected,
      button: true,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 110,
            height: 100,
            decoration: BoxDecoration(
              gradient: widget.selected
                  ? const LinearGradient(
                      colors: [Color(0xFFF0318B), Color(0xFFA21CAF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: widget.selected ? null : const Color(0xFF16121F),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: widget.selected
                    ? Colors.transparent
                    : Colors.white.withValues(alpha: 0.06),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.type.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 8),
                Text(
                  widget.type.label,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── No-glow scroll behaviour ─────────────────────────────────────────────────
class _NoGlowBehavior extends ScrollBehavior {
  const _NoGlowBehavior();

  @override
  Widget buildOverscrollIndicator(
          BuildContext context, Widget child, ScrollableDetails details) =>
      child;
}
