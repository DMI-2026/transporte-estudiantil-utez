import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/core/widgets/ui_state.dart';
import 'package:transporte_estudiantil/src/features/operator/domain/entities/pasajero.dart';
import 'package:transporte_estudiantil/src/features/operator/presentation/abordaje/lista_abordaje_cubit.dart';
import 'package:transporte_estudiantil/src/features/operator/presentation/abordaje/validar_abordaje_cubit.dart';

import '../../../fakes/fake_operator_repository.dart';

void main() {
  test('una lectura válida actualiza el abordaje', () async {
    final cubit = ValidarAbordajeCubit(FakeOperatorRepository());
    await cubit.load();

    await cubit.leer();

    expect(cubit.state.ultimaValida?.pasajero?.folio, 'UTEZ-1050');
    expect(cubit.state.invalida, isNull);
  });

  test('una lectura inválida no registra abordaje y pide abrir el error', () async {
    final repo = FakeOperatorRepository();
    repo.siguienteLectura = LecturaQr.invalida(
      motivo: 'La reserva está cancelada.',
      salida: FixturesOperador.salida,
    );
    final cubit = ValidarAbordajeCubit(repo, salidaId: 'SAL-001');
    await cubit.load();

    await cubit.leer();

    expect(cubit.state.invalida?.motivo, 'La reserva está cancelada.');
    expect(cubit.state.ultimaValida, isNull);
  });

  test('la lista cuenta abordados y filtra por nombre o folio', () async {
    final cubit = ListaAbordajeCubit(FakeOperatorRepository(), 'SAL-001');
    await cubit.load();

    final data = (cubit.state.lista as UiData<ListaAbordaje>).value;
    expect(data.abordaron, 1);
    expect(data.porAbordar, 1);

    cubit.buscar('sofía');
    expect(cubit.state.filtrados(data).single.folio, 'UTEZ-1050');
    cubit.buscar('1048');
    expect(cubit.state.filtrados(data).single.nombre, 'Mariana L.');
    cubit.buscar('nadie');
    expect(cubit.state.filtrados(data), isEmpty);
  });
}
