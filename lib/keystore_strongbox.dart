import 'keystore_strongbox_platform_interface.dart';

class KeystoreStrongbox {
  Future<String?> getPlatformVersion() {
    return KeystoreStrongboxPlatform.instance.getPlatformVersion();
  }

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
