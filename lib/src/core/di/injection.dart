import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import '../firebase/firebase_bootstrap.dart';
import '../router/app_router.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  await FirebaseBootstrap.initialize();

  getIt.registerLazySingleton<FirebaseFirestore>(() {
    if (!FirebaseBootstrap.isReady) {
      throw StateError(
        'Cloud Firestore no está disponible. Activa USE_FIREBASE cuando el proyecto tenga google-services.json o GoogleService-Info.plist.',
      );
    }
    return FirebaseFirestore.instance;
  });

  getIt.registerLazySingleton<AppRouter>(AppRouter.new);
}
