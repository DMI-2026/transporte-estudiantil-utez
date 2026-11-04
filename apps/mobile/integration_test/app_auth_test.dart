import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/app/app.dart';
import 'package:transporte_estudiantil/src/core/di/injection.dart';

/// Humo del arranque sin Firebase. Corre en el tester de Flutter
/// (no hace falta un celular): `flutter test integration_test`.
void main() {
  setUp(() async {
    await getIt.reset();
    await configureDependencies();
  });

  testWidgets('arranca en login y avisa que Firebase está desactivado', (
    tester,
  ) async {
    await tester.pumpWidget(const TransporteApp());
    await tester.pumpAndSettle();

    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('Firebase desactivado'), findsOneWidget);
    expect(find.byKey(const Key('campo-correo')), findsOneWidget);
    expect(find.byKey(const Key('campo-contrasena')), findsOneWidget);
  });

  testWidgets('entrar sin backend muestra un mensaje de usuario, no un stack', (
    tester,
  ) async {
    await tester.pumpWidget(const TransporteApp());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('campo-correo')),
      'a@utez.edu.mx',
    );
    await tester.enterText(find.byKey(const Key('campo-contrasena')), 'secret1');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('No pudimos iniciar sesión'), findsOneWidget);
    expect(find.textContaining('Instance of'), findsNothing);
  });

  testWidgets('desde login se abre el registro y se valida el correo UTEZ', (
    tester,
  ) async {
    await tester.pumpWidget(const TransporteApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Crear cuenta'));
    await tester.pumpAndSettle();

    expect(find.text('Registro'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('campo-nombre')), 'Ana');
    await tester.enterText(
      find.byKey(const Key('campo-correo')),
      'ana@gmail.com',
    );
    await tester.enterText(find.byKey(const Key('campo-contrasena')), 'secret1');
    await tester.tap(find.text('Registrarme'));
    await tester.pumpAndSettle();

    expect(find.text('No pudimos crear la cuenta'), findsOneWidget);
    expect(find.textContaining('@utez.edu.mx'), findsWidgets);
  });
}
