// File generated based on google-services.json
// This file is required for Firebase initialization

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBFXE0ZH_7lc0mlp9baZxsVPufa3ainOJk',
    appId: '1:1043044865580:android:528f8cd20f62dad304e389',
    messagingSenderId: '1043044865580',
    projectId: 'wign-realm',
    storageBucket: 'wign-realm.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD9sKpC1v8UP48D7gCKbcWl5SI4tDWrMR8',
    appId: '1:1043044865580:web:347724a6f3b6d46b04e389',
    messagingSenderId: '1043044865580',
    projectId: 'wign-realm',
    authDomain: 'wign-realm.firebaseapp.com',
    storageBucket: 'wign-realm.firebasestorage.app',
    measurementId: 'G-F543SD1VKY',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBf-n34OY9kz1ZRrAUOFy2dIVhFdfDl-6o',
    appId: '1:1043044865580:ios:370706b36d82445a04e389',
    messagingSenderId: '1043044865580',
    projectId: 'wign-realm',
    storageBucket: 'wign-realm.firebasestorage.app',
    iosBundleId: 'com.example.wignRealm',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBf-n34OY9kz1ZRrAUOFy2dIVhFdfDl-6o',
    appId: '1:1043044865580:ios:370706b36d82445a04e389',
    messagingSenderId: '1043044865580',
    projectId: 'wign-realm',
    storageBucket: 'wign-realm.firebasestorage.app',
    iosBundleId: 'com.example.wignRealm',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD9sKpC1v8UP48D7gCKbcWl5SI4tDWrMR8',
    appId: '1:1043044865580:web:8ffddacd302390ce04e389',
    messagingSenderId: '1043044865580',
    projectId: 'wign-realm',
    authDomain: 'wign-realm.firebaseapp.com',
    storageBucket: 'wign-realm.firebasestorage.app',
    measurementId: 'G-K39V4H2470',
  );

}