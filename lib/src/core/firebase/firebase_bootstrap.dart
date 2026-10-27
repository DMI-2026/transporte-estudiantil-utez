import 'package:firebase_core/firebase_core.dart';

import '../../../firebase_options.dart';
import '../logging/app_logger.dart';

/// Arranque de Firebase. Solo llama a [Firebase.initializeApp] cuando el
/// proceso se lanzó con `--dart-define=USE_FIREBASE=true` o con
/// `--dart-define-from-file` que defina esa clave.
///
/// La configuración nativa (`google-services.json` o
/// `GoogleService-Info.plist`) no se versiona.
abstract final class FirebaseBootstrap {
  static const useFirebase = bool.fromEnvironment('USE_FIREBASE');

  static bool isReady = false;

  static Future<void> initialize() async {
    if (!useFirebase) {
      isReady = false;
      AppLogger.info(
        'Firebase desactivado. Define USE_FIREBASE=true cuando exista google-services.json o GoogleService-Info.plist.',
      );
      return;
    }

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    isReady = true;
    AppLogger.info('Firebase inicializado.');
  }
}
