import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/firebase_auth_gateway.dart';
import '../../features/auth/data/datasources/firestore_user_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/data/repositories/unavailable_auth_repository.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/session/auth_session_cubit.dart';
import '../firebase/firebase_bootstrap.dart';
import '../router/app_router.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  await FirebaseBootstrap.initialize();

  _configureCore();
  await _configureAuth();
  _configureRouter();
}

void _configureCore() {
  getIt.registerLazySingleton<FirebaseFirestore>(() {
    if (!FirebaseBootstrap.isReady) {
      return UnavailableFirestore();
    }
    return FirebaseFirestore.instance;
  });
}

Future<void> _configureAuth() async {
  getIt.registerLazySingleton<AuthRepository>(() {
    if (!FirebaseBootstrap.isReady) {
      return UnavailableAuthRepository();
    }
    return AuthRepositoryImpl(
      authGateway: FirebaseAuthGateway(FirebaseAuth.instance),
      users: FirestoreUserRemoteDataSource(getIt<FirebaseFirestore>()),
    );
  });

  final session = AuthSessionCubit(getIt<AuthRepository>())..start();
  getIt.registerSingleton<AuthSessionCubit>(session);
}

void _configureRouter() {
  getIt.registerLazySingleton<AppRouter>(() => AppRouter(getIt<AuthSessionCubit>()));
}

/// Firestore no disponible cuando USE_FIREBASE=false.
/// Evita runtime error en _configureAuth al inyectar en FirestoreUserRemoteDataSource.
class UnavailableFirestore implements FirebaseFirestore {
  @override
  noSuchMethod(Invocation invocation) => throw StateError(
        'Firestore no disponible. Activa USE_FIREBASE con google-services.json / GoogleService-Info.plist.',
      );
}
