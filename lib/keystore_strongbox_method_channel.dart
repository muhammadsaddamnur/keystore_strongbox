import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'keystore_strongbox_platform_interface.dart';

/// An implementation of [KeystoreStrongboxPlatform] that uses method channels.
class MethodChannelKeystoreStrongbox extends KeystoreStrongboxPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('keystore_strongbox');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<String?> encrypt({
    required String tag,
    required String message,
    required String sharedPreferences,
  }) async {
    var iv = await getIV(key: tag, sharedPreferences: sharedPreferences);
    log('iv sp : $iv');

    final res = await methodChannel.invokeMethod<String?>(
      'encrypt',
      {
        'tag': tag,
        'message': message,
        'iv': iv,
      },
    );

    if (res == null) return null;
    var jsonRes = json.decode(res);
    if (iv == null) {
      log('iv new : ${jsonRes['iv']}');

      await setIV(
        key: tag,
        value: jsonRes['iv'],
        sharedPreferences: sharedPreferences,
      );
    }

    return jsonRes['ciphertext'];
  }

  @override
  Future<String?> decrypt({
    required String tag,
    required String message,
    required String sharedPreferences,
  }) async {
    var iv = await getIV(key: tag, sharedPreferences: sharedPreferences);
    log('iv sp : $iv');

    final res = await methodChannel.invokeMethod<String?>(
      'decrypt',
      {'tag': tag, 'message': message, 'iv': iv},
    );

    if (res == null) return null;

    var jsonRes = json.decode(res);

    return jsonRes['plainText'];
  }

  Future<bool?> setIV({
    required String key,
    required String value,
    required String sharedPreferences,
  }) async {
    final res = await methodChannel.invokeMethod<bool?>(
      'storeSharedPreferences',
      {
        'sharedPreferenceName': sharedPreferences,
        'tag': key,
        'message': value,
      },
    );
    return res;
  }

  Future<String?> getIV({
    required String key,
    required String sharedPreferences,
  }) async {
    final res = await methodChannel.invokeMethod<String?>(
      'loadSharedPreferences',
      {
        'sharedPreferenceName': sharedPreferences,
        'tag': key,
      },
    );
    return res;
  }
}
