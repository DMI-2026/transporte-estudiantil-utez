import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/core/errors/app_failure.dart';
import 'package:transporte_estudiantil/src/core/widgets/ui_state.dart';
import 'package:transporte_estudiantil/src/features/home/presentation/home_cubit.dart';
import 'package:transporte_estudiantil/src/features/reservations/domain/entities/reserva.dart';

import '../../../fakes/fake_reservations_repository.dart';

void main() {
  test('elige la reserva activa más cercana', () async {
    final cubit = HomeCubit(
      FakeReservationsRepository(
        reservas: [
          FixturesEstudiante.abordada,
          FixturesEstudiante.activa,
        ],
      ),
    );

    await cubit.load();

    final data = (cubit.state.proxima as UiData<Reserva>).value;
    expect(data.folio, FixturesEstudiante.activa.folio);
  });

  test('sin activas muestra vacío', () async {
    final cubit = HomeCubit(
      FakeReservationsRepository(reservas: [FixturesEstudiante.abordada]),
    );

    await cubit.load();

    expect(cubit.state.proxima, isA<UiEmpty<Reserva>>());
  });

  test('error de red se propaga', () async {
    final cubit = HomeCubit(
      FakeReservationsRepository(failure: const NetworkFailure()),
    );

    await cubit.load();

    expect(cubit.state.proxima, isA<UiError<Reserva>>());
  });
}
