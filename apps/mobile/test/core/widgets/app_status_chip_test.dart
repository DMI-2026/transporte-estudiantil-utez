import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/core/widgets/app_status_chip.dart';

void main() {
  testWidgets('muestra la etiqueta y el icono', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppStatusChip(
            label: 'Cuenta aprobada',
            tone: AppStatusTone.success,
            icon: Icons.verified_user_outlined,
          ),
        ),
      ),
    );

    expect(find.text('Cuenta aprobada'), findsOneWidget);
    expect(find.byIcon(Icons.verified_user_outlined), findsOneWidget);
  });
}
