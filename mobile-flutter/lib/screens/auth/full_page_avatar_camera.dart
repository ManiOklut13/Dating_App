import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class FullPageAvatarCamera extends StatefulWidget {
  const FullPageAvatarCamera({super.key});

  @override
  State<FullPageAvatarCamera> createState() => _FullPageAvatarCameraState();
}

class _FullPageAvatarCameraState extends State<FullPageAvatarCamera> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _cameraIndex = 0;
  bool _isInitialized = false;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      final frontIdx = _cameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
      );
      _cameraIndex = frontIdx != -1 ? frontIdx : 0;
      await _startController(_cameras[_cameraIndex]);
    } catch (_) {}
  }

  Future<void> _startController(CameraDescription description) async {
    final prev = _controller;
    final nextController = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await prev?.dispose();
    _controller = nextController;

    try {
      await nextController.initialize();
      if (mounted) setState(() => _isInitialized = true);
    } catch (_) {}
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    setState(() => _isInitialized = false);
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    await _startController(_cameras[_cameraIndex]);
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized || _isCapturing) {
      return;
    }
    setState(() => _isCapturing = true);
    try {
      final XFile file = await _controller!.takePicture();
      if (mounted) Navigator.pop(context, File(file.path));
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final previewSize = _controller?.value.previewSize;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_isInitialized && _controller != null)
            previewSize != null
                ? SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: previewSize.height,
                        height: previewSize.width,
                        child: CameraPreview(_controller!),
                      ),
                    ),
                  )
                : CameraPreview(_controller!)
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),

          // Face alignment guide
          IgnorePointer(
            child: Center(
              child: Container(
                width: 250,
                height: 320,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(160),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.65),
                    width: 2.2,
                  ),
                ),
              ),
            ),
          ),

          // Top bar
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.black45,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Center your face for Bitmoji',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.black45,
                      child: IconButton(
                        icon: const Icon(Icons.cameraswitch_rounded, color: Colors.white),
                        onPressed: _switchCamera,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Shutter button
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 28),
                child: GestureDetector(
                  onTap: _takePicture,
                  child: Container(
                    width: 76,
                    height: 76,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3.5),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.face_retouching_natural,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
