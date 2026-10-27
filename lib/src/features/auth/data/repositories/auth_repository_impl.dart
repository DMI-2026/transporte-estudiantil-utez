import '../../domain/entities/app_user.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_gateway.dart';
import '../datasources/user_remote_datasource.dart';
import '../models/app_user_mapper.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.authGateway,
    required this.users,
  });

  final AuthGateway authGateway;
  final UserRemoteDataSource users;

  @override
  bool get isAvailable => true;

  @override
  Stream<AppUser?> watchSessionUser() {
    return authGateway.watchUid().asyncMap(_loadProfile);
  }

  Future<AppUser?> _loadProfile(String? uid) async {
    if (uid == null) {
      return null;
    }
    final data = await users.fetchProfile(uid);
    return AppUserMapper.fromFirestore(uid, data);
  }

  @override
  Future<AuthResult<AppUser>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final uid = await authGateway.signIn(email: email, password: password);
      final profile = await _loadProfile(uid);
      if (profile == null) {
        return (value: null, failure: const AuthGenericFailure());
      }
      return (value: profile, failure: null);
    } on AppFailure catch (e) {
      return (value: null, failure: e);
    } catch (_) {
      return (value: null, failure: const AuthNetworkFailure());
    }
  }

  @override
  Future<AuthResult<AppUser>> signUp({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  }) async {
    try {
      final uid = await authGateway.signUp(email: email, password: password);
      await users.saveProfile(
        uid,
        AppUserMapper.newProfile(
          email: email,
          displayName: displayName,
          role: role,
        ),
      );
      final profile = await _loadProfile(uid);
      if (profile == null) {
        return (value: null, failure: const AuthGenericFailure());
      }
      return (value: profile, failure: null);
    } on AppFailure catch (e) {
      // Si Auth creó la cuenta pero el perfil no se guardó, no dejamos una
      // sesión huérfana (usuario autenticado sin documento en Firestore).
      await _signOutSilently();
      return (value: null, failure: e);
    } catch (_) {
      await _signOutSilently();
      return (value: null, failure: const AuthNetworkFailure());
    }
  }

  Future<void> _signOutSilently() async {
    try {
      await authGateway.signOut();
    } catch (_) {
      // Ignorar: ya estamos reportando el fallo original.
    }
  }

  @override
  Future<void> signOut() => authGateway.signOut();
}
