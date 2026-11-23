import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class InAppCameraScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final String actionLabel;

  const InAppCameraScreen({
    super.key,
    required this.title,
    required this.subtitle,
    this.actionLabel = 'Capture Photo',
  });

  @override
  State<InAppCameraScreen> createState() => _InAppCameraScreenState();
}

class _InAppCameraScreenState extends State<InAppCameraScreen> {
  CameraController? _controller;
  bool _isReady = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _error = 'No camera found on this device.');
        return;
      }
      final cam = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        cam,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await _controller!.initialize();
      if (mounted) setState(() => _isReady = true);
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Camera preview unavailable: $e');
      }
    }
  }

  Future<void> _capture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      final XFile photo = await _controller!.takePicture();
      if (mounted) Navigator.pop(context, photo.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Capture error: $e')),
        );
      }
    }
  }

  // Fallback in case device has no camera or permission was denied
  void _fallbackSimulatedCapture() {
    Navigator.pop(context, 'assets/images/placeholder_avatar.png');
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(widget.title,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              widget.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF16161D),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFFF2E55), width: 2),
                ),
                clipBehavior: Clip.antiAlias,
                child: _error != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.camera_alt_outlined, color: Colors.grey, size: 48),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF2E55),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.check_circle_outline, size: 18),
                            label: const Text('Use Simulation Capture'),
                            onPressed: _fallbackSimulatedCapture,
                          ),
                        ],
                      )
                    : !_isReady
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFFFF2E55)),
                          )
                        : Stack(
                            fit: StackFit.expand,
                            children: [
                              CameraPreview(_controller!),
                              Center(
                                child: Container(
                                  width: 220,
                                  height: 290,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(140),
                                    border: Border.all(
                                      color: const Color(0xFFFF2E55),
                                      width: 3,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF2E55),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.camera_alt_rounded),
                label: Text(
                  widget.actionLabel,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: _isReady
                    ? _capture
                    : (_error != null ? _fallbackSimulatedCapture : null),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
