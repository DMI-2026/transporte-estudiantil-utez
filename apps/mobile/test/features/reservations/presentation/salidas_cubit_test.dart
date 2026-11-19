import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/core/errors/app_failure.dart';
import 'package:transporte_estudiantil/src/core/widgets/ui_state.dart';
import 'package:transporte_estudiantil/src/features/reservations/presentation/salidas/salidas_cubit.dart';

import '../../../fakes/fake_reservations_repository.dart';

void main() {
  test('carga salidas y muestra vacío si no hay', () async {
    final repo = FakeReservationsRepository(salidas: []);
    final cubit = SalidasCubit(repo);

    await cubit.load();

    expect(cubit.state.salidas, isA<UiEmpty>());
  });

  test('error de red se muestra con reintentar', () async {
    final repo = FakeReservationsRepository(failure: const NetworkFailure());
    final cubit = SalidasCubit(repo);

    await cubit.load();

    final state = cubit.state.salidas as UiError;
    expect(state.message, contains('conexión'));
    expect(state.onRetry, isNotNull);
  });

  test('no deja seleccionar una salida llena', () async {
    final cubit = SalidasCubit(
      FakeReservationsRepository(salidas: [FixturesEstudiante.salidaLlena]),
    );
    await cubit.load();

    cubit.seleccionar(FixturesEstudiante.salidaLlena);

    expect(cubit.state.seleccionada, isNull);
    expect(cubit.state.puedeReservar, isFalse);
  });

  test('seleccionar elige la primera parada y reservar crea la reserva', () async {
    final repo = FakeReservationsRepository(reservas: []);
    final cubit = SalidasCubit(repo);
    await cubit.load();

    cubit.seleccionar(FixturesEstudiante.salida);
    expect(cubit.state.parada, 'Centro');
    cubit.elegirParada('Las Palmas');
    await cubit.reservar();

    expect(cubit.state.reservaCreada?.parada.nombre, 'Las Palmas');
    expect(cubit.state.reservando, isFalse);
  });

  test('si falla la reserva muestra el mensaje y permite reintentar', () async {
    final repo = FakeReservationsRepository(
      actionFailure: const GenericFailure('Ya no hay lugares en esta salida.'),
    );
    final cubit = SalidasCubit(repo);
    await cubit.load();
    cubit.seleccionar(FixturesEstudiante.salida);

    await cubit.reservar();

    expect(cubit.state.error, 'Ya no hay lugares en esta salida.');
    expect(cubit.state.reservaCreada, isNull);
    expect(cubit.state.puedeReservar, isTrue);
  });
}
