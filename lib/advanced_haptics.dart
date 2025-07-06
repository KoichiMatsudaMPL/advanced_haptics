import 'package:flutter/services.dart';

class AdvancedHaptics {
  static const MethodChannel _channel = MethodChannel('com.example/advanced_haptics');

  /// Checks if the device supports custom haptics.
  /// On iOS, this checks for Core Haptics support (iPhone 8+).
  /// On Android, this checks if the vibrator can control amplitude.
  static Future<bool> hasCustomHapticsSupport() async {
    try {
      final bool hasSupport = await _channel.invokeMethod('hasCustomHapticsSupport');
      return hasSupport;
    } on PlatformException {
      return false;
    }
  }

  /// Plays a haptic pattern defined by timings and amplitudes.
  /// [timings] - A list of integers representing the duration of each vibration and pause in milliseconds.
  ///             e.g., [off, on, off, on, ...]. The first value is the initial delay.
  /// [amplitudes] - A list of integers (0-255) for the intensity of each vibration.
  ///                The length must be the same as [timings]. Use 0 for pauses.
  ///
  /// This maps directly to Android's `VibrationEffect.createWaveform`.
  /// On iOS, this is emulated with a series of transient haptics (less precise).
  static Future<void> playWaveform(List<int> timings, List<int> amplitudes) async {
    if (timings.length != amplitudes.length) {
      throw ArgumentError('Timings and amplitudes lists must have the same length.');
    }
    await _channel.invokeMethod('playWaveform', {
      'timings': timings,
      'amplitudes': amplitudes,
    });
  }

  /// Plays a custom haptic pattern from an .ahap file on iOS.
  /// [ahapPath] - The asset path to the .ahap file (e.g., 'assets/haptics/rumble.ahap').
  ///
  /// On Android, this falls back to a predefined, strong vibration pattern.
  static Future<void> playAhap(String ahapPath) async {
    await _channel.invokeMethod('playAhap', {'path': ahapPath});
  }

  /// A simple, predefined "success" haptic.
  static Future<void> success() async {
    // Android: A simple on-off-on pattern
    // iOS: A nice double-tap haptic
    await _channel.invokeMethod('success');
  }

  /// Stops any currently playing haptic pattern.
  static Future<void> stop() async {
    await _channel.invokeMethod('stop');
  }

// --------------------------------------------
// 🔽 Utility Presets (with parameter docs)
// --------------------------------------------

  /// Plays a quick, light tap haptic feedback.
  ///
  /// [timings] defines the duration (in ms) of each segment in the pattern.
  /// [amplitudes] defines the strength of vibration for each segment (0–255).
  /// Must be the same length as [timings].
  static Future<void> lightTap({
    List<int> timings = const [0, 30],
    List<int> amplitudes = const [180, 0],
  }) async {
    await playWaveform(timings, amplitudes);
  }

  /// Plays a medium-strength haptic tap.
  ///
  /// Stronger than [lightTap], but softer and shorter than [heavyRumble].
  ///
  /// [timings] - Duration of each vibration segment in ms.
  /// [amplitudes] - Intensity of each segment (0–255).
  static Future<void> mediumTap({
    List<int> timings = const [0, 50],
    List<int> amplitudes = const [200, 0],
  }) async {
    await playWaveform(timings, amplitudes);
  }

  /// Plays a strong, short "heavy rumble" haptic.
  ///
  /// [timings] - Duration of the vibration (e.g., 200ms).
  /// [amplitudes] - Vibration intensity (0–255).
  static Future<void> heavyRumble({
    List<int> timings = const [0, 200],
    List<int> amplitudes = const [255, 0],
  }) async {
    await playWaveform(timings, amplitudes);
  }

  /// Plays a double-tap success haptic pattern.
  ///
  /// This gives a quick buzz-buzz feedback, suitable for confirming success or completion.
  ///
  /// [timings] - Alternating pause/on durations.
  /// [amplitudes] - Vibration intensity of each step (0–255).
  static Future<void> successBuzz({
    List<int> timings = const [0, 50, 100, 50],
    List<int> amplitudes = const [255, 0, 255, 0],
  }) async {
    await playWaveform(timings, amplitudes);
  }

  /// Plays an error-like feedback with two longer buzzes.
  ///
  /// Good for denoting failure, blocking actions, or system alerts.
  ///
  /// [timings] - Durations of pause/on segments.
  /// [amplitudes] - Vibration intensity levels (0–255).
  static Future<void> error({
    List<int> timings = const [0, 100, 50, 100],
    List<int> amplitudes = const [255, 0, 200, 0],
  }) async {
    await playWaveform(timings, amplitudes);
  }

  /// Plays a short, crisp selection click haptic.
  ///
  /// Best used for subtle UI events like item selection or toggles.
  ///
  /// [timings] - Duration of the click (typically <30ms).
  /// [amplitudes] - Vibration strength (0–255).
  static Future<void> selectionClick({
    List<int> timings = const [0, 20],
    List<int> amplitudes = const [120, 0],
  }) async {
    await playWaveform(timings, amplitudes);
  }

}