// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBNjXSwA67Fy7omBKYHSfPo5ExfQBUxT1E',
    appId: '1:821300283651:web:712a40a8b3eba96d428136',
    messagingSenderId: '821300283651',
    projectId: 'caregiver-dashboard',
    authDomain: 'caregiver-dashboard.firebaseapp.com',
    storageBucket: 'caregiver-dashboard.appspot.com',
    measurementId: 'G-PHC5M40WPC',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAtt8n2Xz8qObrjaSmJnlVnNJGH4EBaq7s',
    appId: '1:821300283651:android:d4adce7fe47a1288428136',
    messagingSenderId: '821300283651',
    projectId: 'caregiver-dashboard',
    storageBucket: 'caregiver-dashboard.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD3b4riQ7FLGZn4lWsAV3NdKPGLr7LO8cs',
    appId: '1:821300283651:ios:229fcb94e33962cc428136',
    messagingSenderId: '821300283651',
    projectId: 'caregiver-dashboard',
    storageBucket: 'caregiver-dashboard.appspot.com',
    iosBundleId: 'com.example.caregiverDashboard',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD3b4riQ7FLGZn4lWsAV3NdKPGLr7LO8cs',
    appId: '1:821300283651:ios:229fcb94e33962cc428136',
    messagingSenderId: '821300283651',
    projectId: 'caregiver-dashboard',
    storageBucket: 'caregiver-dashboard.appspot.com',
    iosBundleId: 'com.example.caregiverDashboard',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBNjXSwA67Fy7omBKYHSfPo5ExfQBUxT1E',
    appId: '1:821300283651:web:860397fa6c419d06428136',
    messagingSenderId: '821300283651',
    projectId: 'caregiver-dashboard',
    authDomain: 'caregiver-dashboard.firebaseapp.com',
    storageBucket: 'caregiver-dashboard.appspot.com',
    measurementId: 'G-2Y0BVH8RJM',
  );

}