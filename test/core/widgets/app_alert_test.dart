import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/core/widgets/app_alert.dart';

void main() {
  testWidgets('muestra título, mensaje e icono', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppAlert(
            tone: AppAlertTone.success,
            title: 'Reserva confirmada',
            message: 'Tu asiento quedó reservado.',
          ),
        ),
      ),
    );

    expect(find.text('Reserva confirmada'), findsOneWidget);
    expect(find.text('Tu asiento quedó reservado.'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
  });

  testWidgets('permite cerrar el aviso', (tester) async {
    var cerrado = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppAlert(title: 'Aviso', onClose: () => cerrado = true),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Cerrar aviso'));

    expect(cerrado, isTrue);
  });
}
