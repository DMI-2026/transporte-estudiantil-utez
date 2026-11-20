import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/firebase_auth_gateway.dart';
import '../../features/auth/data/datasources/firestore_user_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/data/repositories/unavailable_auth_repository.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/session/auth_session_cubit.dart';
import '../../features/routes_map/data/datasources/firestore_routes_remote_datasource.dart';
import '../../features/routes_map/data/repositories/routes_repository_impl.dart';
import '../../features/routes_map/domain/repositories/routes_repository.dart';
import '../../features/incidents/data/datasources/demo_incidents_datasource.dart';
import '../../features/incidents/data/datasources/firestore_incidents_datasource.dart';
import '../../features/incidents/data/datasources/incidents_datasource.dart';
import '../../features/incidents/data/repositories/incidents_repository_impl.dart';
import '../../features/incidents/domain/repositories/incidents_repository.dart';
import '../../features/profile/data/datasources/demo_profile_datasource.dart';
import '../../features/profile/data/datasources/firestore_profile_datasource.dart';
import '../../features/profile/data/datasources/profile_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/reservations/data/datasources/demo_reservations_datasource.dart';
import '../../features/reservations/data/datasources/firestore_reservations_datasource.dart';
import '../../features/reservations/data/datasources/reservations_datasource.dart';
import '../../features/reservations/data/repositories/reservations_repository_impl.dart';
import '../../features/reservations/domain/repositories/reservations_repository.dart';
import '../../features/trip/data/repositories/demo_trip_repository.dart';
import '../../features/trip/domain/repositories/trip_repository.dart';
import '../firebase/firebase_bootstrap.dart';
import '../router/app_router.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  await FirebaseBootstrap.initialize();

  _configureCore();
  _configureRoutes();
  _configureEstudiante();
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

void _configureRoutes() {
  getIt.registerLazySingleton<RoutesRepository>(
    () => RoutesRepositoryImpl(
      FirestoreRoutesRemoteDataSource(getIt<FirebaseFirestore>()),
    ),
  );
}

/// Módulo estudiante: reservas usan Firestore si Firebase está listo;
/// el resto sigue en fuentes de demostración hasta su issue de backend.
void _configureEstudiante() {
  getIt.registerLazySingleton<ReservationsDataSource>(() {
    if (!FirebaseBootstrap.isReady) {
      return DemoReservationsDataSource();
    }
    return FirestoreReservationsDataSource(
      firestore: getIt<FirebaseFirestore>(),
      currentUid: () => FirebaseAuth.instance.currentUser?.uid,
    );
  });
  getIt.registerLazySingleton<ReservationsRepository>(
    () => ReservationsRepositoryImpl(getIt<ReservationsDataSource>()),
  );
  getIt.registerLazySingleton<TripRepository>(
    () => DemoTripRepository(getIt<ReservationsDataSource>()),
  );
  getIt.registerLazySingleton<IncidentsDataSource>(() {
    if (!FirebaseBootstrap.isReady) {
      return DemoIncidentsDataSource();
    }
    return FirestoreIncidentsDataSource(
      firestore: getIt<FirebaseFirestore>(),
      storage: FirebaseStorage.instance,
      currentUid: () => FirebaseAuth.instance.currentUser?.uid,
    );
  });
  getIt.registerLazySingleton<IncidentsRepository>(
    () => IncidentsRepositoryImpl(getIt<IncidentsDataSource>()),
  );
  getIt.registerLazySingleton<ProfileDataSource>(() {
    if (!FirebaseBootstrap.isReady) {
      return DemoProfileDataSource();
    }
    return FirestoreProfileDataSource(
      firestore: getIt<FirebaseFirestore>(),
      currentUid: () => FirebaseAuth.instance.currentUser?.uid,
    );
  });
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(getIt<ProfileDataSource>()),
  );
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
