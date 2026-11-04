import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/core/errors/app_failure.dart';
import 'package:transporte_estudiantil/src/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:transporte_estudiantil/src/features/auth/domain/entities/user_role.dart';
import 'package:transporte_estudiantil/src/features/auth/domain/failures/auth_failure.dart';

import '../../../fakes/fake_auth_gateway.dart';
import '../../../fakes/fake_user_remote_datasource.dart';

void main() {
  Map<String, dynamic> perfil({String estado = 'aprobada'}) => {
    'email': 'a@utez.edu.mx',
    'rol': 'estudiante',
    'estadoVerificacion': estado,
    'nombreCompleto': 'Ana',
  };

  group('AuthRepositoryImpl', () {
    test('signIn carga el perfil de Firestore', () async {
      final gateway = FakeAuthGateway(uid: 'uid-1');
      final users = FakeUserRemoteDataSource(
        perfiles: {'uid-1': perfil()},
      );
      final repo = AuthRepositoryImpl(authGateway: gateway, users: users);

      final result = await repo.signIn(
        email: 'a@utez.edu.mx',
        password: 'secret1',
      );

      expect(result.failure, isNull);
      expect(result.value?.uid, 'uid-1');
      expect(result.value?.displayName, 'Ana');
      expect(gateway.signInCalls, 1);
    });

    test('signIn con fallo de red deja mensaje accionable', () async {
      final gateway = FakeAuthGateway()
        ..fallaAlEntrar = const AuthNetworkFailure();
      final repo = AuthRepositoryImpl(
        authGateway: gateway,
        users: FakeUserRemoteDataSource(),
      );

      final result = await repo.signIn(email: 'a@x.com', password: 'secret1');

      expect(result.value, isNull);
      expect(result.failure, isA<AuthNetworkFailure>());
      expect(result.failure!.userMessage, contains('conexión'));
    });

    test('signUp guarda el documento de usuario', () async {
      final gateway = FakeAuthGateway();
      final users = FakeUserRemoteDataSource();
      final repo = AuthRepositoryImpl(authGateway: gateway, users: users);

      final result = await repo.signUp(
        email: 'a@utez.edu.mx',
        password: 'secret1',
        displayName: 'Ana',
        role: UserRole.estudiante,
      );

      expect(result.failure, isNull);
      expect(users.perfiles['uid-nuevo']?['email'], 'a@utez.edu.mx');
      expect(users.perfiles['uid-nuevo']?['estadoVerificacion'], 'pendiente');
    });

    test('signUp sin perfil legible no reporta éxito', () async {
      final gateway = FakeAuthGateway();
      // Guardar funciona pero la lectura devuelve un perfil incompleto.
      final users = _DatasourceQueDevuelveNull();
      final repo = AuthRepositoryImpl(authGateway: gateway, users: users);

      final result = await repo.signUp(
        email: 'a@utez.edu.mx',
        password: 'secret1',
        displayName: 'Ana',
        role: UserRole.estudiante,
      );

      expect(result.value, isNull);
      expect(result.failure, isA<AuthGenericFailure>());
    });

    test('si falla guardar el perfil, cierra la sesión huérfana', () async {
      final gateway = FakeAuthGateway();
      final users = FakeUserRemoteDataSource()
        ..fallaAlGuardar = const FirestoreFailure();
      final repo = AuthRepositoryImpl(authGateway: gateway, users: users);

      final result = await repo.signUp(
        email: 'a@utez.edu.mx',
        password: 'secret1',
        displayName: 'Ana',
        role: UserRole.estudiante,
      );

      expect(result.failure, isA<FirestoreFailure>());
      expect(gateway.signOutCalls, 1);
      expect(gateway.uid, isNull);
    });

    test('si Firestore falla al leer, no se confirma el perfil', () async {
      final gateway = FakeAuthGateway(uid: 'uid-1');
      final users = FakeUserRemoteDataSource()
        ..fallaAlLeer = const FirestoreFailure();
      final repo = AuthRepositoryImpl(authGateway: gateway, users: users);

      final result = await repo.signIn(email: 'a@x.com', password: 'secret1');

      expect(result.value, isNull);
      expect(result.failure, isA<FirestoreFailure>());
    });
  });
}

class _DatasourceQueDevuelveNull extends FakeUserRemoteDataSource {
  @override
  Future<Map<String, dynamic>?> fetchProfile(String uid) async => null;
}
