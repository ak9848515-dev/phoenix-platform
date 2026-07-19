// File: firebase_options.dart
//
// IMPORTANT: This file contains PLACEHOLDER values. To use Firebase
// in production, run the following command to generate real keys:
//
//   flutterfire configure --project=phoenix-growth-os-86302
//
// This will:
//   1. Generate firebase_options.dart with real API keys
//   2. Download google-services.json for Android
//   3. Download GoogleService-Info.plist for iOS
//   4. Update the project to use the generated config
//
// Until then, Firebase will gracefully initialize with fallback values
// and all optional services will report as "Unavailable" in diagnostics.
// The app continues to work fully offline using local storage.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

/// Default [FirebaseOptions] for the current platform.
///
/// [currentPlatform] returns platform-specific options using the
/// Firebase project `phoenix-growth-os-86302` defined in [.firebaserc].
///
/// NOTE: API keys below are placeholders. Run:
///   flutterfire configure --project=phoenix-growth-os-86302
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDEFAULT_ANDROID_API_KEY',
    appId: '1:863020000000:android:default',
    messagingSenderId: '863020000000',
    projectId: 'phoenix-growth-os-86302',
    storageBucket: 'phoenix-growth-os-86302.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDEFAULT_IOS_API_KEY',
    appId: '1:863020000000:ios:default',
    messagingSenderId: '863020000000',
    projectId: 'phoenix-growth-os-86302',
    storageBucket: 'phoenix-growth-os-86302.firebasestorage.app',
    iosBundleId: 'com.phoenix.platform',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDEFAULT_IOS_API_KEY',
    appId: '1:863020000000:ios:default',
    messagingSenderId: '863020000000',
    projectId: 'phoenix-growth-os-86302',
    storageBucket: 'phoenix-growth-os-86302.firebasestorage.app',
    iosBundleId: 'com.phoenix.platform',
  );
}
