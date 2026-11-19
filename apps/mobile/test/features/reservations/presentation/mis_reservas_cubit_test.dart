import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/core/errors/app_failure.dart';
import 'package:transporte_estudiantil/src/core/widgets/ui_state.dart';
import 'package:transporte_estudiantil/src/features/reservations/presentation/mis_reservas/mis_reservas_cubit.dart';

import '../../../fakes/fake_reservations_repository.dart';

void main() {
  test('separa próximas y anteriores', () async {
    final cubit = MisReservasCubit(
      FakeReservationsRepository(
        reservas: [
          FixturesEstudiante.activa,
          FixturesEstudiante.abordada,
          FixturesEstudiante.cancelada,
        ],
      ),
    );

    await cubit.load();

    final data = (cubit.state as UiData<MisReservas>).value;
    expect(data.proximas.map((r) => r.folio), ['UTEZ-1048']);
    expect(data.anteriores.map((r) => r.folio), ['UTEZ-1031', 'UTEZ-1022']);
  });

  test('sin reservas muestra estado vacío', () async {
    final cubit = MisReservasCubit(FakeReservationsRepository(reservas: []));

    await cubit.load();

    expect(cubit.state, isA<UiEmpty<MisReservas>>());
  });

  test('error muestra mensaje de usuario', () async {
    final cubit = MisReservasCubit(
      FakeReservationsRepository(failure: const NetworkFailure()),
    );

    await cubit.load();

    expect(
      (cubit.state as UiError).message,
      'No se pudo completar la operación. Revisa tu conexión.',
    );
  });
}
