import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/core/errors/app_failure.dart';
import 'package:transporte_estudiantil/src/core/widgets/ui_state.dart';
import 'package:transporte_estudiantil/src/features/incidents/presentation/reportar/reportar_incidente_cubit.dart';

import '../../../fakes/fake_incidents_repository.dart';
import '../../../fakes/fake_reservations_repository.dart';

void main() {
  test('carga las salidas de tus reservas como opciones', () async {
    final cubit = ReportarIncidenteCubit(
      FakeIncidentsRepository(),
      FakeReservationsRepository(),
    );

    await cubit.load();

    expect(
      (cubit.state.referencias as UiData<List<String>>).value,
      ['SAL-001 · Combi 01'],
    );
  });

  test('no envía si el formulario es inválido y muestra los errores', () async {
    final incidents = FakeIncidentsRepository();
    final cubit = ReportarIncidenteCubit(
      incidents,
      FakeReservationsRepository(),
    );
    await cubit.load();

    await cubit.enviar();

    expect(incidents.ultimoEnviado, isNull);
    expect(cubit.state.errorTipo, isNotNull);
    expect(cubit.state.errorReferencia, isNotNull);
    expect(cubit.state.errorDescripcion, isNotNull);
  });

  test('envía el reporte con la evidencia de demostración', () async {
    final incidents = FakeIncidentsRepository();
    final cubit = ReportarIncidenteCubit(
      incidents,
      FakeReservationsRepository(),
      referenciaInicial: 'SAL-001 · Combi 01',
    );
    await cubit.load();
    cubit
      ..elegirTipo('Asiento dañado')
      ..escribirDescripcion('  El respaldo del asiento está flojo.  ')
      ..adjuntarEvidenciaDemo();

    await cubit.enviar();

    expect(cubit.state.enviado?.folio, 'INC-100');
    expect(incidents.ultimoEnviado?.descripcion, 'El respaldo del asiento está flojo.');
    expect(incidents.ultimoEnviado?.evidencia, 'evidencia_demo.jpg');
  });

  test('si falla el envío muestra el mensaje', () async {
    final cubit = ReportarIncidenteCubit(
      FakeIncidentsRepository(sendFailure: const NetworkFailure()),
      FakeReservationsRepository(),
      referenciaInicial: 'SAL-001 · Combi 01',
    );
    await cubit.load();
    cubit
      ..elegirTipo('Otro')
      ..escribirDescripcion('Algo pasó durante el viaje.');

    await cubit.enviar();

    expect(cubit.state.enviado, isNull);
    expect(cubit.state.error, contains('conexión'));
  });
}
