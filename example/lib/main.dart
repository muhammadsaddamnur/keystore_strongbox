import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:keystore_strongbox/keystore_strongbox.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _keystoreStrongboxPlugin = KeystoreStrongbox();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await _keystoreStrongboxPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
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
              Center(
                child: Text('Running on: $_platformVersion\n'),
              ),
              ElevatedButton(
                onPressed: () async {
                  var s = await _keystoreStrongboxPlugin.encrypt(
                      tag: 'dam', message: 'saddam');
                  log(s.toString());
                },
                child: Text('Encrypt'),
              ),
              ElevatedButton(
                onPressed: () async {
                  var s = await _keystoreStrongboxPlugin.decrypt(
                    tag: 'dam',
                    message: 'M6D1KXYnO/eH+26BFM0WxX6b7dXwXw==',
                  );
                  log(s.toString());
                },
                child: Text('Decrypt'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
