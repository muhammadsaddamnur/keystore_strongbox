import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keystore_strongbox/keystore_strongbox_method_channel.dart';

void main() {
  MethodChannelKeystoreStrongbox platform = MethodChannelKeystoreStrongbox();
  const MethodChannel channel = MethodChannel('keystore_strongbox');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
