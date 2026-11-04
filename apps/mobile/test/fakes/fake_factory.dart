import 'package:transporte_estudiantil/src/features/auth/domain/entities/app_user.dart';
import 'package:transporte_estudiantil/src/features/auth/domain/entities/user_role.dart';
import 'package:transporte_estudiantil/src/features/auth/domain/entities/verification_status.dart';
import 'package:transporte_estudiantil/src/features/auth/domain/failures/auth_failure.dart';
import 'package:transporte_estudiantil/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:transporte_estudiantil/src/features/auth/data/datasources/auth_gateway.dart';
import 'package:transporte_estudiantil/src/features/auth/data/datasources/user_remote_datasource.dart';

/// Factory centralizado para crear fakes consistentes en tests.
/// Evita duplicación de configuración y asegura comportamiento uniforme.
class FakeFactory {
  FakeFactory._();

  /// Repositorio de auth configurable para tests.
  static FakeAuthRepository authRepository({
    AppUser? session,
    AuthFailure? signInFailure,
    AuthFailure? signUpFailure,
    bool isAvailable = true,
  }) =>
      FakeAuthRepository(
        session: session,
        signInFailure: signInFailure,
        signUpFailure: signUpFailure,
        isAvailable: isAvailable,
      );

  /// Gateway de auth configurable.
  static FakeAuthGateway authGateway({
    String? uid,
    AuthFailure? signInFailure,
    AuthFailure? signUpFailure,
    AuthFailure? signOutFailure,
  }) =>
      FakeAuthGateway(
        currentUid: uid,
        signInFailure: signInFailure,
        signUpFailure: signUpFailure,
        signOutFailure: signOutFailure,
      );

  /// Datasource de usuarios configurable.
  static FakeUserRemoteDataSource userRemoteDataSource({
    Map<String, Map<String, dynamic>>? profiles,
    AuthFailure? fetchFailure,
    AuthFailure? saveFailure,
  }) =>
      FakeUserRemoteDataSource(
        profiles: profiles ?? {},
        fetchFailure: fetchFailure,
        saveFailure: saveFailure,
      );

  /// Usuario estudiante demo aprobado.
  static const AppUser demoEstudiante = AppUser(
    uid: 'uid-estudiante',
    email: 'estudiante@utez.edu.mx',
    role: UserRole.estudiante,
    verificationStatus: VerificationStatus.aprobada,
    displayName: 'Estudiante Demo',
  );

  /// Usuario operador demo aprobado.
  static const AppUser demoOperador = AppUser(
    uid: 'uid-operador',
    email: 'operador@utez.edu.mx',
    role: UserRole.operador,
    verificationStatus: VerificationStatus.aprobada,
    displayName: 'Operador Demo',
  );

  /// Usuario admin demo aprobado.
  static const AppUser demoAdmin = AppUser(
    uid: 'uid-admin',
    email: 'admin@utez.edu.mx',
    role: UserRole.administrador,
    verificationStatus: VerificationStatus.aprobada,
    displayName: 'Admin Demo',
  );

  /// Usuario con verificación pendiente.
  static const AppUser demoPendiente = AppUser(
    uid: 'uid-pendiente',
    email: 'pendiente@utez.edu.mx',
    role: UserRole.estudiante,
    verificationStatus: VerificationStatus.pendiente,
    displayName: 'Pendiente Demo',
  );

  /// Usuario rechazado.
  static const AppUser demoRechazado = AppUser(
    uid: 'uid-rechazado',
    email: 'rechazado@utez.edu.mx',
    role: UserRole.estudiante,
    verificationStatus: VerificationStatus.rechazada,
    displayName: 'Rechazado Demo',
  );
}

/// Repositorio fake re-exportado para conveniencia.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    this.session,
    this.signInFailure,
    this.signUpFailure,
    this.isAvailable = true,
  });

  @override
  final bool isAvailable;
  AppUser? session;
  int signOutCalls = 0;
  AuthFailure? signInFailure;
  AuthFailure? signUpFailure;
  int signInCalls = 0;
  int signUpCalls = 0;

  @override
  Stream<AppUser?> watchSessionUser() async* {
    yield session;
  }

  @override
  Future<AuthResult<AppUser>> signIn({
    required String email,
    required String password,
  }) async {
    signInCalls++;
    if (signInFailure != null) {
      return (value: null, failure: signInFailure);
    }
    session = FakeFactory.demoEstudiante;
    return (value: session, failure: null);
  }

  @override
  Future<AuthResult<AppUser>> signUp({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  }) async {
    signUpCalls++;
    if (signUpFailure != null) {
      return (value: null, failure: signUpFailure);
    }
    session = AppUser(
      uid: 'uid-nuevo',
      email: email,
      role: role,
      verificationStatus: VerificationStatus.pendiente,
      displayName: displayName,
    );
    return (value: session, failure: null);
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    session = null;
  }
}

/// Gateway fake re-exportado para conveniencia.
class FakeAuthGateway implements AuthGateway {
  FakeAuthGateway({
    this.currentUid,
    this.signInFailure,
    this.signUpFailure,
    this.signOutFailure,
  });

  String? currentUid;
  AuthFailure? signInFailure;
  AuthFailure? signUpFailure;
  AuthFailure? signOutFailure;
  int signInCalls = 0;
  int signUpCalls = 0;
  int signOutCalls = 0;

  @override
  Stream<String?> watchUid() async* {
    yield currentUid;
  }

  @override
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    signInCalls++;
    if (signInFailure != null) throw signInFailure!;
    currentUid = 'uid-$signInCalls';
    return currentUid!;
  }

  @override
  Future<String> signUp({
    required String email,
    required String password,
  }) async {
    signUpCalls++;
    if (signUpFailure != null) throw signUpFailure!;
    currentUid = 'uid-nuevo-$signUpCalls';
    return currentUid!;
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    if (signOutFailure != null) throw signOutFailure!;
    currentUid = null;
  }
}

/// Datasource fake re-exportado para conveniencia.
class FakeUserRemoteDataSource implements UserRemoteDataSource {
  FakeUserRemoteDataSource({
    required this.profiles,
    this.fetchFailure,
    this.saveFailure,
  });

  final Map<String, Map<String, dynamic>> profiles;
  AuthFailure? fetchFailure;
  AuthFailure? saveFailure;
  int fetchCalls = 0;
  int saveCalls = 0;

  @override
  Future<Map<String, dynamic>?> fetchProfile(String uid) async {
    fetchCalls++;
    if (fetchFailure != null) throw fetchFailure!;
    return profiles[uid];
  }

  @override
  Future<void> saveProfile(String uid, Map<String, Object?> data) async {
    saveCalls++;
    if (saveFailure != null) throw saveFailure!;
    profiles[uid] = Map<String, dynamic>.from(data);
  }
}