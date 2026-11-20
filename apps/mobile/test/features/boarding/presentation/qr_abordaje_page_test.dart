import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:transporte_estudiantil/src/features/boarding/data/pase_gateway.dart';
import 'package:transporte_estudiantil/src/features/boarding/presentation/qr_abordaje_page.dart';

import '../../../fakes/fake_reservations_repository.dart';

void main() {
  testWidgets('una reserva pagada muestra el QR', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: QrAbordajePage(
          folio: 'UTEZ-1048',
          repository: FakeReservationsRepository(),
          pase: const DemoPaseGateway(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(QrImageView), findsOneWidget);
    expect(find.text('Presenta este código al operador'), findsOneWidget);
  });

  testWidgets('una reserva cancelada no muestra QR', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: QrAbordajePage(
          folio: 'UTEZ-1022',
          repository: FakeReservationsRepository(
            reservas: [FixturesEstudiante.cancelada],
          ),
          pase: const DemoPaseGateway(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(QrImageView), findsNothing);
    expect(find.text('Este QR ya no es válido'), findsOneWidget);
  });
}
