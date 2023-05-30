import 'keystore_strongbox_platform_interface.dart';

class KeystoreStrongbox {
  /// Retrieves the platform version from the underlying platform-specific implementation.
  Future<String?> getPlatformVersion() {
    return KeystoreStrongboxPlatform.instance.getPlatformVersion();
  }

  /// Encrypts the provided message using the specified tag and sharedPreferences.
  Future<String?> encrypt({
    required String tag,
    required String message,
    String sharedPreferences = 'iv_flutter_keystore_strongbox',
  }) {
    return KeystoreStrongboxPlatform.instance.encrypt(
      tag: tag,
      message: message,
      sharedPreferences: sharedPreferences,
    );
  }

  /// Decrypts the provided message using the specified tag and sharedPreferences.
  Future<String?> decrypt({
    required String tag,
    required String message,
    String sharedPreferences = 'iv_flutter_keystore_strongbox',
  }) {
    return KeystoreStrongboxPlatform.instance.decrypt(
      tag: tag,
      message: message,
      sharedPreferences: sharedPreferences,
    );
  }

  /// Sets the initialization vector (IV) value for the specified key in the sharedPreferences.
  Future<bool?> setIV({
    required String key,
    required String value,
    String sharedPreferences = 'iv_flutter_keystore_strongbox',
  }) {
    return KeystoreStrongboxPlatform.instance.setIV(
      key: key,
      value: value,
      sharedPreferences: sharedPreferences,
    );
  }

  /// Retrieves the initialization vector (IV) value for the specified key from the sharedPreferences.
  Future<String?> getIV({
    required String key,
    String sharedPreferences = 'iv_flutter_keystore_strongbox',
  }) {
    return KeystoreStrongboxPlatform.instance.getIV(
      key: key,
      sharedPreferences: sharedPreferences,
    );
  }
}
