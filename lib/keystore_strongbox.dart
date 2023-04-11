import 'keystore_strongbox_platform_interface.dart';

class KeystoreStrongbox {
  Future<String?> getPlatformVersion() {
    return KeystoreStrongboxPlatform.instance.getPlatformVersion();
  }

  Future<String?> encrypt({required String tag, required String message}) {
    return KeystoreStrongboxPlatform.instance.encrypt(
      tag: tag,
      message: message,
    );
  }

  Future<String?> decrypt({
    required String tag,
    required String message,
  }) {
    return KeystoreStrongboxPlatform.instance.decrypt(
      tag: tag,
      message: message,
    );
  }
}
