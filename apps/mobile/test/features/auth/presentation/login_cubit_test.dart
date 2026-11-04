import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/features/auth/domain/failures/auth_failure.dart';
import 'package:transporte_estudiantil/src/features/auth/presentation/login/login_cubit.dart';

import '../../../fakes/fake_auth_repository.dart';

void main() {
  group('LoginCubit', () {
    test('rechaza contraseña corta sin llamar al repo', () async {
      final repo = FakeAuthRepository();
      final cubit = LoginCubit(repo);

      await cubit.submit(email: 'a@utez.edu.mx', password: '123');

      expect(cubit.state.status, LoginStatus.failure);
      expect(cubit.state.message, contains('6 caracteres'));
      expect(repo.signInCalls, 0);
    });

    test('rechaza correo sin formato válido sin llamar al repo', () async {
      final repo = FakeAuthRepository();
      final cubit = LoginCubit(repo);

      await cubit.submit(email: 'sin-arroba', password: 'secret1');

      expect(cubit.state.status, LoginStatus.failure);
      expect(cubit.state.message, 'Correo no válido.');
      expect(repo.signInCalls, 0);
    });

    test('éxito deja status success', () async {
      final cubit = LoginCubit(FakeAuthRepository());

      await cubit.submit(email: 'a@utez.edu.mx', password: 'secret1');

      expect(cubit.state.status, LoginStatus.success);
    });

    test('un fallo de red deja mensaje sin stack', () async {
      final repo = FakeAuthRepository(signInFailure: const AuthNetworkFailure());
      final cubit = LoginCubit(repo);

      await cubit.submit(email: 'a@utez.edu.mx', password: 'secret1');

      expect(cubit.state.status, LoginStatus.failure);
      expect(cubit.state.message, contains('conexión'));
      expect(cubit.state.message, isNot(contains('Instance of')));
    });
  });
}
