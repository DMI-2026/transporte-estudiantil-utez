import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/core/errors/app_failure.dart';
import 'package:transporte_estudiantil/src/core/widgets/ui_state.dart';
import 'package:transporte_estudiantil/src/features/incidents/domain/entities/reporte.dart';
import 'package:transporte_estudiantil/src/features/operator/domain/entities/salida_operador.dart';
import 'package:transporte_estudiantil/src/features/operator/presentation/recorrido/finalizar_recorrido_cubit.dart';
import 'package:transporte_estudiantil/src/features/operator/presentation/recorrido/recorrido_cubit.dart';

import '../../../fakes/fake_operator_repository.dart';

void main() {
  final enCurso = FixturesOperador.salida.copyWith(estado: EstadoSalida.enCurso);

  test('marcar llegada avanza a la siguiente parada', () async {
    final cubit = RecorridoCubit(
      FakeOperatorRepository(salidas: [enCurso]),
      'SAL-001',
    );
    await cubit.load();

    await cubit.marcarLlegada();

    final s = (cubit.state.salida as UiData<SalidaOperador>).value;
    expect(s.paradaActual.nombre, 'Las Palmas');
  });

  test('si falla la llegada conserva la parada y muestra el error', () async {
    final repo = FakeOperatorRepository(salidas: [enCurso]);
    final cubit = RecorridoCubit(repo, 'SAL-001');
    await cubit.load();
    repo.actionFailure = const NetworkFailure();

    await cubit.marcarLlegada();

    final s = (cubit.state.salida as UiData<SalidaOperador>).value;
    expect(s.paradaActual.nombre, 'Centro');
    expect(cubit.state.error, contains('conexión'));
  });

  test('el resumen incluye solo reportes abiertos de esta salida', () async {
    Reporte reporte(String folio, String ref, EstadoReporte estado) => Reporte(
      folio: folio,
      tipo: 'Iluminación',
      descripcion: 'La luz no enciende.',
      referencia: ref,
      fecha: DateTime(2026, 10, 26),
      estado: estado,
    );
    final cubit = FinalizarRecorridoCubit(
      FakeOperatorRepository(
        salidas: [enCurso],
        reportes: [
          reporte('INC-026', 'SAL-001 · Combi 01', EstadoReporte.abierto),
          reporte('INC-021', 'SAL-001 · Combi 01', EstadoReporte.cerrado),
          reporte('INC-030', 'SAL-005 · Combi 01', EstadoReporte.abierto),
        ],
      ),
      'SAL-001',
    );

    await cubit.load();

    final r = (cubit.state.resumen as UiData<ResumenRecorrido>).value;
    expect(r.reportesAbiertos.map((e) => e.folio), ['INC-026']);
  });

  test('confirmar finaliza el recorrido', () async {
    final cubit = FinalizarRecorridoCubit(
      FakeOperatorRepository(salidas: [enCurso]),
      'SAL-001',
    );
    await cubit.load();

    await cubit.finalizar();

    expect(cubit.state.finalizada?.estado, EstadoSalida.finalizada);
  });
}
