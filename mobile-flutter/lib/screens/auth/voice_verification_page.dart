import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/theme_provider.dart';
import '../../services/voice_amplitude_recorder.dart';
import 'final_onboarding_step.dart';

class VoiceVerificationPage extends StatefulWidget {
  const VoiceVerificationPage({super.key});

  @override
  State<VoiceVerificationPage> createState() => _VoiceVerificationPageState();
}

class _VoiceVerificationPageState extends State<VoiceVerificationPage> {
  static const int _barCount = 30;
  static const int _maxRecordSeconds = 4;

  final VoiceAmplitudeRecorder _recorder = VoiceAmplitudeRecorder();
  late List<double> _waveformBars;
  Timer? _elapsedTimer;

  bool _isRecording = false;
  bool _isVerified = false;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _waveformBars = List<double>.filled(_barCount, 0.10, growable: true);
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  String get _formattedDuration {
    final mins = (_elapsedSeconds ~/ 60).toString();
    final secs = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  Future<void> _startVoiceCheck() async {
    if (_isRecording) return;

    _elapsedTimer?.cancel();
    setState(() {
      _isRecording = true;
      _isVerified = false;
      _elapsedSeconds = 0;
      _waveformBars = List<double>.filled(_barCount, 0.10, growable: true);
    });

    await _recorder.start((level) {
      if (!mounted || !_isRecording) return;
      setState(() {
        _waveformBars.removeAt(0);
        _waveformBars.add(level);
      });
    });

    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _elapsedSeconds++);
      if (_elapsedSeconds >= _maxRecordSeconds) {
        _finishRecording();
      }
    });
  }

  Future<void> _finishRecording() async {
    _elapsedTimer?.cancel();
    _elapsedTimer = null;
    await _recorder.stop();
    if (!mounted) return;
    setState(() {
      _isRecording = false;
      _isVerified = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final waveColor = _isVerified
        ? Colors.greenAccent
        : (_isRecording ? const Color(0xFFFF2E55) : Colors.white24);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Voice Verification',
          style: TextStyle(color: Colors.white70, fontSize: 15),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const Text(
              'Verify Your Voice',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Tap the microphone button and read the phrase below clearly',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF16161D),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFFF2E55).withOpacity(0.5),
                ),
              ),
              child: const Text(
                '"Hey YoUnMe, this is my real voice and I am ready to connect."',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17.5,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // WhatsApp-style Live Voice Frequency Bar Waveform
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF16161D),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: _isRecording
                      ? const Color(0xFFFF2E55).withOpacity(0.75)
                      : (_isVerified
                          ? Colors.greenAccent.withOpacity(0.6)
                          : Colors.white12),
                  width: 1.4,
                ),
              ),
              child: Row(
                children: [
                  // Recording dot / verified status + timer
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isRecording
                          ? const Color(0xFFFF2E55)
                          : (_isVerified ? Colors.greenAccent : Colors.white30),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formattedDuration,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontFeatures: [FontFeature.tabularFigures()],
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Symmetrical up-and-down frequency bars
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: _waveformBars.map((level) {
                          final barHeight = 6.0 + (level * 38.0);
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 55),
                            width: 3.5,
                            height: barHeight,
                            decoration: BoxDecoration(
                              color: waveColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Mic / Stop / Verified Circular Action Button
            GestureDetector(
              onTap: _isRecording
                  ? (_elapsedSeconds >= 1 ? _finishRecording : null)
                  : (_isVerified ? null : _startVoiceCheck),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isVerified
                      ? Colors.green
                      : (_isRecording
                          ? const Color(0xFFFF2E55)
                          : const Color(0xFFFF2E55)),
                  boxShadow: [
                    BoxShadow(
                      color: (_isVerified
                              ? Colors.greenAccent
                              : const Color(0xFFFF2E55))
                          .withOpacity(_isRecording ? 0.65 : 0.45),
                      blurRadius: _isRecording ? 30 : 22,
                      spreadRadius: _isRecording ? 4 : 0,
                    ),
                  ],
                ),
                child: Icon(
                  _isVerified
                      ? Icons.check_rounded
                      : (_isRecording ? Icons.stop_rounded : Icons.mic_rounded),
                  color: Colors.white,
                  size: 42,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              _isRecording
                  ? 'Recording voice... Tap stop when done'
                  : (_isVerified
                      ? 'Voice Verified Successfully!'
                      : 'Tap Mic to Start'),
              style: TextStyle(
                color: _isVerified ? Colors.greenAccent : Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            if (_isVerified) ...[
              const SizedBox(height: 6),
              TextButton.icon(
                onPressed: _startVoiceCheck,
                icon: const Icon(
                  Icons.replay_rounded,
                  size: 16,
                  color: Colors.white60,
                ),
                label: const Text(
                  'Record Again',
                  style: TextStyle(color: Colors.white60, fontSize: 13),
                ),
              ),
            ],
            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isVerified
                      ? const Color(0xFFFF2E55)
                      : Colors.grey[850],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _isVerified
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FinalOnboardingStep(
                              onThemeChanged: (mode) {
                                try {
                                  YoUnMeThemeScope.of(context).setThemeMode(mode);
                                } catch (_) {}
                              },
                              onEnterHome: () {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/home',
                                  (route) => false,
                                );
                              },
                            ),
                          ),
                        );
                      }
                    : null,
                child: const Text(
                  'Next: App Appearance (Step 5)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
