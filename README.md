
---

# Advanced Haptics

A Flutter plugin for playing powerful, custom haptic feedback patterns. This package provides a unified API for Android and iOS, giving developers access to fine-grained vibration control and Apple Core Haptics `.ahap` files.

[![pub version](https://img.shields.io/pub/v/advanced_haptics.svg)](https://pub.dev/packages/advanced_haptics)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/miracle101000/advanced_haptics/blob/main/LICENSE)

---

## ✨ Features

-   ✅ **Unified API** for Android and iOS.
-   🎯 **Custom Waveforms**: Full control of vibration timing and intensity.
-   🍎 **Core Haptics on iOS**: Play custom `.ahap` files for rich, layered tactile feedback.
-   🧠 **Predefined Patterns**: A suite of built-in methods like `lightTap()`, `success()`, `error()`, and more for common use cases.
-   🛡️ **Capability Detection**: A simple method to check if a device supports advanced haptics.
-   🪶 **Graceful Fallback**: Sensible fallback behavior on unsupported devices.

---

## 🖥 Platform Support

| Feature             | Android (8.0+ / API 26+) | iOS (13.0+ / iPhone 8+) |
| ------------------- | ------------------------ | ----------------------- |
| Waveform            | ✅ Native                | ✅ Emulated             |
| `.ahap` Playback    | 🔁 Fallback              | ✅ Native               |
| Amplitude Control   | ✅ Native                | ✅ Native               |
| Predefined Patterns | ✅ Supported             | ✅ Supported            |

> ℹ️ **Note:** iPads do not support Core Haptics. Always use `hasCustomHapticsSupport()` to verify device capabilities before playing complex patterns.

---

## 🚀 Getting Started

### 1. Install

Add `advanced_haptics` to your `pubspec.yaml` dependencies.

```yaml
dependencies:
  advanced_haptics: ^0.0.6 # Use the latest version
```

Then, run `flutter pub get`.

### 2. Android Setup

Add the `VIBRATE` permission to your `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.your_app">

    <!-- Add this line -->
    <uses-permission android:name="android.permission.VIBRATE"/>

   <application ...>
   </application>
</manifest>
```

### 3. iOS Setup

To play custom patterns on iOS, add your `.ahap` files to your project assets (e.g., under an `assets/haptics/` folder) and declare them in your `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/haptics/
```

### Creating `.ahap` Files (for iOS)

An `.ahap` file is a JSON file that describes a haptic pattern. The best way to create them is with a visual tool.

-   **Recommended Tool:** Use [Captain AHAP](https://apps.apple.com/us/app/captain-ahap/id1502445293) on macOS to visually design patterns and preview them on a connected iPhone.
-   **Manual Creation:** You can also write the JSON by hand. Here is an example of a single, sharp tap:

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

---

## 📦 Usage

Import the package in your Dart file:

```dart
import 'package:advanced_haptics/advanced_haptics.dart';
```

### ✅ Check for Support

Before playing complex patterns, it's wise to check if the hardware supports them.

```dart
if (await AdvancedHaptics.hasCustomHapticsSupport()) {
  // Safe to use advanced feedback
}
```

### ⚡ Predefined Haptic Patterns

Use these for quick, consistent feedback across your app.

```dart
// Simple taps
await AdvancedHaptics.lightTap();
await AdvancedHaptics.mediumTap();
await AdvancedHaptics.selectionClick(); // A crisp, UI-element-like click

// Rumbles and Buzzes
await AdvancedHaptics.heavyRumble();
await AdvancedHaptics.successBuzz();

// Notifiers
await AdvancedHaptics.success(); // A distinct double-tap
await AdvancedHaptics.error();   // A clear failure/alert pattern
```

### 🎛️ Custom Waveform (Android Preferred)

Design unique patterns with precise control over timings (in milliseconds) and amplitudes (0-255).

```dart
await AdvancedHaptics.playWaveform(
  [0, 100, 150, 100],    // Timings: [delay, on, off, on]
  [0, 180, 0, 255],      // Amplitudes for each timing segment
);
```

### 🍏 Play `.ahap` File (iOS Only)

Trigger your custom-designed haptic experiences on supported iPhones.

```dart
await AdvancedHaptics.playAhap('assets/haptics/rumble.ahap');
```

### 🛑 Stop All Vibrations

Immediately cancel any ongoing haptic effect.

```dart
await AdvancedHaptics.stop();
```

---

## 🧠 API Reference

| Method                                       | Description                                                                    |
| -------------------------------------------- | ------------------------------------------------------------------------------ |
| `Future<bool> hasCustomHapticsSupport()`     | Checks if the device supports amplitude-controlled haptics.                    |
| `playWaveform(timings, amplitudes)`          | Plays a custom vibration pattern, best for Android.                            |
| `playAhap(path)`                             | Plays a custom `.ahap` haptic file on iOS (with a fallback on Android).        |
| `stop()`                                     | Stops any ongoing vibration immediately.                                       |
| `success()`                                  | Plays a predefined double-tap success pattern.                                 |
| `error()`                                    | Plays a predefined alert/failure pattern.                                      |
| `lightTap()`                                 | Plays quick, subtle feedback. Ideal for minor UI interactions.                 |
| `mediumTap()`                                | Plays mid-strength feedback.                                                   |
| `selectionClick()`                           | Plays a crisp, click-like haptic for selections (like a picker wheel).         |
| `heavyRumble()`                              | Plays strong, heavy feedback.                                                  |
| `successBuzz()`                              | Plays a buzz-buzz style success pattern.                                       |

---

## 🙌 Contributing

Pull requests and issues are welcome! If you encounter a bug, please provide logs, device information, and steps to reproduce. When contributing code, please ensure it's tested across a range of devices if possible.

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for full details.