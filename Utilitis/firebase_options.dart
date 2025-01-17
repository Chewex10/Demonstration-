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
    apiKey: 'AIzaSyDwfZ7Cg4bgdTK9b2NehAK5Y0b6VvhEFwg',
    appId: '1:570896606914:web:1d47e5b7dfdc30424e3d5b',
    messagingSenderId: '570896606914',
    projectId: 'fieldproject-5ca99',
    authDomain: 'fieldproject-5ca99.firebaseapp.com',
    storageBucket: 'fieldproject-5ca99.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCFfA6ve9SX_Jx3IRBEKChPUkpt3UPWTQs',
    appId: '1:570896606914:android:52e359bb612137ed4e3d5b',
    messagingSenderId: '570896606914',
    projectId: 'fieldproject-5ca99',
    storageBucket: 'fieldproject-5ca99.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAYTtTYRtNYikmgfT_Z_0qRxpcYS9g8VYQ',
    appId: '1:570896606914:ios:6c203c803c527f0f4e3d5b',
    messagingSenderId: '570896606914',
    projectId: 'fieldproject-5ca99',
    storageBucket: 'fieldproject-5ca99.appspot.com',
    iosBundleId: 'com.example.servicefield',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAYTtTYRtNYikmgfT_Z_0qRxpcYS9g8VYQ',
    appId: '1:570896606914:ios:6c203c803c527f0f4e3d5b',
    messagingSenderId: '570896606914',
    projectId: 'fieldproject-5ca99',
    storageBucket: 'fieldproject-5ca99.appspot.com',
    iosBundleId: 'com.example.servicefield',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDwfZ7Cg4bgdTK9b2NehAK5Y0b6VvhEFwg',
    appId: '1:570896606914:web:8d7b395707a4812b4e3d5b',
    messagingSenderId: '570896606914',
    projectId: 'fieldproject-5ca99',
    authDomain: 'fieldproject-5ca99.firebaseapp.com',
    storageBucket: 'fieldproject-5ca99.appspot.com',
  );

}
