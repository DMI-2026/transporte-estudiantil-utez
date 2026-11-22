import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/core/errors/app_failure.dart';
import 'package:transporte_estudiantil/src/core/widgets/ui_state.dart';
import 'package:transporte_estudiantil/src/features/operator/domain/entities/salida_operador.dart';
import 'package:transporte_estudiantil/src/features/operator/presentation/salidas/operador_salidas_cubit.dart';

import '../../../fakes/fake_operator_repository.dart';

void main() {
  test('carga salidas o muestra vacío', () async {
    final vacio = OperadorSalidasCubit(FakeOperatorRepository(salidas: []));
    await vacio.load();
    expect(vacio.state.salidas, isA<UiEmpty>());

    final con = OperadorSalidasCubit(FakeOperatorRepository());
    await con.load();
    expect(con.state.salidas, isA<UiData<List<SalidaOperador>>>());
  });

  test('error de red muestra reintentar', () async {
    final cubit = OperadorSalidasCubit(
      FakeOperatorRepository(failure: const NetworkFailure()),
    );

    await cubit.load();

    expect((cubit.state.salidas as UiError).onRetry, isNotNull);
  });

  test('iniciar deja la salida en curso para navegar al recorrido', () async {
    final cubit = OperadorSalidasCubit(FakeOperatorRepository());
    await cubit.load();

    await cubit.iniciar(FixturesOperador.salida);

    expect(cubit.state.iniciada?.estado, EstadoSalida.enCurso);
    expect(cubit.state.iniciando, isFalse);
  });

  test('si no se puede iniciar muestra el motivo', () async {
    final cubit = OperadorSalidasCubit(
      FakeOperatorRepository(
        actionFailure: const GenericFailure('Este recorrido ya se inició.'),
      ),
    );
    await cubit.load();

    await cubit.iniciar(FixturesOperador.salida);

    expect(cubit.state.iniciada, isNull);
    expect(cubit.state.error, 'Este recorrido ya se inició.');
  });
}
