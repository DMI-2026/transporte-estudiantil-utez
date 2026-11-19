import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/features/incidents/domain/entities/reporte.dart';
import 'package:transporte_estudiantil/src/features/incidents/presentation/mis_reportes/mis_reportes_page.dart';

import '../../../fakes/fake_incidents_repository.dart';

void main() {
  testWidgets('lista los reportes con su estado', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MisReportesPage(
          repository: FakeIncidentsRepository(
            reportes: [
              Reporte(
                folio: 'INC-024',
                tipo: 'Objeto olvidado',
                descripcion: 'Olvidé una sudadera gris.',
                referencia: 'R01 · Combi 01',
                fecha: DateTime(2026, 10, 23, 8, 10),
                estado: EstadoReporte.enRevision,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('INC-024 · Objeto olvidado'), findsOneWidget);
    expect(find.text('En revisión'), findsOneWidget);
  });

  testWidgets('sin reportes muestra el estado vacío', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: MisReportesPage(repository: FakeIncidentsRepository())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sin reportes'), findsOneWidget);
  });
}
