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
    apiKey: 'AIzaSyDummyKeyForLocalDevelopment',
    appId: '1:123456789:web:dummyAppIdForDev',
    messagingSenderId: '123456789',
    projectId: 'mealplanner-dev',
    authDomain: 'mealplanner-dev.firebaseapp.com',
    storageBucket: 'mealplanner-dev.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDummyKeyForLocalDevelopment',
    appId: '1:123456789:android:dummyAppIdForDev',
    messagingSenderId: '123456789',
    projectId: 'mealplanner-dev',
    storageBucket: 'mealplanner-dev.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDummyKeyForLocalDevelopment',
    appId: '1:123456789:ios:dummyAppIdForDev',
    messagingSenderId: '123456789',
    projectId: 'mealplanner-dev',
    storageBucket: 'mealplanner-dev.appspot.com',
    iosBundleId: 'com.example.mealPlanner',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDummyKeyForLocalDevelopment',
    appId: '1:123456789:macos:dummyAppIdForDev',
    messagingSenderId: '123456789',
    projectId: 'mealplanner-dev',
    storageBucket: 'mealplanner-dev.appspot.com',
    iosBundleId: 'com.example.mealPlanner',
  );
}
