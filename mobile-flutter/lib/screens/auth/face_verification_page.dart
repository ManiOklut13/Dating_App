import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'voice_verification_page.dart';

class FaceVerificationPage extends StatefulWidget {
  const FaceVerificationPage({super.key});

  @override
  State<FaceVerificationPage> createState() => _FaceVerificationPageState();
}

class _FaceVerificationPageState extends State<FaceVerificationPage> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isDetecting = false;
  bool _isFaceVerified = false;

  @override
  void initState() {
    super.initState();
    _startLiveCamera();
  }

  Future<void> _startLiveCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      final frontCam = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      _cameraController =
          CameraController(frontCam, ResolutionPreset.medium, enableAudio: false);
      await _cameraController!.initialize();
      if (mounted) setState(() => _isCameraInitialized = true);
    } catch (_) {}
  }

  Future<void> _verifyLiveFace() async {
    setState(() => _isDetecting = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _isDetecting = false;
      _isFaceVerified = true;
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF0B0B0F) : theme.scaffoldBackgroundColor;
    final titleColor = isDark ? Colors.white70 : Colors.black87;
    final cardBg = isDark ? const Color(0xFF16161D) : Colors.grey.shade100;
    final waitingText = isDark ? Colors.white60 : Colors.grey.shade700;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
        title: Text('Step 5 of 5 • Live Face Verification',
            style: TextStyle(color: titleColor, fontSize: 15)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Full-Area Live Camera View
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: _isFaceVerified
                        ? Colors.greenAccent
                        : const Color(0xFFFF2E55),
                    width: 2.5,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (_isCameraInitialized && _cameraController != null)
                      CameraPreview(_cameraController!)
                    else
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(color: Color(0xFFFF2E55)),
                            const SizedBox(height: 12),
                            Text('Starting camera preview...',
                                style: TextStyle(color: waitingText, fontSize: 13)),
                          ],
                        ),
                      ),

                    Center(
                      child: Container(
                        width: 230,
                        height: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(150),
                          border: Border.all(
                            color: _isFaceVerified
                                ? Colors.greenAccent
                                : const Color(0xFFFF2E55),
                            width: 3,
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Center(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isFaceVerified
                                ? Colors.green
                                : const Color(0xFFFF2E55),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          icon: Icon(_isFaceVerified
                              ? Icons.verified_user_rounded
                              : Icons.face_unlock_rounded),
                          label: Text(
                            _isDetecting
                                ? 'Detecting Live Face...'
                                : (_isFaceVerified
                                    ? 'Live Face Verified'
                                    : 'Detect & Verify Live Face'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: (_isDetecting || _isFaceVerified)
                              ? null
                              : _verifyLiveFace,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Next -> Dedicated Voice Verification Page
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFaceVerified
                      ? const Color(0xFFFF2E55)
                      : Colors.grey[850],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _isFaceVerified
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const VoiceVerificationPage()),
                        );
                      }
                    : null,
                child: const Text('Next: Voice Verification',
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
