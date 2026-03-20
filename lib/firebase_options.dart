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
          'run FlutterFire CLI or configure manually.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static FirebaseOptions get web => FirebaseOptions(
    apiKey: const String.fromEnvironment(
      'FIREBASE_WEB_API_KEY',
      defaultValue: 'AIzaSyD5u2UTRr7ObBrlO_mUTDUpx_RvY2qMVE4',
    ),
    appId: const String.fromEnvironment(
      'FIREBASE_WEB_APP_ID',
      defaultValue: '1:737646867874:web:36faefa1d193c009f0eefb',
    ),
    messagingSenderId: const String.fromEnvironment(
      'FIREBASE_WEB_MESSAGING_SENDER_ID',
      defaultValue: '737646867874',
    ),
    projectId: const String.fromEnvironment(
      'FIREBASE_WEB_PROJECT_ID',
      defaultValue: 'studymedical',
    ),
    authDomain: const String.fromEnvironment(
      'FIREBASE_WEB_AUTH_DOMAIN',
      defaultValue: 'studymedical.firebaseapp.com',
    ),
    storageBucket: const String.fromEnvironment(
      'FIREBASE_WEB_STORAGE_BUCKET',
      defaultValue: 'studymedical.firebasestorage.app',
    ),
    measurementId: const String.fromEnvironment(
      'FIREBASE_WEB_MEASUREMENT_ID',
      defaultValue: 'G-7NCDPS9595',
    ),
  );

  static FirebaseOptions get android => FirebaseOptions(
    apiKey: const String.fromEnvironment(
      'FIREBASE_ANDROID_API_KEY',
      defaultValue: 'AIzaSyBSRJBBbqfrhjF8vLWhrokCqrkeniDgvnM',
    ),
    appId: const String.fromEnvironment(
      'FIREBASE_ANDROID_APP_ID',
      defaultValue: '1:737646867874:android:b3dd1c0cf39cf78ff0eefb',
    ),
    messagingSenderId: const String.fromEnvironment(
      'FIREBASE_ANDROID_MESSAGING_SENDER_ID',
      defaultValue: '737646867874',
    ),
    projectId: const String.fromEnvironment(
      'FIREBASE_ANDROID_PROJECT_ID',
      defaultValue: 'studymedical',
    ),
    storageBucket: const String.fromEnvironment(
      'FIREBASE_ANDROID_STORAGE_BUCKET',
      defaultValue: 'studymedical.firebasestorage.app',
    ),
    databaseURL: const String.fromEnvironment(
      'FIREBASE_ANDROID_DATABASE_URL',
      defaultValue: 'https://studymedical-default-rtdb.firebaseio.com',
    ),
  );

  static FirebaseOptions get ios => FirebaseOptions(
    apiKey: const String.fromEnvironment(
      'FIREBASE_IOS_API_KEY',
      defaultValue: 'AIzaSyDZTDIegLoxrj25l5DP_qMWjt2YLAb6sRc',
    ),
    appId: const String.fromEnvironment(
      'FIREBASE_IOS_APP_ID',
      defaultValue: '1:737646867874:ios:85cac7e17e9da332f0eefb',
    ),
    messagingSenderId: const String.fromEnvironment(
      'FIREBASE_IOS_MESSAGING_SENDER_ID',
      defaultValue: '737646867874',
    ),
    projectId: const String.fromEnvironment(
      'FIREBASE_IOS_PROJECT_ID',
      defaultValue: 'studymedical',
    ),
    storageBucket: const String.fromEnvironment(
      'FIREBASE_IOS_STORAGE_BUCKET',
      defaultValue: 'studymedical.firebasestorage.app',
    ),
    iosBundleId: const String.fromEnvironment(
      'FIREBASE_IOS_BUNDLE_ID',
      defaultValue: 'com.example.studyMedical',
    ),
  );

  static FirebaseOptions get macos => FirebaseOptions(
    apiKey: const String.fromEnvironment(
      'FIREBASE_MACOS_API_KEY',
      defaultValue: 'AIzaSyDZTDIegLoxrj25l5DP_qMWjt2YLAb6sRc',
    ),
    appId: const String.fromEnvironment(
      'FIREBASE_MACOS_APP_ID',
      defaultValue: '1:737646867874:ios:85cac7e17e9da332f0eefb',
    ),
    messagingSenderId: const String.fromEnvironment(
      'FIREBASE_MACOS_MESSAGING_SENDER_ID',
      defaultValue: '737646867874',
    ),
    projectId: const String.fromEnvironment(
      'FIREBASE_MACOS_PROJECT_ID',
      defaultValue: 'studymedical',
    ),
    storageBucket: const String.fromEnvironment(
      'FIREBASE_MACOS_STORAGE_BUCKET',
      defaultValue: 'studymedical.firebasestorage.app',
    ),
    iosBundleId: const String.fromEnvironment(
      'FIREBASE_MACOS_BUNDLE_ID',
      defaultValue: 'com.example.studyMedical',
    ),
  );

  static FirebaseOptions get windows => FirebaseOptions(
    apiKey: const String.fromEnvironment(
      'FIREBASE_WINDOWS_API_KEY',
      defaultValue: 'AIzaSyD5u2UTRr7ObBrlO_mUTDUpx_RvY2qMVE4',
    ),
    appId: const String.fromEnvironment(
      'FIREBASE_WINDOWS_APP_ID',
      defaultValue: '1:737646867874:web:1349dbab406c8434f0eefb',
    ),
    messagingSenderId: const String.fromEnvironment(
      'FIREBASE_WINDOWS_MESSAGING_SENDER_ID',
      defaultValue: '737646867874',
    ),
    projectId: const String.fromEnvironment(
      'FIREBASE_WINDOWS_PROJECT_ID',
      defaultValue: 'studymedical',
    ),
    authDomain: const String.fromEnvironment(
      'FIREBASE_WINDOWS_AUTH_DOMAIN',
      defaultValue: 'studymedical.firebaseapp.com',
    ),
    storageBucket: const String.fromEnvironment(
      'FIREBASE_WINDOWS_STORAGE_BUCKET',
      defaultValue: 'studymedical.firebasestorage.app',
    ),
    measurementId: const String.fromEnvironment(
      'FIREBASE_WINDOWS_MEASUREMENT_ID',
      defaultValue: 'G-Y0KJ3H02JM',
    ),
  );
}
