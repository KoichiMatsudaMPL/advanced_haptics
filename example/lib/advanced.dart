import 'dart:async';
import 'package:advanced_haptics/advanced_haptics.dart';

enum HapticTaskType { download, scan, charge }

class HapticEngine {
  final HapticTaskType type;
  bool _isPlaying = false;
  Timer? _loopTimer;

  HapticEngine(this.type);

  bool get isPlaying => _isPlaying;

  /// Starts the continuous haptic loop for the given progress.
  void start(double progress) {
    if (_isPlaying) return;
    _isPlaying = true;
    _loop(progress);
  }

  /// Updates the haptic feedback based on the new progress value.
  void update(double progress) {
    if (!_isPlaying) return;
    // The loop will pick up the new progress value on its next iteration.
    // For instant feedback, we can cancel and restart the loop.
    _loopTimer?.cancel();
    _loop(progress);
  }

  /// Stops the haptic loop immediately.
  void stop() {
    if (!_isPlaying) return;
    _loopTimer?.cancel();
    _isPlaying = false;
    // On Android, explicitly stopping is important for waveform effects.
    AdvancedHaptics.stop();
  }

  /// The main loop that generates the haptic patterns.
  void _loop(double progress) {
    // Ensure progress is within a valid range [0, 1]
    final p = progress.clamp(0.0, 1.0);

    switch (type) {
      case HapticTaskType.download:
        _runDownloadLoop(p);
        break;
      case HapticTaskType.scan:
        _runScanLoop(p);
        break;
      case HapticTaskType.charge:
        _runChargeLoop(p);
        break;
    }
  }

  void _runDownloadLoop(double p) {
    // A continuous, low rumble that gets slightly more intense.
    // We achieve this with a short, repeating waveform.
    final intensity = (100 + (p * 80)).toInt(); // Intensity from 100 to 180
    final timings = [0, 50]; // A short, constant vibration
    final amplitudes = [0, intensity];
    AdvancedHaptics.playWaveform(timings, amplitudes);

    // Re-trigger the vibration every 55ms to feel continuous
    _loopTimer = Timer(const Duration(milliseconds: 55), () {
      if (_isPlaying) _loop(p);
    });
  }

  void _runScanLoop(double p) {
    // A rhythmic "tick" that gets faster.
    // We achieve this by shortening the delay in the timer.
    final duration = (400 - (p * 350)).toInt(); // Delay from 400ms down to 50ms
    const timings = [0, 20]; // A very short, sharp tick
    const amplitudes = [0, 255];
    AdvancedHaptics.playWaveform(timings, amplitudes);

    _loopTimer = Timer(Duration(milliseconds: duration), () {
      if (_isPlaying) _loop(p);
    });
  }
  
  void _runChargeLoop(double p) {
    // A swelling vibration that increases in intensity and sharpness.
    // On iOS, this will be emulated but the ramp-up will still be noticeable.
    final intensity = (50 + (p * 205)).toInt().clamp(0, 255); // Intensity from 50 to 255
    final timings = [0, 100]; // A steady vibration duration
    final amplitudes = [0, intensity];
    AdvancedHaptics.playWaveform(timings, amplitudes);

    // If we've reached 100%, play a final "thump" and stop.
    if (p >= 1.0) {
      _loopTimer = Timer(const Duration(milliseconds: 120), () {
        AdvancedHaptics.playWaveform([0, 150], [0, 255]); // The final thump
        stop();
      });
    } else {
      // Re-trigger the vibration every 110ms
      _loopTimer = Timer(const Duration(milliseconds: 110), () {
        if (_isPlaying) _loop(p);
      });
    }
  }
}


