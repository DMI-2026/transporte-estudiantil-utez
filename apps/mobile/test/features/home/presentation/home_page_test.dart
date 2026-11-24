import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/features/home/presentation/home_page.dart';

import '../../../fakes/fake_auth_repository.dart';
import '../../../fakes/fake_reservations_repository.dart';

void main() {
  testWidgets('con usuario muestra saludo y próxima reserva', (tester) async {
    var cerro = false;
    await tester.pumpWidget(
      MaterialApp(
        home: HomePage(
          user: FakeAuthRepository.demoEstudiante,
          onSignOut: () => cerro = true,
          reservations: FakeReservationsRepository(
            reservas: [FixturesEstudiante.activa],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hola, Ana Demo'), findsOneWidget);
    expect(find.text('Próxima reserva'), findsOneWidget);
    expect(find.text('Inicio'), findsOneWidget);
    expect(find.textContaining(FixturesEstudiante.activa.folio), findsOneWidget);

    await tester.tap(find.byTooltip('Cerrar sesión'));
    expect(cerro, isTrue);
  });

  testWidgets('sin usuario muestra mensaje vacío', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomePage(
          user: null,
          onSignOut: _noop,
          reservations: FakeReservationsRepository(reservas: []),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sin sesión'), findsOneWidget);
    expect(find.textContaining('No hay sesión activa'), findsOneWidget);
  });
}

void _noop() {}
