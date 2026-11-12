// ─────────────────────────────────────────────────────────────────────────────
// Plan Date CTA Button - Restyled
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../repository/plan_date_repository.dart';

class PlanDateCta extends StatefulWidget {
  final bool enabled;
  final bool isLoading;
  final String? partnerName;
  final VoidCallback? onPressed;

  const PlanDateCta({
    super.key,
    required this.enabled,
    required this.isLoading,
    required this.partnerName,
    required this.onPressed,
  });

  @override
  State<PlanDateCta> createState() => _PlanDateCtaState();
}

class _PlanDateCtaState extends State<PlanDateCta> with SingleTickerProviderStateMixin {
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
    final label = widget.partnerName != null
        ? 'Plan date with ${widget.partnerName!}'
        : 'Plan date';

    return Semantics(
      label: '$label — costs ${PlanDateConfig.coinCost} coins',
      button: true,
      enabled: widget.enabled,
      child: GestureDetector(
        onTapDown: widget.enabled && !widget.isLoading ? (_) => _controller.forward() : null,
        onTapUp: widget.enabled && !widget.isLoading
            ? (_) {
                _controller.reverse();
                widget.onPressed?.call();
              }
            : null,
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
            height: 64,
            decoration: BoxDecoration(
              gradient: widget.enabled
                  ? const LinearGradient(
                      colors: [Color(0xFFF0318B), Color(0xFFA21CAF)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : null,
              color: widget.enabled ? null : const Color(0xFF16121F),
              borderRadius: BorderRadius.circular(32),
              boxShadow: widget.enabled
                  ? [
                      BoxShadow(
                        color: const Color(0xFFF0318B).withValues(alpha: 0.5),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
              border: widget.enabled
                  ? null
                  : Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  if (widget.isLoading)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  else ...[
                    Icon(
                      Icons.send_outlined,
                      color: widget.enabled ? Colors.white : const Color(0xFF8E88A3),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: widget.enabled ? Colors.white : const Color(0xFF8E88A3),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.monetization_on_rounded,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${PlanDateConfig.coinCost}',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: widget.enabled ? Colors.white : const Color(0xFF8E88A3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
