import '../entities/app_user.dart';
import '../entities/user_role.dart';
import '../failures/auth_failure.dart';

typedef AuthResult<T> = ({T? value, AuthFailure? failure});

abstract interface class AuthRepository {
  /// `false` cuando el backend no está configurado (por ejemplo, Firebase
  /// desactivado en local). La UI lo usa para avisar sin tocar infraestructura.
  bool get isAvailable;

  Stream<AppUser?> watchSessionUser();

  Future<AuthResult<AppUser>> signIn({
    required String email,
    required String password,
  });

  Future<AuthResult<AppUser>> signUp({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  });

  Future<void> signOut();
}
