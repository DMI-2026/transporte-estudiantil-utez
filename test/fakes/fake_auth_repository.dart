import 'package:transporte_estudiantil/src/features/auth/domain/entities/app_user.dart';
import 'package:transporte_estudiantil/src/features/auth/domain/entities/user_role.dart';
import 'package:transporte_estudiantil/src/features/auth/domain/entities/verification_status.dart';
import 'package:transporte_estudiantil/src/features/auth/domain/failures/auth_failure.dart';
import 'package:transporte_estudiantil/src/features/auth/domain/repositories/auth_repository.dart';

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

  static const demoEstudiante = AppUser(
    uid: 'uid-1',
    email: 'a@utez.edu.mx',
    role: UserRole.estudiante,
    verificationStatus: VerificationStatus.aprobada,
    displayName: 'Ana Demo',
  );

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
    session = demoEstudiante;
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
