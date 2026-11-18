import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/core/errors/app_failure.dart';
import 'package:transporte_estudiantil/src/features/routes_map/domain/entities/bus_route.dart';
import 'package:transporte_estudiantil/src/features/routes_map/presentation/routes_page.dart';

import '../../../fakes/fake_routes_repository.dart';

void main() {
  testWidgets('muestra las rutas y el permiso denegado al crear', (
    tester,
  ) async {
    final repo = FakeRoutesRepository(
      routes: const [BusRoute(id: 'r1', nombre: 'UTEZ — Centro')],
      createFailure: const FirestoreFailure(
        'No tienes permiso para leer o guardar estos datos.',
      ),
    );

    await tester.pumpWidget(MaterialApp(home: RoutesPage(repository: repo)));
    await tester.pumpAndSettle();

    expect(find.text('UTEZ — Centro'), findsOneWidget);

    await tester.tap(find.text('Agregar ruta de prueba'));
    await tester.pumpAndSettle();

    expect(find.text('No se guardó la ruta'), findsOneWidget);
    expect(
      find.text('No tienes permiso para leer o guardar estos datos.'),
      findsOneWidget,
    );
    expect(repo.createCalls, 1);
  });
}
