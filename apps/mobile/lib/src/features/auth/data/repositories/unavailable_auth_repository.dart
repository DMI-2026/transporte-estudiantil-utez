import '../../domain/entities/app_user.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';

class UnavailableAuthRepository implements AuthRepository {
  @override
  bool get isAvailable => false;

  @override
  Stream<AppUser?> watchSessionUser() async* {
    yield null;
  }

  @override
  Future<AuthResult<AppUser>> signIn({
    required String email,
    required String password,
  }) async {
    return (value: null, failure: const AuthUnavailableFailure());
  }

  @override
  Future<AuthResult<AppUser>> signUp({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  }) async {
    return (value: null, failure: const AuthUnavailableFailure());
  }

  @override
  Future<void> signOut() async {}
}
