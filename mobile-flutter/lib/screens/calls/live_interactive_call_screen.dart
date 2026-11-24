import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/profiles_data.dart';

class LiveInteractiveCallScreen extends StatefulWidget {
  final String userName;
  final String avatarUrl;
  final bool isVideo;

  /// Fired once when the call is ended from this screen (End Call or the
  /// in-call back button), with the connected duration.
  final ValueChanged<Duration>? onCallEnded;

  const LiveInteractiveCallScreen({
    super.key,
    required this.userName,
    required this.avatarUrl,
    this.isVideo = false,
    this.onCallEnded,
  });

  @override
  State<LiveInteractiveCallScreen> createState() => _LiveInteractiveCallScreenState();
}

class _LiveInteractiveCallScreenState extends State<LiveInteractiveCallScreen>
    with TickerProviderStateMixin {
  bool _isConnected = false;
  bool _isEnded = false;
  bool _isMuted = false;
  bool _isSpeaker = true;
  bool _isCameraOn = true;
  int _seconds = 0;
  Timer? _timer;
  Timer? _connectTimer;

  int _rating = 5;

  final List<String> _icebreakers = [
    'If you could teleport right now, where in Mumbai would we go?',
    'What is the best dish you can cook from scratch in 15 minutes?',
    'What song instantly puts you in a good mood on a rainy day?',
    'Subko coffee or vintage chai tapri with friends?',
    'What is your all-time favorite travel memory?',
  ];
  int _icebreakerIndex = 0;

  late AnimationController _waveController;
  late AnimationController _breatheController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // Transition from Ringing to Connected after 2.5 seconds
    _connectTimer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() => _isConnected = true);
        _startTimer();
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _seconds++);
      }
    });
  }

  void _endCall() {
    if (_isEnded) return;
    _connectTimer?.cancel();
    _timer?.cancel();
    widget.onCallEnded?.call(Duration(seconds: _seconds));
    setState(() => _isEnded = true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _connectTimer?.cancel();
    _waveController.dispose();
    _breatheController.dispose();
    super.dispose();
  }

  String get _formattedTime {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (_isEnded) {
      return _buildCallEndedScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D070C),
      body: SafeArea(
        child: Stack(
          children: [
            // Video Mode: Fullscreen animated remote video view
            if (widget.isVideo) _buildVideoBackground(),

            // Audio Mode: Center Avatar & Waves
            if (!widget.isVideo) _buildAudioCenterView(),

            // Top Status Pill
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _endCall,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0x66000000),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xCC1B1119),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: _isConnected ? const Color(0x6622C55E) : const Color(0x66EC4899),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isConnected ? const Color(0xFF22C55E) : const Color(0xFFF59E0B),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isConnected
                              ? 'Connected with ${widget.userName} • 20 coins/min'
                              : widget.isVideo
                                  ? 'YoUnMe HD Video • Ringing...'
                                  : 'YoUnMe HD Voice • Ringing...',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xCC1B1119),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _formattedTime,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            // PiP Local Camera (Video mode only)
            if (widget.isVideo && _isConnected)
              Positioned(
                top: 70,
                right: 16,
                child: _buildLocalCameraPip(),
              ),

            // Bottom Stack: Icebreaker Topic Card + Bottom 4-button dock (Clean vertical column, zero overlap)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ICEBREAKER TOPIC CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xE61B1119),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFF2E1E2B)),
                      boxShadow: const [
                        BoxShadow(color: Colors.black54, blurRadius: 16, offset: Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Text('⚡', style: TextStyle(fontSize: 13)),
                                SizedBox(width: 6),
                                Text(
                                  'ICEBREAKER TOPIC',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF38BDF8),
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _icebreakerIndex = (_icebreakerIndex + 1) % _icebreakers.length;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0x3338BDF8),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Row(
                                  children: [
                                    Text('Next', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF38BDF8))),
                                    SizedBox(width: 3),
                                    Icon(Icons.refresh, size: 11, color: Color(0xFF38BDF8)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '"${_icebreakers[_icebreakerIndex]}"',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // BOTTOM DOCK
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xF21B1119),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0xFF2E1E2B)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Mute button
                        _dockButton(
                          icon: _isMuted ? Icons.mic_off : Icons.mic,
                          label: _isMuted ? 'Muted' : 'Mute',
                          active: _isMuted,
                          onTap: () => setState(() => _isMuted = !_isMuted),
                        ),
                        // Speaker / Camera button
                        _dockButton(
                          icon: _isSpeaker ? Icons.volume_up : Icons.volume_off,
                          label: 'Speaker',
                          active: _isSpeaker,
                          activeColor: const Color(0xFF22C55E),
                          onTap: () => setState(() => _isSpeaker = !_isSpeaker),
                        ),
                        // Camera toggle button
                        _dockButton(
                          icon: _isCameraOn ? Icons.videocam : Icons.videocam_off,
                          label: _isCameraOn ? 'Video On' : 'Video Off',
                          active: _isCameraOn,
                          activeColor: const Color(0xFF38BDF8),
                          onTap: () => setState(() => _isCameraOn = !_isCameraOn),
                        ),
                        // Red End Call button
                        GestureDetector(
                          onTap: _endCall,
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x80EF4444),
                                  blurRadius: 16,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.call_end, color: Colors.white, size: 24),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dockButton({
    required IconData icon,
    required String label,
    required bool active,
    Color activeColor = const Color(0xFFEC4899),
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? activeColor.withValues(alpha: 0.25) : const Color(0x1AFFFFFF),
              border: Border.all(
                color: active ? activeColor : const Color(0x33FFFFFF),
              ),
            ),
            child: Icon(
              icon,
              size: 20,
              color: active ? activeColor : Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: active ? activeColor : const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioCenterView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Glowing gradient circle avatar
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFE11D48), Color(0xFFEC4899)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x66EC4899),
                  blurRadius: 36,
                  spreadRadius: 6,
                ),
              ],
            ),
            padding: const EdgeInsets.all(4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(65),
              child: SafeProfileImage(imageUrl: widget.avatarUrl, width: 122, height: 122),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.userName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            _isConnected ? '• Connected • Speaking...' : 'Connecting encrypted voice line...',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _isConnected ? const Color(0xFF22C55E) : const Color(0xFFF59E0B),
            ),
          ),
          const SizedBox(height: 20),

          // Animated audio waveform bars
          AnimatedBuilder(
            animation: _waveController,
            builder: (context, _) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(14, (i) {
                  final sinVal = sin((_waveController.value * 2 * pi) + (i * 0.45));
                  final height = _isConnected ? (12.0 + (sinVal.abs() * 28.0)) : 8.0;
                  return Container(
                    width: 4,
                    height: height,
                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                    decoration: BoxDecoration(
                      color: _isConnected ? const Color(0xFFEC4899) : const Color(0x4DFFFFFF),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              );
            },
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildVideoBackground() {
    return AnimatedBuilder(
      animation: _breatheController,
      builder: (context, _) {
        final scale = 1.0 + (_breatheController.value * 0.03);
        return Transform.scale(
          scale: scale,
          child: Stack(
            fit: StackFit.expand,
            children: [
              SafeProfileImage(imageUrl: widget.avatarUrl, fit: BoxFit.cover),
              // Subtle dark gradient vignette
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0x99000000),
                      Colors.transparent,
                      Colors.transparent,
                      Color(0xCC000000),
                    ],
                    stops: [0.0, 0.2, 0.7, 1.0],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocalCameraPip() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100,
        height: 140,
        decoration: BoxDecoration(
          color: const Color(0xFF1B1119),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x66FFFFFF), width: 1.5),
          boxShadow: const [
            BoxShadow(color: Colors.black54, blurRadius: 16, offset: Offset(0, 4)),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Selfie camera simulation (realistic portrait of Aarav or user avatar)
            const SafeProfileImage(
              imageUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=800&q=80',
              fit: BoxFit.cover,
            ),
            // Pill: • You
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xCC000000),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(radius: 3, backgroundColor: Color(0xFF22C55E)),
                    SizedBox(width: 4),
                    Text('You', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallEndedScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF0D070C),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Green avatar circle
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF22C55E), width: 3),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(45),
                    child: SafeProfileImage(imageUrl: widget.avatarUrl, width: 90, height: 90),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Call Ended',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  '${widget.isVideo ? 'Video' : 'Audio'} session with ${widget.userName}',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                ),
                const SizedBox(height: 4),
                Text(
                  'Duration: $_formattedTime',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF22C55E)),
                ),
                const SizedBox(height: 28),

                // 5-star interactive rating bar
                Text(
                  'Rate connection quality with ${widget.userName}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white70),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starIndex = index + 1;
                    return GestureDetector(
                      onTap: () => setState(() => _rating = starIndex),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(
                          starIndex <= _rating ? Icons.star : Icons.star_border,
                          size: 32,
                          color: const Color(0xFFF59E0B),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 36),

                // Return to Discovery pink button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE11D48), Color(0xFFEC4899)],
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x66EC4899),
                          blurRadius: 18,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Return to Discovery',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
