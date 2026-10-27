import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/features/auth/domain/failures/auth_failure.dart';
import 'package:transporte_estudiantil/src/features/auth/presentation/login/login_page.dart';

import '../../../fakes/fake_auth_repository.dart';

void main() {
  Future<void> montar(WidgetTester tester, FakeAuthRepository repo) async {
    await tester.pumpWidget(MaterialApp(home: LoginPage(repository: repo)));
  }

  testWidgets('muestra el título y permite entrar', (tester) async {
    final repo = FakeAuthRepository();
    await montar(tester, repo);

    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('Transporte Estudiantil UTEZ'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('campo-correo')), 'a@utez.edu.mx');
    await tester.enterText(find.byKey(const Key('campo-contrasena')), 'secret1');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(repo.signInCalls, 1);
  });

  testWidgets('con backend desactivado muestra el aviso', (tester) async {
    await montar(tester, FakeAuthRepository(isAvailable: false));

    expect(find.text('Firebase desactivado'), findsOneWidget);
  });

  testWidgets('con backend disponible no muestra el aviso', (tester) async {
    await montar(tester, FakeAuthRepository());

    expect(find.text('Firebase desactivado'), findsNothing);
  });

  testWidgets('si falla la carga muestra el error, no un stack', (tester) async {
    final repo = FakeAuthRepository(signInFailure: const AuthNetworkFailure());
    await montar(tester, repo);

    await tester.enterText(find.byKey(const Key('campo-correo')), 'a@utez.edu.mx');
    await tester.enterText(find.byKey(const Key('campo-contrasena')), 'secret1');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('No pudimos iniciar sesión'), findsOneWidget);
    expect(find.textContaining('conexión'), findsOneWidget);
    expect(find.textContaining('Instance of'), findsNothing);
  });
}
