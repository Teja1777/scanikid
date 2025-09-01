import 'package:firebase_core/firebase_core.dart';
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

  static final FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBqs5WxN_YLl2hPQnX9b6XPlOL9_u-AJOU',
    appId: '1:248733071874:web:0dc6410c8431da1de6851b',
    messagingSenderId: '248733071874',
    projectId: 'scanikid',
    authDomain: 'scanikid.firebaseapp.com',
    storageBucket: 'scanikid.firebasestorage.app',
    measurementId: 'G-77JSSKPLC0',
  );

  static final FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBqrU0Ru8ewAcX9TJYdPx-AfZS5olehMBI',
    appId: '1:248733071874:android:249054b4d70eb797e6851b',
    messagingSenderId: '248733071874',
    projectId: 'scanikid',
    storageBucket: 'scanikid.firebasestorage.app',
  );

  static final FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDKFJM9fKCKv_61YWTxZskOWurrdobH_zs',
    appId: '1:248733071874:ios:41ccff975a9a6181e6851b',
    messagingSenderId: '248733071874',
    projectId: 'scanikid',
    storageBucket: 'scanikid.firebasestorage.app',
    iosClientId: '248733071874-o735n099ce9ldnvm80u077717n8uvs4k.apps.googleusercontent.com',
    iosBundleId: 'com.example.scanikid12',
  );
  static final FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDKFJM9fKCKv_61YWTxZskOWurrdobH_zs',
    appId: '1:248733071874:ios:41ccff975a9a6181e6851b',
    messagingSenderId: '248733071874',
    projectId: 'scanikid',
    storageBucket: 'scanikid.firebasestorage.app',
    iosClientId: '248733071874-o735n099ce9ldnvm80u077717n8uvs4k.apps.googleusercontent.com',
    iosBundleId: 'com.example.scanikid12',
  );

  static final FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBqs5WxN_YLl2hPQnX9b6XPlOL9_u-AJOU',
    appId: '1:248733071874:web:2378d87479de3411e6851b',
    messagingSenderId: '248733071874',
    projectId: 'scanikid',
    authDomain: 'scanikid.firebaseapp.com',
    storageBucket: 'scanikid.firebasestorage.app',
    measurementId: 'G-KF8ETXPTHD',
  );
}