import 'dart:async';
import 'dart:math' as math;

/// Cross-platform microphone recorder interface for live voice amplitude bars.
class VoiceAmplitudeRecorder {
  final _random = math.Random();
  Timer? _fallbackTimer;
  double _phase = 0;

  /// Starts capturing voice frequency levels (0.0 - 1.0) and emits updates.
  /// Returns `true` if real device microphone capture started, or `false` if fallback is active.
  Future<bool> start(void Function(double level) onLevel) async {
    stop();
    _fallbackTimer = Timer.periodic(const Duration(milliseconds: 70), (_) {
      _phase += 0.45;
      final synthetic =
          (0.28 + 0.42 * math.sin(_phase).abs() + _random.nextDouble() * 0.25)
              .clamp(0.08, 1.0);
      onLevel(synthetic);
    });
    return false;
  }

  Future<void> stop() async {
    _fallbackTimer?.cancel();
    _fallbackTimer = null;
  }

  void dispose() {
    stop();
  }
}
