import 'package:flutter/material.dart';
import '../../services/theme_provider.dart';
import 'final_onboarding_step.dart';

class VoiceVerificationPage extends StatefulWidget {
  const VoiceVerificationPage({super.key});

  @override
  State<VoiceVerificationPage> createState() => _VoiceVerificationPageState();
}

class _VoiceVerificationPageState extends State<VoiceVerificationPage> {
  bool _isRecording = false;
  bool _isVerified = false;

  Future<void> _startVoiceCheck() async {
    setState(() => _isRecording = true);
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    setState(() {
      _isRecording = false;
      _isVerified = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Voice Verification',
            style: TextStyle(color: Colors.white70, fontSize: 15)),
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
                  color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Tap the microphone button and read the phrase below clearly',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
            const SizedBox(height: 28),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFF16161D),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFFFF2E55).withOpacity(0.5)),
              ),
              child: const Text(
                '"Hey YoUnMe, this is my real voice and I am ready to connect."',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 40),

            GestureDetector(
              onTap: (_isRecording || _isVerified) ? null : _startVoiceCheck,
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isVerified
                      ? Colors.green
                      : (_isRecording
                          ? Colors.amber[700]
                          : const Color(0xFFFF2E55)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF2E55).withOpacity(0.45),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: Icon(
                  _isVerified ? Icons.check_rounded : Icons.mic_rounded,
                  color: Colors.white,
                  size: 44,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _isRecording
                  ? 'Listening... Speak clearly'
                  : (_isVerified
                      ? 'Voice Verified Successfully!'
                      : 'Tap Mic to Start'),
              style: TextStyle(
                color: _isVerified ? Colors.greenAccent : Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
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
                      borderRadius: BorderRadius.circular(16)),
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
                                    context, '/home', (route) => false);
                              },
                            ),
                          ),
                        );
                      }
                    : null,
                child: const Text('Next: App Appearance (Step 5)',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
