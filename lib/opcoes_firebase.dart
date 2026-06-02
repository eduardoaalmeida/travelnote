import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class OpcoesPadraoFirebase {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError('FirebaseOptions para iOS não configurado.');
      case TargetPlatform.macOS:
        throw UnsupportedError('FirebaseOptions para macOS não configurado.');
      case TargetPlatform.windows:
        return web;
      case TargetPlatform.linux:
        throw UnsupportedError('FirebaseOptions para Linux não configurado.');
      default:
        throw UnsupportedError('Plataforma não suportada.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyADtlTcU2OxYHLAXaulG6nOXwpnB5O21-I',
    appId: '1:646131190495:android:6afed9bf7bfa5570b6776a',
    messagingSenderId: '646131190495',
    projectId: 'travelnote-79d32',
    storageBucket: 'travelnote-79d32.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyACs4f_U0DH4qIy96obYnNbSyk5D1iGDQE',
    authDomain: 'travelnote-79d32.firebaseapp.com',
    projectId: 'travelnote-79d32',
    storageBucket: 'travelnote-79d32.firebasestorage.app',
    messagingSenderId: '646131190495',
    appId: '1:646131190495:web:1c14a114a8bd8ddfb6776a',
  );
}
