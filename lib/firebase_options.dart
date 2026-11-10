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
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCcO5tmTnbp0x4FWCzt_jlnvgr5UVsQEYw',
    appId: '1:1019250167469:web:2af509bf6df72fe6538024',
    messagingSenderId: '1019250167469',
    projectId: 'midterm-44765',
    authDomain: 'midterm-44765.firebaseapp.com',
    storageBucket: 'midterm-44765.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCTWkqJBRogxw6Yrcq7LTkP-lcHzZOpaIw',
    appId: '1:1019250167469:android:f2435f0b565ad4e0538024',
    messagingSenderId: '1019250167469',
    projectId: 'midterm-44765',
    storageBucket: 'midterm-44765.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCcO5tmTnbp0x4FWCzt_jlnvgr5UVsQEYw',
    appId: '1:1019250167469:web:2af509bf6df72fe6538024',
    messagingSenderId: '1019250167469',
    projectId: 'midterm-44765',
    storageBucket: 'midterm-44765.firebasestorage.app',
    iosBundleId: 'com.example.midterm',
  );
}
