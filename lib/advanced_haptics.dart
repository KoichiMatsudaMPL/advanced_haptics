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
}