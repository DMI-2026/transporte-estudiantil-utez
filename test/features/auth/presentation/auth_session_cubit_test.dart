import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/features/auth/domain/entities/app_user.dart';
import 'package:transporte_estudiantil/src/features/auth/domain/entities/user_role.dart';
import 'package:transporte_estudiantil/src/features/auth/domain/entities/verification_status.dart';
import 'package:transporte_estudiantil/src/features/auth/presentation/session/auth_session_cubit.dart';

import '../../../fakes/fake_auth_repository.dart';

class _RepoConStream extends FakeAuthRepository {
  final controller = StreamController<AppUser?>();

  @override
  Stream<AppUser?> watchSessionUser() => controller.stream;
}

AppUser _usuario(VerificationStatus estado) => AppUser(
  uid: 'u1',
  email: 'a@utez.edu.mx',
  role: UserRole.estudiante,
  verificationStatus: estado,
);

void main() {
  group('AuthSessionCubit', () {
    late _RepoConStream repo;
    late AuthSessionCubit cubit;

    setUp(() {
      repo = _RepoConStream();
      cubit = AuthSessionCubit(repo)..start();
    });

    tearDown(() async {
      await cubit.close();
      await repo.controller.close();
    });

    test('arranca en loading sin usuario', () {
      expect(cubit.state.status, AuthSessionStatus.loading);
      expect(cubit.state.user, isNull);
    });

    test('null → unauthenticated', () async {
      repo.controller.add(null);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.status, AuthSessionStatus.unauthenticated);
      expect(cubit.state.user, isNull);
    });

    test('mapea estadoVerificacion al estado de sesión', () async {
      final esperados = {
        VerificationStatus.aprobada: AuthSessionStatus.authenticated,
        VerificationStatus.pendiente: AuthSessionStatus.pendingVerification,
        VerificationStatus.rechazada: AuthSessionStatus.rejected,
      };

      for (final entry in esperados.entries) {
        repo.controller.add(_usuario(entry.key));
        await Future<void>.delayed(Duration.zero);
        expect(cubit.state.status, entry.value, reason: entry.key.name);
        expect(cubit.state.user?.uid, 'u1');
      }
      expect(cubit.state.isRejected, isTrue);
    });

    test('emite un estado por cada cambio del repositorio', () async {
      final emitidos = <AuthSessionStatus>[];
      final sub = cubit.stream.listen((s) => emitidos.add(s.status));

      repo.controller.add(_usuario(VerificationStatus.aprobada));
      repo.controller.add(null);
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(emitidos, [
        AuthSessionStatus.authenticated,
        AuthSessionStatus.unauthenticated,
      ]);
    });

    test('signOut delega en el repositorio', () async {
      await cubit.signOut();
      expect(repo.signOutCalls, 1);
    });

    test('backendAvailable refleja el repositorio', () {
      expect(cubit.backendAvailable, isTrue);
      expect(
        AuthSessionCubit(FakeAuthRepository(isAvailable: false)).backendAvailable,
        isFalse,
      );
    });
  });
}
