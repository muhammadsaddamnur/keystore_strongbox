import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'keystore_strongbox_method_channel.dart';

abstract class KeystoreStrongboxPlatform extends PlatformInterface {
  /// Constructs a KeystoreStrongboxPlatform.
  KeystoreStrongboxPlatform() : super(token: _token);

  static final Object _token = Object();

  static KeystoreStrongboxPlatform _instance = MethodChannelKeystoreStrongbox();

  /// The default instance of [KeystoreStrongboxPlatform] to use.
  ///
  /// Defaults to [MethodChannelKeystoreStrongbox].
  static KeystoreStrongboxPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [KeystoreStrongboxPlatform] when
  /// they register themselves.
  static set instance(KeystoreStrongboxPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> encrypt({
    required String tag,
    required String message,
    required String sharedPreferences,
  }) {
    throw UnimplementedError('encrypt() has not been implemented.');
  }

  Future<String?> decrypt({
    required String tag,
    required String message,
    required String sharedPreferences,
  }) {
    throw UnimplementedError('decrypt() has not been implemented.');
  }

  Future<bool?> setIV({
    required String key,
    required String value,
    required String sharedPreferences,
  });

  Future<String?> getIV({
    required String key,
    required String sharedPreferences,
  });
}
