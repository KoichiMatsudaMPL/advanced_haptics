
---

# Advanced Haptics

A Flutter plugin for playing powerful, custom haptic feedback patterns. This package provides a unified API to access Android's `VibrationEffect.createWaveform` and iOS's Core Haptics with `.ahap` files, enabling developers to create rich, game-style tactile feedback.

[![pub version](https://img.shields.io/pub/v/advanced_haptics.svg)](https://pub.dev/packages/advanced_haptics)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

*(A GIF demonstrating the example app would be perfect here!)*

## Features

-   **Unified API:** A single, easy-to-use Dart API for both platforms.
-   **Android Waveform Support:** Full control over vibration `timings` and `amplitudes` using Android's native `VibrationEffect`.
-   **iOS Core Haptics:** Play complex, custom patterns on iOS using `.ahap` (Apple Haptic and Audio Pattern) files.
-   **Device Capability Check:** Check if a device supports advanced, amplitude-controlled haptics.
-   **Pre-defined Patterns:** Simple, ready-to-use patterns like `success`.
-   **Fallback Support:** Provides sensible fallback behavior on older devices or platforms without full support.

## Platform Support

| Feature               | Android (8.0+, API 26+) | iOS (13.0+)             | Notes                                                         |
| --------------------- | ----------------------- | ----------------------- | ------------------------------------------------------------- |
| **Waveform**          | ✅ Native               | ✅ Emulated             | iOS emulation is a best-effort and less precise than native.  |
| **.ahap Patterns**    | 🟡 Fallback             | ✅ Native               | Requires **iPhone 8 or newer**. Not supported on iPad.         |
| **Amplitude Control** | ✅ Native               | ✅ Native               | Requires **iPhone 8 or newer**.                               |
| **Pre-defined**       | ✅ Supported            | ✅ Supported            | Requires **iPhone 8 or newer** for custom feel.                 |

## Key Limitations & Considerations

Please read these limitations carefully to understand what to expect on each platform.

#### Android
-   **API Level Requirement:** Advanced waveform control with amplitude (`playWaveform`) requires **Android 8.0 (API level 26)** or higher. On older versions, calls will fail.
-   **Hardware Variance:** The quality and intensity of haptic feedback can vary significantly between Android device manufacturers (e.g., Samsung vs. Google Pixel vs. OnePlus). Always test on a range of target devices.

#### iOS
-   **Hardware Requirement:** Core Haptics is only supported on **iPhone 8 and newer models**. The plugin will not produce custom feedback on older iPhones (e.g., iPhone 7) or any iPad models. The `hasCustomHapticsSupport()` method will correctly return `false` on these devices.
-   **OS Requirement:** The plugin requires **iOS 13.0** or higher.
-   **Waveform Emulation:** The `playWaveform` method on iOS is a **best-effort emulation** of Android's native feature. It is created by sequencing a series of transient haptic taps. It will not be as precise or feel the same as on Android. For the best experience on iOS, always prefer using `.ahap` files.

## Getting Started

### 1. Installation

Add `advanced_haptics` to your project's `pubspec.yaml` file:

```yaml
dependencies:
  advanced_haptics: ^0.0.1 # Replace with the latest version
```

Then, run `flutter pub get` in your terminal.

### 2. Android Setup (API 26+)

Add the `VIBRATE` permission to your `AndroidManifest.xml` file, located at `android/app/src/main/AndroidManifest.xml`.

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.your_app">

    <!-- Add this line -->
    <uses-permission android:name="android.permission.VIBRATE"/>

   <application ...>
       ...
   </application>
</manifest>
```

### 3. iOS Setup (iOS 13+, iPhone 8+)

For iOS, you need to include any `.ahap` files you wish to play in your project assets. See the section below on how to create these files. Once created, add them to your `pubspec.yaml`:

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/haptics/ # Add the folder containing your .ahap files
```

Make sure the files are placed in the corresponding folder in your project (e.g., `assets/haptics/my_pattern.ahap`).

---

## Creating `.ahap` Files for iOS

An `.ahap` (Apple Haptic and Audio Pattern) file is a JSON file with a specific structure that describes a sequence of haptic events. You cannot generate these from a simple command-line tool; they must be authored.

### 1. Using a GUI Tool (Recommended)

For most users, a visual tool is the easiest and most intuitive method.

**[Captain AHAP](https://apps.apple.com/us/app/captain-ahap/id1502445293)** is a third-party app for macOS that provides a timeline-based editor. It allows for live previewing of haptics on a connected iPhone, which is invaluable for iterating on your patterns.

### 2. Manually Writing the JSON (Advanced)

You can also create `.ahap` files by hand in any text editor.

#### Key Concepts:

-   **`HapticIntensity`**: How strong the vibration is (`0.0` to `1.0`).
-   **`HapticSharpness`**: How "sharp" or "dull" it feels. High values are crisp taps; low values are soft rumbles (`0.0` to `1.0`).
-   **`HapticTransient`**: An instantaneous "tap" event.
-   **`HapticContinuous`**: A vibration that lasts for a specified `EventDuration`.

#### Example: A Single, Sharp Tap (`sharp_tap.ahap`)

```json
{
    "Version": 1,
    "Pattern": [
        {
            "Event": {
                "Time": 0.0,
                "EventType": "HapticTransient",
                "EventParameters": [
                    { "ParameterID": "HapticIntensity", "ParameterValue": 1.0 },
                    { "ParameterID": "HapticSharpness", "ParameterValue": 1.0 }
                ]
            }
        }
    ]
}
```

For more details, refer to Apple's official documentation on [representing haptic patterns](https://developer.apple.com/documentation/corehaptics/chpattern/representing_haptic_patterns_in_dictionaries).

---

## Usage

Import the package in your Dart file:

```dart
import 'package:advanced_haptics/advanced_haptics.dart';
```

### Checking for Device Support

It's good practice to check if the device can play custom haptics before calling other methods.

```dart
final bool canVibrate = await AdvancedHaptics.hasCustomHapticsSupport();
if (canVibrate) {
  print("This device supports custom haptics!");
}
```

### Playing a Pre-defined Pattern

```dart
// Plays a quick double-tap success feedback
await AdvancedHaptics.success();
```

### Playing a Custom Waveform (Android-focused)

Create a custom vibration by defining a pattern of timings and amplitudes.

-   `timings`: A list of durations in milliseconds. The pattern is `[delay, vibrate, pause, vibrate, ...]`.
-   `amplitudes`: A list of intensities (0-255). **Must be the same length as `timings`**. Use `0` for pauses.

```dart
final timings = [0, 100, 200, 300];
final amplitudes = [0, 150, 0, 255];
await AdvancedHaptics.playWaveform(timings, amplitudes);
```

### Playing an `.ahap` File (iOS-focused)

For the richest experience on iOS, play a custom `.ahap` file.

```dart
// Make sure 'assets/haptics/rumble.ahap' is declared in your pubspec.yaml
await AdvancedHaptics.playAhap('assets/haptics/rumble.ahap');
```

### Stopping Vibrations

```dart
await AdvancedHaptics.stop();
```

## API Reference

| Method                                       | Description                                                                                             |
| -------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| `Future<bool> hasCustomHapticsSupport()`     | Checks if the device supports amplitude-controlled haptics.                                             |
| `Future<void> playWaveform(List<int> timings, List<int> amplitudes)` | Plays a custom waveform pattern.                                                                        |
| `Future<void> playAhap(String ahapPath)`     | Plays a `.ahap` file on iOS with a fallback on Android.                                                 |
| `Future<void> success()`                     | Plays a predefined "success" haptic.                                                                    |
| `Future<void> stop()`                        | Stops any currently playing haptic feedback.                                                            |

## Contributing

Contributions are welcome! If you find a bug or have a feature request, please open an issue. If you want to contribute code, please feel free to fork the repository and submit a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.