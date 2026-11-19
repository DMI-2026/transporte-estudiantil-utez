import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import '../../features/incidents/data/repositories/incidents_repository_impl.dart';
import '../../features/incidents/domain/repositories/incidents_repository.dart';
import '../../features/profile/data/datasources/demo_profile_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/reservations/data/datasources/demo_reservations_datasource.dart';
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

/// Módulo estudiante con fuentes de DEMOSTRACIÓN en memoria (sin Firebase).
/// Cuando exista el backend, se cambia solo la fuente de datos aquí.
void _configureEstudiante() {
  getIt.registerLazySingleton<ReservationsDataSource>(
    DemoReservationsDataSource.new,
  );
  getIt.registerLazySingleton<ReservationsRepository>(
    () => ReservationsRepositoryImpl(getIt<ReservationsDataSource>()),
  );
  getIt.registerLazySingleton<TripRepository>(
    () => DemoTripRepository(getIt<ReservationsDataSource>()),
  );
  getIt.registerLazySingleton<IncidentsRepository>(
    () => IncidentsRepositoryImpl(DemoIncidentsDataSource()),
  );
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(DemoProfileDataSource()),
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
