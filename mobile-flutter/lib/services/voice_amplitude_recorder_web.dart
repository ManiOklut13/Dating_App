import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:math' as math;
import 'dart:typed_data';

/// Web microphone recorder using standard `dart:js_interop` + Web Audio
/// `AnalyserNode` to emit live voice frequency amplitude levels (0.0 - 1.0).
class VoiceAmplitudeRecorder {
  JSObject? _mediaStream;
  JSObject? _audioCtx;
  JSObject? _analyser;
  Timer? _sampleTimer;
  final _random = math.Random();
  double _phase = 0;

  /// Starts browser microphone recording and emits live frequency samples.
  /// Falls back cleanly if mic permission is denied or unavailable.
  Future<bool> start(void Function(double level) onLevel) async {
    await stop();
    try {
      final nav = globalContext.getProperty<JSObject?>('navigator'.toJS);
      final mediaDevices = nav?.getProperty<JSObject?>('mediaDevices'.toJS);
      if (mediaDevices == null) {
        _startFallback(onLevel);
        return false;
      }

      final constraints = <String, Object?>{'audio': true}.jsify();
      final streamPromise = mediaDevices.callMethod<JSPromise<JSAny?>>(
        'getUserMedia'.toJS,
        constraints,
      );
      final streamAny = await streamPromise.toDart;
      if (streamAny == null) {
        _startFallback(onLevel);
        return false;
      }
      _mediaStream = streamAny as JSObject;

      final audioCtxCtor =
          globalContext.getProperty<JSFunction?>('AudioContext'.toJS) ??
              globalContext.getProperty<JSFunction?>('webkitAudioContext'.toJS);
      if (audioCtxCtor == null) {
        _startFallback(onLevel);
        return false;
      }

      _audioCtx = audioCtxCtor.callAsConstructor<JSObject>();
      final state =
          _audioCtx!.getProperty<JSString?>('state'.toJS)?.toDart;
      if (state == 'suspended') {
        await _audioCtx!
            .callMethod<JSPromise<JSAny?>>('resume'.toJS)
            .toDart;
      }

      final source = _audioCtx!.callMethod<JSObject>(
        'createMediaStreamSource'.toJS,
        _mediaStream,
      );
      _analyser = _audioCtx!.callMethod<JSObject>('createAnalyser'.toJS);
      _analyser!.setProperty('fftSize'.toJS, 64.toJS);
      _analyser!.setProperty('smoothingTimeConstant'.toJS, 0.72.toJS);
      source.callMethod<JSAny?>('connect'.toJS, _analyser);

      final binCount =
          _analyser!.getProperty<JSNumber?>('frequencyBinCount'.toJS)?.toDartInt ??
              32;
      final jsFreqArray = Uint8List(binCount).toJS;

      _sampleTimer = Timer.periodic(const Duration(milliseconds: 65), (_) {
        if (_analyser == null) return;
        _analyser!.callMethod<JSAny?>('getByteFrequencyData'.toJS, jsFreqArray);
        final bytes = jsFreqArray.toDart;
        int sum = 0;
        for (int i = 0; i < bytes.length; i++) {
          sum += bytes[i];
        }
        final avg = bytes.isEmpty ? 0.0 : sum / bytes.length;
        final normalized = (avg / 95.0).clamp(0.08, 1.0);
        onLevel(normalized);
      });
      return true;
    } catch (_) {
      _startFallback(onLevel);
      return false;
    }
  }

  void _startFallback(void Function(double level) onLevel) {
    _sampleTimer = Timer.periodic(const Duration(milliseconds: 70), (_) {
      _phase += 0.45;
      final synthetic =
          (0.25 + 0.45 * math.sin(_phase).abs() + _random.nextDouble() * 0.25)
              .clamp(0.08, 1.0);
      onLevel(synthetic);
    });
  }

  Future<void> stop() async {
    _sampleTimer?.cancel();
    _sampleTimer = null;

    if (_mediaStream != null) {
      try {
        final tracks = _mediaStream!.callMethod<JSObject>('getAudioTracks'.toJS);
        final length =
            tracks.getProperty<JSNumber?>('length'.toJS)?.toDartInt ?? 0;
        for (int i = 0; i < length; i++) {
          final track = tracks.getProperty<JSObject?>(i.toJS);
          track?.callMethod<JSAny?>('stop'.toJS);
        }
      } catch (_) {}
      _mediaStream = null;
    }

    if (_audioCtx != null) {
      try {
        await _audioCtx!
            .callMethod<JSPromise<JSAny?>>('close'.toJS)
            .toDart;
      } catch (_) {}
      _audioCtx = null;
    }
    _analyser = null;
  }

  void dispose() {
    stop();
  }
}
