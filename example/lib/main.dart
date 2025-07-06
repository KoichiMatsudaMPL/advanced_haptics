import 'package:flutter/material.dart';
import 'package:advanced_haptics/advanced_haptics.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _hasSupport = false;

  @override
  void initState() {
    super.initState();
    _checkSupport();
  }

  Future<void> _checkSupport() async {
    final hasSupport = await AdvancedHaptics.hasCustomHapticsSupport();
    if (mounted) {
      setState(() {
        _hasSupport = hasSupport;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Advanced Haptics Example'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                ListTile(
                  title: const Text('Device Support'),
                  trailing: Text(
                    _hasSupport ? '✅ Supported' : '❌ Not Supported',
                    style: TextStyle(
                      color: _hasSupport ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(),
                ElevatedButton(
                  onPressed: () => AdvancedHaptics.success(),
                  child: const Text('Play Success Haptic'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Pattern: wait 0ms, vibrate 100ms, wait 200ms, vibrate 300ms
                    final timings = [0, 100, 200, 300];
                    // Amplitudes: 0 for pauses, 1-255 for vibration intensity
                    final amplitudes = [0, 150, 0, 255];
                    AdvancedHaptics.playWaveform(timings, amplitudes);
                  },
                  child: const Text('Play Custom Waveform'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => AdvancedHaptics.playAhap('assets/haptics/rumble.ahap'),
                  child: const Text('Play .ahap file (iOS) / Fallback (Android)'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => AdvancedHaptics.stop(),
                  child: const Text('Stop Haptics'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}