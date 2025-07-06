import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'advanced_haptics_method_channel.dart';

abstract class AdvancedHapticsPlatform extends PlatformInterface {
  /// Constructs a AdvancedHapticsPlatform.
  AdvancedHapticsPlatform() : super(token: _token);

  static final Object _token = Object();

  static AdvancedHapticsPlatform _instance = MethodChannelAdvancedHaptics();

  /// The default instance of [AdvancedHapticsPlatform] to use.
  ///
  /// Defaults to [MethodChannelAdvancedHaptics].
  static AdvancedHapticsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AdvancedHapticsPlatform] when
  /// they register themselves.
  static set instance(AdvancedHapticsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
