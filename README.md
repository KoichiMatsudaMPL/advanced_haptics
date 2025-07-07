

# Advanced Haptics

A Flutter plugin for playing powerful, custom haptic feedback patterns. This package provides a unified API for Android and iOS, giving developers access to fine-grained vibration control and Apple Core Haptics `.ahap` files.

[![pub version](https://img.shields.io/pub/v/advanced_haptics.svg)](https://pub.dev/packages/advanced_haptics)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/miracle101000/advanced_haptics/blob/main/LICENSE)

---

## ✨ Features

-   ✅ **Unified API**: A single, easy-to-use Dart API for both platforms.
-   🎯 **Custom Waveforms**: Full control of vibration timing, intensity, and looping.
-   🍎 **Core Haptics on iOS**: Play custom `.ahap` files for rich, layered tactile feedback.
-   🧠 **Predefined Patterns**: A suite of built-in methods like `lightTap()`, `success()`, `error()` and more.
-   🧩 **Native Android Effects**: Access system-level vibration effects like `tick`, `heavyClick`, etc.
-   🛡️ **Capability Detection**: Easily check if a device supports advanced haptics.
-   🪶 **Graceful Fallbacks**: Sensible defaults for unsupported hardware or platforms.

---

## 🖥 Platform Support

| Feature             | Android (8.0+ / API 26+) | iOS (13.0+ / iPhone 8+) |
| ------------------- | ------------------------ | ----------------------- |
| Waveform            | ✅ Native                | ✅ Emulated             |
| `.ahap` Playback    | 🔁 Fallback              | ✅ Native               |
| Amplitude Control   | ✅ Native                | ✅ Native               |
| Predefined Patterns | ✅ Native + Custom       | ✅ Native               |

> ℹ️ **Note:** iPads do not support Core Haptics. Always use `hasCustomHapticsSupport()` before playing advanced patterns to ensure a good user experience.

---

## 🚀 Getting Started

### 1. Install

Add `advanced_haptics` to your `pubspec.yaml` dependencies:

```yaml
dependencies:
  advanced_haptics: ^0.0.6 # Use the latest version
```

Then, run `flutter pub get` in your terminal.

### 2. Android Setup

Add the `VIBRATE` permission to your `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest ...>
    <!-- Add this line -->
    <uses-permission android:name="android.permission.VIBRATE"/>
    <application ...>
    </application>
</manifest>
```

### 3. iOS Setup

To play custom patterns on iOS, add your `.ahap` files to your project assets (e.g., under an `assets/haptics/` folder) and declare the folder in your `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/haptics/
```

#### Creating `.ahap` Files (for iOS)
An `.ahap` file is a JSON file that describes a haptic pattern. The best way to create them is with a visual tool.

-   **Recommended Tool:** Use **[Captain AHAP](https://apps.apple.com/us/app/captain-ahap/id1502445293)** on macOS to visually design patterns and preview them on a connected iPhone.
-   **Manual Creation:** You can also write the JSON by hand. Here is an example of a single, sharp tap:
    ```json
    {
      "Version": 1,
      "Pattern": [
        {
          "Event": { "Time": 0.0, "EventType": "HapticTransient",
            "EventParameters": [
              { "ParameterID": "HapticIntensity", "ParameterValue": 1.0 },
              { "ParameterID": "HapticSharpness", "ParameterValue": 1.0 }
            ]
          }
        }
      ]
    }
    ```

---

## 📦 Usage

Import the package in your Dart file:

```dart
import 'package:advanced_haptics/advanced_haptics.dart';
```

### ✅ Capability Check

```dart
final bool hasSupport = await AdvancedHaptics.hasCustomHapticsSupport();
if (hasSupport) {
  // Safe to use advanced haptics
}
```

### ⚡ Predefined Taps & Buzzes

Use these for quick, consistent feedback across your app.

```dart
await AdvancedHaptics.lightTap();
await AdvancedHaptics.mediumTap();
await AdvancedHaptics.heavyRumble();
await AdvancedHaptics.selectionClick();
await AdvancedHaptics.successBuzz();
await AdvancedHaptics.success();
await AdvancedHaptics.error();
```

### 🎛️ Custom Waveform

Design unique patterns with precise control over timings (in milliseconds), amplitudes (0-255), and an optional repeat index.

```dart
// Plays a pattern, with no repeat
await AdvancedHaptics.playWaveform(
  [0, 100, 100, 200],     // Timings: [delay, on, off, on]
  [0, 180, 0, 255],       // Amplitudes for each segment
  repeat: -1              // -1 means no repeat
);
```

### 🍏 Play `.ahap` File on iOS

Trigger your custom-designed haptic experiences on supported iPhones.

```dart
await AdvancedHaptics.playAhap('assets/haptics/success.ahap');
```

### 📲 Android Native Effects (API 29+)

Play Android's built-in system haptic effects using an enum.

```dart
await AdvancedHaptics.playPredefined(AndroidPredefinedHaptic.heavyClick);
```
Available enums: `click`, `doubleClick`, `tick`, `heavyClick`, `pop`, `thud`, `ringtone1`.

### 🛑 Stop All Vibrations

Immediately cancel any ongoing haptic effect.

```dart
await AdvancedHaptics.stop();
```

---

## 🧠 API Reference

| Method                                      | Description                                                                    |
| ------------------------------------------- | ------------------------------------------------------------------------------ |
| `Future<bool> hasCustomHapticsSupport()`    | Checks if the device supports amplitude control.                               |
| `playWaveform(timings, amplitudes, repeat)` | Plays a precise custom vibration pattern. Best for Android.                    |
| `playAhap(path)`                            | Plays a `.ahap` Core Haptics file on iOS (with a fallback on Android).         |
| `playPredefined(effect)`                    | Plays Android's native haptic effect (requires API 29+).                       |
| `stop()`                                    | Cancels any active haptic feedback.                                            |
| `lightTap()` / `mediumTap()` etc.           | A suite of standard UI feedback presets for common interactions.               |

---

## 🙌 Contributing

We welcome issues, feature requests, and pull requests! If submitting code, please test on both Android and iOS where applicable and provide details on the devices used.

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for full details.