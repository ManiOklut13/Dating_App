import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/call_user.dart';
import '../../services/call_history_service.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Full-screen DEMO video call interface.
/// Lifecycle:
///   1. "Calling <name>…" — 2-second simulated ring
///   2. "Connected"       — elapsed timer runs, controls visible
///   3. "Call Ended"      — 1.5-second display, then Navigator.pop
///
/// No real camera/microphone stream is accessed in demo mode.
/// All controls are interactive UI toggles only.
/// ─────────────────────────────────────────────────────────────────────────────
enum _VCallState { calling, ringing, connected, ended }

class VideoCallScreen extends StatefulWidget {
  final CallUser user;

  const VideoCallScreen({super.key, required this.user});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen>
    with TickerProviderStateMixin {
  // ── call state ───────────────────────────────────────────────────────────────
  _VCallState _callState = _VCallState.calling;
  bool _isMuted = false;
  bool _isCameraOn = true;
  bool _isFrontCamera = true;
  bool _isSpeakerOn = true;
  // Controls visibility is driven by _controlsFadeController (no separate bool needed)

  // ── timer ────────────────────────────────────────────────────────────────────
  int _elapsedSeconds = 0;
  Timer? _callTimer;
  Timer? _ringingTimer;
  Timer? _connectTimer;
  Timer? _controlHideTimer;
  DateTime? _connectedAt;

  // ── animations ───────────────────────────────────────────────────────────────
  late AnimationController _pulseController;
  late AnimationController _controlsFadeController;
  late Animation<double> _controlsFade;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _controlsFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: 1.0,
    );
    _controlsFade = _controlsFadeController;

    // Sequence: 1. Calling -> 2. Ringing (after 1.5s) -> 3. Connected (after 3.5s total)
    _ringingTimer = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() => _callState = _VCallState.ringing);
    });

    _connectTimer = Timer(const Duration(milliseconds: 3500), _onConnect);
  }

  void _onConnect() {
    if (!mounted) return;
    _connectedAt = DateTime.now();
    setState(() => _callState = _VCallState.connected);
    _pulseController.stop();

    _callTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsedSeconds++);
    });

    // Auto-hide controls after 4 s
    _scheduleControlHide();
  }

  void _scheduleControlHide() {
    _controlHideTimer?.cancel();
    _controlHideTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted || _callState != _VCallState.connected) return;
      _controlsFadeController.reverse();
    });
  }

  void _showControls() {
    _controlsFadeController.forward();
    _scheduleControlHide();
  }

  void _endCall() {
    _ringingTimer?.cancel();
    _connectTimer?.cancel();
    _callTimer?.cancel();
    _controlHideTimer?.cancel();

    final duration = _callState == _VCallState.connected && _connectedAt != null
        ? DateTime.now().difference(_connectedAt!)
        : Duration.zero;

    CallHistoryService.instance.addEntry(CallHistoryEntry(
      id: 'video-${DateTime.now().millisecondsSinceEpoch}',
      user: widget.user,
      type: CallType.video,
      direction: CallDirection.outgoing,
      timestamp: DateTime.now(),
      duration: duration,
    ));

    setState(() => _callState = _VCallState.ended);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _ringingTimer?.cancel();
    _connectTimer?.cancel();
    _callTimer?.cancel();
    _controlHideTimer?.cancel();
    _pulseController.dispose();
    _controlsFadeController.dispose();
    super.dispose();
  }

  String get _timerLabel {
    final m = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get _statusLabel {
    switch (_callState) {
      case _VCallState.calling:
        return 'Calling ${widget.user.name}...';
      case _VCallState.ringing:
        return 'Ringing...';
      case _VCallState.connected:
        return 'Connected · Demo ($_timerLabel)';
      case _VCallState.ended:
        return 'Call Ended';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _callState == _VCallState.connected ? _showControls : null,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Remote video area (large) ────────────────────────────────────
            _RemoteVideoArea(
              user: widget.user,
              callState: _callState,
              pulseController: _pulseController,
            ),

            // ── Status overlay ───────────────────────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: _VideoTopOverlay(
                  user: widget.user,
                  statusLabel: _statusLabel,
                  callState: _callState,
                  onBack: _callState != _VCallState.ended ? _endCall : null,
                ),
              ),
            ),

            // ── Local camera PIP (top-right) ─────────────────────────────────
            if (_callState == _VCallState.connected)
              Positioned(
                top: MediaQuery.of(context).padding.top + 70,
                right: 16,
                child: _LocalCameraPip(
                  isCameraOn: _isCameraOn,
                  isFrontCamera: _isFrontCamera,
                ),
              ),

            // ── Controls bar (bottom) — fades in/out ─────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _controlsFade,
                child: SafeArea(
                  child: _VideoControls(
                    isMuted: _isMuted,
                    isCameraOn: _isCameraOn,
                    isFrontCamera: _isFrontCamera,
                    isSpeakerOn: _isSpeakerOn,
                    callState: _callState,
                    onMuteToggle: () => setState(() => _isMuted = !_isMuted),
                    onCameraToggle: () =>
                        setState(() => _isCameraOn = !_isCameraOn),
                    onFlipCamera: () =>
                        setState(() => _isFrontCamera = !_isFrontCamera),
                    onSpeakerToggle: () =>
                        setState(() => _isSpeakerOn = !_isSpeakerOn),
                    onEndCall:
                        _callState != _VCallState.ended ? _endCall : null,
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

// ── Remote video area ─────────────────────────────────────────────────────────
class _RemoteVideoArea extends StatelessWidget {
  final CallUser user;
  final _VCallState callState;
  final AnimationController pulseController;

  const _RemoteVideoArea({
    required this.user,
    required this.callState,
    required this.pulseController,
  });

  String get _initials {
    final parts = user.name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }

  Color get _bgColor {
    final colors = [
      const Color(0xFF9B51E0),
      const Color(0xFFFF2D55),
      const Color(0xFF00E5FF),
      const Color(0xFFFF6B35),
    ];
    final idx = user.id.codeUnits.fold(0, (a, b) => a + b) % colors.length;
    return colors[idx];
  }

  @override
  Widget build(BuildContext context) {
    // Gradient background representing remote video
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _bgColor.withOpacity(0.3),
            const Color(0xFF080A10),
            _bgColor.withOpacity(0.15),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar (larger for video call)
            AnimatedBuilder(
              animation: pulseController,
              builder: (_, child) {
                final scale = (callState == _VCallState.calling || callState == _VCallState.ringing)
                    ? 1.0 + (pulseController.value * 0.08)
                    : 1.0;
                return Transform.scale(scale: scale, child: child);
              },
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: callState == _VCallState.connected
                        ? const Color(0xFF00E676).withOpacity(0.6)
                        : const Color(0xFFFF2D55).withOpacity(0.5),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _bgColor.withOpacity(0.4),
                      blurRadius: 48,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: user.avatarUrl != null
                      ? Image.network(user.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildInitialsWidget())
                      : _buildInitialsWidget(),
                ),
              ),
            ),

            if (callState == _VCallState.calling) ...[
              const SizedBox(height: 24),
              _DotIndicator(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInitialsWidget() => Container(
        color: _bgColor,
        alignment: Alignment.center,
        child: Text(
          _initials,
          style: const TextStyle(
            fontSize: 56,
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
}

/// Animated three-dot "ringing" indicator.
class _DotIndicator extends StatefulWidget {
  @override
  State<_DotIndicator> createState() => _DotIndicatorState();
}

class _DotIndicatorState extends State<_DotIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final t = (_c.value + i / 3) % 1.0;
            final scale = 0.6 + 0.4 * sin(t * pi);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white54,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// ── Top overlay ───────────────────────────────────────────────────────────────
class _VideoTopOverlay extends StatelessWidget {
  final CallUser user;
  final String statusLabel;
  final _VCallState callState;
  final VoidCallback? onBack;

  const _VideoTopOverlay({
    required this.user,
    required this.statusLabel,
    required this.callState,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                size: 30, color: Colors.white70),
            onPressed: onBack ?? () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    if (user.isVerified) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.verified,
                          color: Color(0xFF3B82F6), size: 16),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    statusLabel,
                    key: ValueKey(statusLabel),
                    style: TextStyle(
                      fontSize: 13,
                      color: callState == _VCallState.connected
                          ? const Color(0xFF00E676)
                          : Colors.white60,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Demo tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFF2D55).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFF2D55).withOpacity(0.4)),
            ),
            child: const Text('DEMO CALL — SIMULATED VIDEO',
                style: TextStyle(
                    fontSize: 9.5,
                    color: Color(0xFFFF2D55),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8)),
          ),
        ],
      ),
    );
  }
}

// ── Local camera PIP ──────────────────────────────────────────────────────────
class _LocalCameraPip extends StatelessWidget {
  final bool isCameraOn;
  final bool isFrontCamera;

  const _LocalCameraPip(
      {required this.isCameraOn, required this.isFrontCamera});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 90,
        height: 120,
        color: const Color(0xFF1A1D2E),
        child: isCameraOn
            ? Stack(
                fit: StackFit.expand,
                children: [
                  // Simulated local camera (gradient placeholder)
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0A1020), Color(0xFF1A0A20)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  const Center(
                    child: Icon(Icons.person, color: Colors.white30, size: 40),
                  ),
                  Positioned(
                    bottom: 4,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        isFrontCamera ? 'Front' : 'Rear',
                        style: const TextStyle(
                            fontSize: 9, color: Colors.white38),
                      ),
                    ),
                  ),
                ],
              )
            : const Center(
                child: Icon(Icons.videocam_off, color: Colors.white30, size: 28),
              ),
      ),
    );
  }
}

// ── Video controls bar ────────────────────────────────────────────────────────
class _VideoControls extends StatelessWidget {
  final bool isMuted;
  final bool isCameraOn;
  final bool isFrontCamera;
  final bool isSpeakerOn;
  final _VCallState callState;
  final VoidCallback? onMuteToggle;
  final VoidCallback? onCameraToggle;
  final VoidCallback? onFlipCamera;
  final VoidCallback? onSpeakerToggle;
  final VoidCallback? onEndCall;

  const _VideoControls({
    required this.isMuted,
    required this.isCameraOn,
    required this.isFrontCamera,
    required this.isSpeakerOn,
    required this.callState,
    required this.onMuteToggle,
    required this.onCameraToggle,
    required this.onFlipCamera,
    required this.onSpeakerToggle,
    required this.onEndCall,
  });

  @override
  Widget build(BuildContext context) {
    final bool active = callState != _VCallState.ended;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.85),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Mute mic
          _VControlBtn(
            icon: isMuted ? Icons.mic_off : Icons.mic_none,
            label: isMuted ? 'Unmute' : 'Mute',
            active: active,
            onTap: active ? onMuteToggle : null,
          ),

          // Camera on/off
          _VControlBtn(
            icon: isCameraOn ? Icons.videocam : Icons.videocam_off,
            label: isCameraOn ? 'Camera\nOn' : 'Camera\nOff',
            active: active,
            onTap: active ? onCameraToggle : null,
          ),

          // End Call
          _EndCallBtnV(onTap: onEndCall),

          // Flip camera
          _VControlBtn(
            icon: Icons.flip_camera_android,
            label: 'Flip\nCamera',
            active: active && isCameraOn,
            onTap: active && isCameraOn ? onFlipCamera : null,
          ),

          // Speaker
          _VControlBtn(
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

class _VControlBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const _VControlBtn(
      {required this.icon,
      required this.label,
      required this.active,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active
                  ? Colors.white.withOpacity(0.15)
                  : Colors.white.withOpacity(0.05),
              border:
                  Border.all(color: Colors.white.withOpacity(active ? 0.22 : 0.06)),
            ),
            child: Icon(icon,
                color: active ? Colors.white : Colors.white24, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 10,
                color: active ? Colors.white60 : Colors.white24,
                height: 1.3),
          ),
        ],
      ),
    );
  }
}

class _EndCallBtnV extends StatelessWidget {
  final VoidCallback? onTap;
  const _EndCallBtnV({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: onTap != null
                  ? const Color(0xFFFF2D55)
                  : Colors.grey.withOpacity(0.3),
              boxShadow: onTap != null
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFF2D55).withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 2,
                      )
                    ]
                  : null,
            ),
            child: const Icon(Icons.call_end, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 6),
          Text(
            'End Call',
            style: TextStyle(
                fontSize: 10,
                color: onTap != null ? Colors.white60 : Colors.white24),
          ),
        ],
      ),
    );
  }
}
