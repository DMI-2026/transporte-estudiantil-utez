import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/core/widgets/student_bottom_nav.dart';

void main() {
  testWidgets('la barra del estudiante tiene sus cuatro pestañas', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(bottomNavigationBar: StudentBottomNav(currentIndex: 2)),
      ),
    );

    for (final texto in ['Inicio', 'Rutas', 'Reservas', 'Perfil']) {
      expect(find.text(texto), findsOneWidget);
    }
  });
}
