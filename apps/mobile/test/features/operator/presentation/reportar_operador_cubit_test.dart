import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/features/operator/presentation/reportes/reportar_operador_cubit.dart';

import '../../../fakes/fake_operator_repository.dart';

void main() {
  test('propone la parada actual y valida antes de enviar', () async {
    final repo = FakeOperatorRepository();
    final cubit = ReportarOperadorCubit(repo);
    await cubit.load();

    expect(cubit.state.parada, 'Centro');

    await cubit.enviar();
    expect(repo.ultimoReporte, isNull);
    expect(cubit.state.errorTipo, isNotNull);
    expect(cubit.state.errorDescripcion, isNotNull);
  });

  test('envía el reporte con salida, unidad y parada', () async {
    final repo = FakeOperatorRepository();
    final cubit = ReportarOperadorCubit(repo, salidaId: 'SAL-001');
    await cubit.load();
    cubit
      ..elegirTipo('Iluminación')
      ..elegirParada('Las Palmas')
      ..escribirDescripcion('La luz interior trasera no enciende.');

    await cubit.enviar();

    expect(cubit.state.enviado?.folio, 'INC-200');
    expect(repo.ultimoReporte?.referencia, 'SAL-001 · Combi 01 · Las Palmas');
  });
}
