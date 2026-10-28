import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/features/auth/presentation/register/register_page.dart';

import '../../../fakes/fake_auth_repository.dart';

void main() {
  Future<void> montar(WidgetTester tester, FakeAuthRepository repo) async {
    await tester.pumpWidget(MaterialApp(home: RegisterPage(repository: repo)));
  }

  Future<void> llenar(
    WidgetTester tester, {
    required String nombre,
    required String correo,
    required String contrasena,
  }) async {
    await tester.enterText(find.byKey(const Key('campo-nombre')), nombre);
    await tester.enterText(find.byKey(const Key('campo-correo')), correo);
    await tester.enterText(
      find.byKey(const Key('campo-contrasena')),
      contrasena,
    );
  }

  testWidgets('registra estudiante con correo institucional', (tester) async {
    final repo = FakeAuthRepository();
    await montar(tester, repo);

    await llenar(
      tester,
      nombre: 'Ana',
      correo: 'ana@utez.edu.mx',
      contrasena: 'secret1',
    );
    await tester.tap(find.text('Registrarme'));
    await tester.pumpAndSettle();

    expect(repo.signUpCalls, 1);
    expect(find.text('No pudimos crear la cuenta'), findsNothing);
  });

  testWidgets('estudiante con correo externo ve el error y no llama al repo', (
    tester,
  ) async {
    final repo = FakeAuthRepository();
    await montar(tester, repo);

    await llenar(
      tester,
      nombre: 'Ana',
      correo: 'ana@gmail.com',
      contrasena: 'secret1',
    );
    await tester.tap(find.text('Registrarme'));
    await tester.pumpAndSettle();

    expect(repo.signUpCalls, 0);
    expect(find.text('No pudimos crear la cuenta'), findsOneWidget);
    expect(find.textContaining('@utez.edu.mx'), findsWidgets);
  });
}
