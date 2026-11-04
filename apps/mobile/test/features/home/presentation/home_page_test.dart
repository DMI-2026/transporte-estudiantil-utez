import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/features/home/presentation/home_page.dart';

import '../../../fakes/fake_auth_repository.dart';

void main() {
  testWidgets('con usuario muestra saludo y no lista vacía', (tester) async {
    var cerro = false;
    await tester.pumpWidget(
      MaterialApp(
        home: HomePage(
          user: FakeAuthRepository.demoEstudiante,
          onSignOut: () => cerro = true,
        ),
      ),
    );

    expect(find.text('Transporte exclusivo estudiantil'), findsOneWidget);
    expect(find.text('Hola, Ana Demo'), findsOneWidget);

    await tester.tap(find.byTooltip('Cerrar sesión'));
    expect(cerro, isTrue);
  });

  testWidgets('sin usuario muestra mensaje vacío', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: HomePage(user: null, onSignOut: _noop)),
    );

    expect(find.text('Sin sesión'), findsOneWidget);
    expect(find.textContaining('No hay sesión activa'), findsOneWidget);
  });
}

void _noop() {}
