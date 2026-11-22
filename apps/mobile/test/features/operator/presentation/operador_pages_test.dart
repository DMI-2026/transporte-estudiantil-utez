import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/core/widgets/operator_bottom_nav.dart';
import 'package:transporte_estudiantil/src/features/operator/presentation/abordaje/lista_abordaje_page.dart';
import 'package:transporte_estudiantil/src/features/operator/presentation/perfil/operador_perfil_page.dart';
import 'package:transporte_estudiantil/src/features/operator/presentation/salidas/operador_salidas_page.dart';

import '../../../fakes/fake_auth_repository.dart';
import '../../../fakes/fake_operator_repository.dart';

void main() {
  testWidgets('la barra del operador tiene sus cuatro pestañas', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(bottomNavigationBar: OperatorBottomNav(currentIndex: 0)),
      ),
    );

    for (final texto in ['Salidas', 'Abordaje', 'Reportes', 'Perfil']) {
      expect(find.text(texto), findsOneWidget);
    }
  });

  testWidgets('Mis salidas saluda y ofrece iniciar el recorrido', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: OperadorSalidasPage(
          repository: FakeOperatorRepository(),
          user: FakeAuthRepository.demoEstudiante,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Buen día, Ana'), findsOneWidget);
    expect(find.text('R01 · Programada'), findsOneWidget);
    expect(find.text('Iniciar recorrido'), findsOneWidget);
  });

  testWidgets('sin salidas muestra el estado vacío', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: OperadorSalidasPage(
          repository: FakeOperatorRepository(salidas: []),
          user: FakeAuthRepository.demoEstudiante,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sin salidas asignadas'), findsOneWidget);
  });

  testWidgets('la lista de abordaje muestra contadores y filtra', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ListaAbordajePage(
          salidaId: 'SAL-001',
          repository: FakeOperatorRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mariana L.'), findsOneWidget);
    expect(find.text('Sofía L.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'sofía');
    await tester.pumpAndSettle();

    expect(find.text('Mariana L.'), findsNothing);
    expect(find.textContaining('Mostrando 1 de 2'), findsOneWidget);
  });

  testWidgets('el perfil confirma antes de cerrar sesión', (tester) async {
    tester.view.physicalSize = const Size(1080, 3200);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    var cerro = false;
    await tester.pumpWidget(
      MaterialApp(
        home: OperadorPerfilPage(
          repository: FakeOperatorRepository(),
          onSignOut: () => cerro = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Carlos Méndez Ruiz'), findsOneWidget);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Cerrar sesión'));
    await tester.pumpAndSettle();
    expect(cerro, isFalse);

    await tester.tap(find.widgetWithText(FilledButton, 'Cerrar sesión'));
    await tester.pumpAndSettle();
    expect(cerro, isTrue);
  });
}
