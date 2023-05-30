import 'package:flutter_test/flutter_test.dart';
import 'package:keystore_strongbox/keystore_strongbox.dart';
import 'package:keystore_strongbox/keystore_strongbox_platform_interface.dart';
import 'package:keystore_strongbox/keystore_strongbox_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockKeystoreStrongboxPlatform
    with MockPlatformInterfaceMixin
    implements KeystoreStrongboxPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<String?> encrypt({
    required String tag,
    required String message,
    required String sharedPreferences,
  }) {
    // TODO: implement encrypt
    throw UnimplementedError();
  }

  @override
  Future<String?> decrypt({
    required String tag,
    required String message,
    required String sharedPreferences,
  }) {
    // TODO: implement decrypt
    throw UnimplementedError();
  }

  @override
  Future<String?> getIV(
      {required String key, required String sharedPreferences}) {
    // TODO: implement getIV
    throw UnimplementedError();
  }

  @override
  Future<bool?> setIV(
      {required String key,
      required String value,
      required String sharedPreferences}) {
    // TODO: implement setIV
    throw UnimplementedError();
  }
}

void main() {
  final KeystoreStrongboxPlatform initialPlatform =
      KeystoreStrongboxPlatform.instance;

  test('$MethodChannelKeystoreStrongbox is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelKeystoreStrongbox>());
  });

  test('getPlatformVersion', () async {
    KeystoreStrongbox keystoreStrongboxPlugin = KeystoreStrongbox();
    MockKeystoreStrongboxPlatform fakePlatform =
        MockKeystoreStrongboxPlatform();
    KeystoreStrongboxPlatform.instance = fakePlatform;

    expect(await keystoreStrongboxPlugin.getPlatformVersion(), '42');
  });
}
