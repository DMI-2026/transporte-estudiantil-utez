import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/features/auth/presentation/verification/verification_page.dart';

void main() {
  testWidgets('cuenta pendiente muestra mensaje de revisión', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: VerificationPage(rejected: false, onSignOut: _noop),
      ),
    );

    expect(find.text('Cuenta en revisión'), findsOneWidget);
    expect(find.textContaining('verificando tu credencial'), findsOneWidget);
  });

  testWidgets('cuenta rechazada muestra mensaje y permite cerrar sesión', (
    tester,
  ) async {
    var cerro = false;
    await tester.pumpWidget(
      MaterialApp(
        home: VerificationPage(rejected: true, onSignOut: () => cerro = true),
      ),
    );

    expect(find.text('Cuenta no aprobada'), findsOneWidget);
    await tester.tap(find.text('Cerrar sesión'));
    expect(cerro, isTrue);
  });
}

void _noop() {}
