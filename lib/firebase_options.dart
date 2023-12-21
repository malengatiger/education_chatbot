// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyB_DF0tAfvuTmzJB-dKSMVO4yQIeFCNDls',
    appId: '1:458451555038:web:06bfd7e3ba6403ee76a84f',
    messagingSenderId: '458451555038',
    projectId: 'stealthcannabis',
    authDomain: 'stealthcannabis.firebaseapp.com',
    storageBucket: 'stealthcannabis.appspot.com',
    measurementId: 'G-1N2X2RT4D5',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAnClIgwtPS-9h_zxvAFU8AL3vym4FY8Es',
    appId: '1:458451555038:android:57ac1b248e133eae76a84f',
    messagingSenderId: '458451555038',
    projectId: 'stealthcannabis',
    storageBucket: 'stealthcannabis.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDajSyhEBj03pGGcfG5p9GUYWiwsCv6y4Y',
    appId: '1:458451555038:ios:00287700509ce66c76a84f',
    messagingSenderId: '458451555038',
    projectId: 'stealthcannabis',
    storageBucket: 'stealthcannabis.appspot.com',
    iosBundleId: 'com.boha.eduChatbot',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDajSyhEBj03pGGcfG5p9GUYWiwsCv6y4Y',
    appId: '1:458451555038:ios:52fefbc5579ea71c76a84f',
    messagingSenderId: '458451555038',
    projectId: 'stealthcannabis',
    storageBucket: 'stealthcannabis.appspot.com',
    iosBundleId: 'com.boha.eduChatbot.RunnerTests',
  );
}
