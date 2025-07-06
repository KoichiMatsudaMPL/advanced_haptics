
---

````markdown
# Advanced Haptics

A Flutter plugin for playing powerful, custom haptic feedback patterns. This package provides a unified API for Android and iOS, giving developers access to fine-grained vibration control and Apple Core Haptics `.ahap` files.

[![pub version](https://img.shields.io/pub/v/advanced_haptics.svg)](https://pub.dev/packages/advanced_haptics)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

---

## ✨ Features

- ✅ **Unified API** for Android and iOS
- 🎯 **Custom Waveforms**: Full control of timing and intensity
- 🍎 **Core Haptics on iOS**: Play `.ahap` files for rich tactile feedback
- 🧠 **Predefined Patterns**: Built-in methods like `lightTap()`, `successBuzz()`, `error()`, and more
- 🛡️ **Capability Detection**: Automatically detects device haptics support
- 🪶 **Fallback Support**: Gracefully degrades on unsupported devices

---

## 🖥 Platform Support

| Feature               | Android 8.0+ | iOS 13.0+ (iPhone 8+) |
|-----------------------|--------------|------------------------|
| Waveform              | ✅ Native     | ✅ Emulated            |
| `.ahap` Playback      | 🔁 Fallback   | ✅ Native              |
| Amplitude Control     | ✅ Native     | ✅ Native              |
| Predefined Patterns   | ✅ Yes        | ✅ Yes                 |

> ℹ️ **Note:** iPads do not support Core Haptics. Use `hasCustomHapticsSupport()` to verify.

---

## 🚀 Getting Started

### 1. Install

```yaml
dependencies:
  advanced_haptics: ^0.0.1
````

```bash
flutter pub get
```

---

### 2. Android Setup

Add the following permission to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.VIBRATE"/>
```

---

### 3. iOS Setup

Add your `.ahap` files under `assets/haptics/`, and include them in your `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/haptics/
```

Ensure your target device is an iPhone 8+ running iOS 13+.

---

## 🎨 Example `.ahap` File (iOS only)

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

Design `.ahap` files using [Captain AHAP](https://apps.apple.com/us/app/captain-ahap/id1502445293) or manually.

---

## 📦 Usage

```dart
import 'package:advanced_haptics/advanced_haptics.dart';
```

### ✅ Check Support

```dart
if (await AdvancedHaptics.hasCustomHapticsSupport()) {
  // Safe to use advanced feedback
}
```

### ⚡ Predefined Haptic Patterns

```dart
await AdvancedHaptics.lightTap();
await AdvancedHaptics.mediumTap();
await AdvancedHaptics.heavyRumble();
await AdvancedHaptics.successBuzz();
await AdvancedHaptics.selectionClick();
await AdvancedHaptics.error();
await AdvancedHaptics.success();
```

### 🎛 Custom Waveform (Android preferred)

```dart
await AdvancedHaptics.playWaveform(
  [0, 100, 150, 100],    // timings in ms
  [0, 180, 0, 255],      // amplitudes 0–255
);
```

### 🍏 Play `.ahap` (iOS only)

```dart
await AdvancedHaptics.playAhap('assets/haptics/rumble.ahap');
```

### 🛑 Stop All Vibrations

```dart
await AdvancedHaptics.stop();
```

---

## 🧠 API Reference

| Method                                  | Description                         |
| --------------------------------------- | ----------------------------------- |
| `hasCustomHapticsSupport()`             | Check platform and hardware support |
| `playWaveform(timings, amplitudes)`     | Custom vibration pattern (Android)  |
| `playAhap(path)`                        | Play an iOS `.ahap` haptic file     |
| `stop()`                                | Stop any ongoing vibration          |
| `success()`                             | Predefined double-tap haptic        |
| `lightTap({timings, amplitudes})`       | Quick subtle feedback               |
| `mediumTap({timings, amplitudes})`      | Mid-strength feedback               |
| `heavyRumble({timings, amplitudes})`    | Strong feedback                     |
| `successBuzz({timings, amplitudes})`    | Buzz-buzz style success pattern     |
| `error({timings, amplitudes})`          | Alert/failure feedback              |
| `selectionClick({timings, amplitudes})` | Crisp, click-like haptic            |

---

## 🙌 Contributing

Pull requests and issues are welcome! Please test across devices and provide logs if possible.

---

## 📄 License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for full details.

