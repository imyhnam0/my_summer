// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBfJbLDJTCzbP155rUcHu5WCVzP27sZaiY',
    appId: '1:697245684494:web:92ea4bd106aadbd98bbd5f',
    messagingSenderId: '697245684494',
    projectId: 'summer-eebb6',
    authDomain: 'summer-eebb6.firebaseapp.com',
    storageBucket: 'summer-eebb6.appspot.com',
    measurementId: 'G-50RWGH3FCE',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDFLdeWusrzIMA_htTEjGdGFtKsLVJqhC0',
    appId: '1:697245684494:android:ab5aaf707950fdc08bbd5f',
    messagingSenderId: '697245684494',
    projectId: 'summer-eebb6',
    storageBucket: 'summer-eebb6.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDSboFRza1T7wiSDo0wf7qEMINJL72YbOk',
    appId: '1:697245684494:ios:f25f63438a7b91168bbd5f',
    messagingSenderId: '697245684494',
    projectId: 'summer-eebb6',
    storageBucket: 'summer-eebb6.appspot.com',
    iosBundleId: 'com.example.health',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDSboFRza1T7wiSDo0wf7qEMINJL72YbOk',
    appId: '1:697245684494:ios:f25f63438a7b91168bbd5f',
    messagingSenderId: '697245684494',
    projectId: 'summer-eebb6',
    storageBucket: 'summer-eebb6.appspot.com',
    iosBundleId: 'com.example.health',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBfJbLDJTCzbP155rUcHu5WCVzP27sZaiY',
    appId: '1:697245684494:web:a5624b2217f509958bbd5f',
    messagingSenderId: '697245684494',
    projectId: 'summer-eebb6',
    authDomain: 'summer-eebb6.firebaseapp.com',
    storageBucket: 'summer-eebb6.appspot.com',
    measurementId: 'G-276N12RDDC',
  );
}
