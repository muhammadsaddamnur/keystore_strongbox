import 'dart:developer';

import 'package:biometricx/biometricx.dart';
import 'package:flutter/material.dart';
import 'package:keystore_strongbox/keystore_strongbox.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _keystoreStrongboxPlugin = KeystoreStrongbox();

  @override
  void initState() {
    super.initState();
  }

  /// Migrates the initialization vector (IV) from the old keystore to the new keystore.
  void migrate() async {
    /// Try to find the IV with the current user in the new keystore
    /// If it's null, retrieve the IV from the old keystore and migrate it to the new keystore
    var newIV = await _keystoreStrongboxPlugin.getIV(
      key: "indonesia",
    );
    log(newIV.toString());
    if (newIV != null) return;

    var oldIV = await _keystoreStrongboxPlugin.getIV(
      key: "indonesia",
      sharedPreferences: 'com.salkuadrat.biometricx',
    );
    if (oldIV == null) return;

    await _keystoreStrongboxPlugin.setIV(
      key: 'indonesia',
      value: oldIV,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              ElevatedButton(
                onPressed: () async {
                  var res = await BiometricX.encrypt(
                    userAuthenticationRequired: false,
                    storeSharedPreferences: false,
                    tag: 'indonesia',
                    returnCipher: true,
                    messageKey: 'bali',
                    message: 'bali',
                  );
                  log('x ${res.data}');
                },
                child: const Text('Encrypt OLD'),
              ),
              ElevatedButton(
                onPressed: () async {
                  var s = await _keystoreStrongboxPlugin.encrypt(
                    tag: 'indonesia',
                    message: 'bali',
                  );

                  log('s $s');
                },
                child: const Text('Encrypt NEW'),
              ),
              ElevatedButton(
                onPressed: () async {
                  var s = await _keystoreStrongboxPlugin.decrypt(
                    tag: 'indonesia',
                    message: '/u6YB5EOyrwsYmAqLBh/AcHzNd4=',
                  );
                  log('s $s');
                },
                child: const Text('Decrypt'),
              ),
              ElevatedButton(
                onPressed: () async {
                  migrate();
                },
                child: const Text('Migrate'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
