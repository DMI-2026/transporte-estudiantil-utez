// Copia este archivo como lib/firebase_options.dart (está en .gitignore).
// Genera la versión real con FlutterFire CLI o a partir de google-services.json.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web no configurada.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError('Plataforma no configurada.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REEMPLAZAR',
    appId: 'REEMPLAZAR',
    messagingSenderId: 'REEMPLAZAR',
    projectId: 'utebus-4435b',
    storageBucket: 'utebus-4435b.firebasestorage.app',
  );
}
