import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/features/auth/domain/entities/user_role.dart';
import 'package:transporte_estudiantil/src/features/auth/domain/failures/auth_failure.dart';
import 'package:transporte_estudiantil/src/features/auth/presentation/register/register_cubit.dart';

import '../../../fakes/fake_auth_repository.dart';

void main() {
  group('RegisterCubit', () {
    test('estudiante con gmail no llama al repo', () async {
      final repo = FakeAuthRepository();
      final cubit = RegisterCubit(repo);

      await cubit.submit(
        email: 'a@gmail.com',
        password: 'secret1',
        displayName: 'Ana',
        role: UserRole.estudiante,
      );

      expect(cubit.state.status, RegisterStatus.failure);
      expect(cubit.state.message, contains('@utez.edu.mx'));
      expect(repo.signUpCalls, 0);
    });

    test('operador con correo libre registra', () async {
      final repo = FakeAuthRepository();
      final cubit = RegisterCubit(repo);

      await cubit.submit(
        email: 'op@mail.com',
        password: 'secret1',
        displayName: 'Luis',
        role: UserRole.operador,
      );

      expect(cubit.state.status, RegisterStatus.success);
      expect(repo.signUpCalls, 1);
    });

    test('correo duplicado muestra el mensaje del dominio', () async {
      final repo = FakeAuthRepository(
        signUpFailure: const AuthInvalidInputFailure(
          'Ese correo ya está registrado.',
        ),
      );
      final cubit = RegisterCubit(repo);

      await cubit.submit(
        email: 'a@utez.edu.mx',
        password: 'secret1',
        displayName: 'Ana',
        role: UserRole.estudiante,
      );

      expect(cubit.state.message, contains('ya está registrado'));
    });
  });
}
