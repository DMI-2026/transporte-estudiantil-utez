import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/features/reservations/presentation/mis_reservas/mis_reservas_page.dart';

import '../../../fakes/fake_reservations_repository.dart';

void main() {
  testWidgets('muestra próximas, anteriores y la barra con Reservas', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MisReservasPage(
          repository: FakeReservationsRepository(
            reservas: [FixturesEstudiante.activa, FixturesEstudiante.abordada],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mis reservas'), findsOneWidget);
    expect(find.text('Próximas · 1'), findsOneWidget);
    expect(find.text('Anteriores · 1'), findsOneWidget);
    expect(find.text('R01 · Reservada'), findsOneWidget);
    expect(find.text('Reservar un viaje'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);
  });

  testWidgets('sin reservas muestra el estado vacío', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MisReservasPage(
          repository: FakeReservationsRepository(reservas: []),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Aún no tienes un viaje'), findsOneWidget);
  });
}
