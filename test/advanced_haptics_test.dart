import 'package:flutter_test/flutter_test.dart';
// import 'package:advanced_haptics/advanced_haptics.dart';
import 'package:advanced_haptics/advanced_haptics_platform_interface.dart';
import 'package:advanced_haptics/advanced_haptics_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAdvancedHapticsPlatform
    with MockPlatformInterfaceMixin
    implements AdvancedHapticsPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final AdvancedHapticsPlatform initialPlatform = AdvancedHapticsPlatform.instance;

  test('$MethodChannelAdvancedHaptics is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAdvancedHaptics>());
  });

  test('getPlatformVersion', () async {
    // AdvancedHaptics advancedHapticsPlugin = AdvancedHaptics();
    // MockAdvancedHapticsPlatform fakePlatform = MockAdvancedHapticsPlatform();
    // AdvancedHapticsPlatform.instance = fakePlatform;

    // expect(await advancedHapticsPlugin.getPlatformVersion(), '42');
  });
}
