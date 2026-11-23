import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/call_user.dart';
import '../../services/call_history_service.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Full-screen DEMO audio call interface.
/// Lifecycle:
///   1. "Calling <name>…" — 2-second simulated ring
///   2. "Connected"       — elapsed timer runs
///   3. "Call Ended"      — 1.5-second display, then Navigator.pop
///
/// No real audio stream is created. This is an interactive UI demo.
/// ─────────────────────────────────────────────────────────────────────────────
enum _CallState { calling, ringing, connected, ended }

class AudioCallScreen extends StatefulWidget {
  final CallUser user;

  const AudioCallScreen({super.key, required this.user});

  @override
  State<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen>
    with TickerProviderStateMixin {
  // ── call state ──────────────────────────────────────────────────────────────
  _CallState _callState = _CallState.calling;
  bool _isMuted = false;
  bool _isSpeakerOn = false;

  // ── timer ────────────────────────────────────────────────────────────────────
  int _elapsedSeconds = 0;
  Timer? _callTimer;
  Timer? _ringingTimer;
  Timer? _connectTimer;
  DateTime? _connectedAt;

  // ── animation ────────────────────────────────────────────────────────────────
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for the avatar ring while calling/ringing
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Sequence: 1. Calling -> 2. Ringing (after 1.5s) -> 3. Connected (after 3.5s total)
    _ringingTimer = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() => _callState = _CallState.ringing);
    });

    _connectTimer = Timer(const Duration(milliseconds: 3500), _onConnect);
  }

  void _onConnect() {
    if (!mounted) return;
    _connectedAt = DateTime.now();
    setState(() => _callState = _CallState.connected);
    _pulseController.stop();
    _pulseController.reset();

    // Start elapsed timer
    _callTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsedSeconds++);
    });
  }

  void _endCall() {
    _ringingTimer?.cancel();
    _connectTimer?.cancel();
    _callTimer?.cancel();

    // Record history entry
    final duration = _callState == _CallState.connected && _connectedAt != null
        ? DateTime.now().difference(_connectedAt!)
        : Duration.zero;

    CallHistoryService.instance.addEntry(CallHistoryEntry(
      id: 'audio-${DateTime.now().millisecondsSinceEpoch}',
      user: widget.user,
      type: CallType.audio,
      direction: CallDirection.outgoing,
      timestamp: DateTime.now(),
      duration: duration,
    ));

    setState(() => _callState = _CallState.ended);

    // Return to previous screen after brief "ended" display
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _ringingTimer?.cancel();
    _connectTimer?.cancel();
    _callTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  // ── helpers ──────────────────────────────────────────────────────────────────
  String get _timerLabel {
    final m = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get _statusLabel {
    switch (_callState) {
      case _CallState.calling:
        return 'Calling ${widget.user.name}...';
      case _CallState.ringing:
        return 'Ringing...';
      case _CallState.connected:
        return 'Connected · Demo ($_timerLabel)';
      case _CallState.ended:
        return 'Call Ended';
    }
  }

  // ── build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0B10),
              Color(0xFF100818),
              Color(0xFF0A1020),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── top bar ─────────────────────────────────────────────────────
              _TopBar(onBack: _callState == _CallState.ended ? null : _endCall),

              // ── avatar + name + status ───────────────────────────────────────
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Pulsing ring around avatar while calling
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (_, child) {
                        final scale = (_callState == _CallState.calling || _callState == _CallState.ringing)
                            ? _pulseAnimation.value
                            : 1.0;
                        return Transform.scale(
                          scale: scale,
                          child: child,
                        );
                      },
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: (_callState == _CallState.calling || _callState == _CallState.ringing)
                                ? const Color(0xFFFF2D55).withOpacity(0.6)
                                : _callState == _CallState.connected
                                    ? const Color(0xFF00E676).withOpacity(0.7)
                                    : Colors.grey.withOpacity(0.4),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (_callState == _CallState.connected
                                      ? const Color(0xFF00E676)
                                      : const Color(0xFFFF2D55))
                                  .withOpacity(0.25),
                              blurRadius: 32,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: _UserAvatar(user: widget.user, size: 140),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Name + verified badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.user.name,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        if (widget.user.isVerified) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.verified,
                              color: Color(0xFF3B82F6), size: 22),
                        ],
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Status / timer
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _statusLabel,
                        key: ValueKey(_statusLabel),
                        style: TextStyle(
                          fontSize: 16,
                          color: _callState == _CallState.connected
                              ? const Color(0xFF00E676)
                              : _callState == _CallState.ended
                                  ? Colors.grey
                                  : Colors.white60,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),

                    if (_callState == _CallState.calling || _callState == _CallState.ringing) ...[
                      const SizedBox(height: 6),
                      Text(
                        widget.user.city,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.white38),
                      ),
                    ],

                    // Demo disclaimer
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF2D55).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFFFF2D55).withOpacity(0.35)),
                      ),
                      child: const Text(
                        'DEMO CALL',
                        style:
                            TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFFF2D55), letterSpacing: 1),
                      ),
                    ),
                  ],
                ),
              ),

              // ── controls ─────────────────────────────────────────────────────
              _AudioControls(
                isMuted: _isMuted,
                isSpeakerOn: _isSpeakerOn,
                callState: _callState,
                onMuteToggle: () => setState(() => _isMuted = !_isMuted),
                onSpeakerToggle: () =>
                    setState(() => _isSpeakerOn = !_isSpeakerOn),
                onEndCall: _callState != _CallState.ended ? _endCall : null,
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ── sub-widgets ────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final VoidCallback? onBack;
  const _TopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                size: 30, color: Colors.white70),
            onPressed: onBack ??
                () => Navigator.of(context).pop(),
            tooltip: 'Minimise',
          ),
          const Expanded(
            child: Text(
              'Audio Call',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 48), // balance the back button
        ],
      ),
    );
  }
}

class _AudioControls extends StatelessWidget {
  final bool isMuted;
  final bool isSpeakerOn;
  final _CallState callState;
  final VoidCallback? onMuteToggle;
  final VoidCallback? onSpeakerToggle;
  final VoidCallback? onEndCall;

  const _AudioControls({
    required this.isMuted,
    required this.isSpeakerOn,
    required this.callState,
    required this.onMuteToggle,
    required this.onSpeakerToggle,
    required this.onEndCall,
  });

  @override
  Widget build(BuildContext context) {
    final bool active = callState != _CallState.ended;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Mute
          _ControlButton(
            icon: isMuted ? Icons.mic_off : Icons.mic,
            label: isMuted ? 'Unmute' : 'Mute',
            active: active,
            onTap: active ? onMuteToggle : null,
          ),

          // End Call (large, red)
          _EndCallButton(onTap: onEndCall),

          // Speaker
          _ControlButton(
            icon: isSpeakerOn ? Icons.volume_up : Icons.volume_off,
            label: isSpeakerOn ? 'Speaker\nOn' : 'Speaker\nOff',
            active: active,
            onTap: active ? onSpeakerToggle : null,
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.active,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active
                  ? Colors.white.withOpacity(0.12)
                  : Colors.white.withOpacity(0.04),
              border: Border.all(
                color: Colors.white.withOpacity(active ? 0.2 : 0.08),
              ),
            ),
            child: Icon(icon,
                color: active ? Colors.white : Colors.white30, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: active ? Colors.white60 : Colors.white24,
            ),
          ),
        ],
      ),
    );
  }
}

class _EndCallButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _EndCallButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: onTap != null
                  ? const Color(0xFFFF2D55)
                  : Colors.grey.withOpacity(0.3),
              boxShadow: onTap != null
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFF2D55).withOpacity(0.5),
                        blurRadius: 24,
                        spreadRadius: 2,
                      )
                    ]
                  : null,
            ),
            child: const Icon(Icons.call_end,
                color: Colors.white, size: 34),
          ),
          const SizedBox(height: 8),
          Text(
            'End Call',
            style: TextStyle(
              fontSize: 12,
              color: onTap != null ? Colors.white60 : Colors.white24,
            ),
          ),
        ],
      ),
    );
  }
}

/// Avatar widget — shows profile photo if [user.avatarUrl] is set, otherwise
/// a coloured circle with the user's initials.
class _UserAvatar extends StatelessWidget {
  final CallUser user;
  final double size;

  const _UserAvatar({required this.user, required this.size});

  String get _initials {
    final parts = user.name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  // Deterministic colour from user id
  Color get _bgColor {
    final colors = [
      const Color(0xFF9B51E0),
      const Color(0xFFFF2D55),
      const Color(0xFF00E5FF),
      const Color(0xFFFF6B35),
      const Color(0xFF00E676),
    ];
    final idx = user.id.codeUnits.fold(0, (a, b) => a + b) % colors.length;
    return colors[idx];
  }

  @override
  Widget build(BuildContext context) {
    if (user.avatarUrl != null) {
      return Image.network(
        user.avatarUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildInitials(),
      );
    }
    return _buildInitials();
  }

  Widget _buildInitials() {
    return Container(
      width: size,
      height: size,
      color: _bgColor,
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: TextStyle(
          fontSize: size * 0.35,
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
