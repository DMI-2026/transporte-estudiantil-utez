import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/core/widgets/app_trip_card.dart';

void main() {
  testWidgets('muestra ruta, horario, estado y pie', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppTripCard(
            routeCode: 'R01',
            statusLabel: 'Confirmada',
            origin: 'Centro Cuernavaca',
            destination: 'UTEZ',
            departureTime: '06:40',
            arrivalTime: '07:25',
            dateLabel: 'Lunes 26 oct 2026',
            unitLabel: 'Unidad U-07',
            onTap: () => taps++,
          ),
        ),
      ),
    );

    expect(find.text('R01 · Confirmada'), findsOneWidget);
    expect(find.text('Centro Cuernavaca — UTEZ'), findsOneWidget);
    expect(find.text('06:40  →  07:25'), findsOneWidget);
    expect(find.text('Lunes 26 oct 2026 · Unidad U-07'), findsOneWidget);

    await tester.tap(find.text('Centro Cuernavaca — UTEZ'));
    expect(taps, 1);
  });
}
