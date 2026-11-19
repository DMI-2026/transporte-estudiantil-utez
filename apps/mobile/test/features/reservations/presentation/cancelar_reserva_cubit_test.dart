import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/core/errors/app_failure.dart';
import 'package:transporte_estudiantil/src/features/reservations/domain/entities/reserva.dart';
import 'package:transporte_estudiantil/src/features/reservations/presentation/cancelar/cancelar_reserva_cubit.dart';

import '../../../fakes/fake_reservations_repository.dart';

void main() {
  test('solo cancela con motivo y confirmación', () async {
    final repo = FakeReservationsRepository();
    final cubit = CancelarReservaCubit(repo, 'UTEZ-1048');
    await cubit.load();

    expect(cubit.state.puedeCancelar, isFalse);
    cubit.elegirMotivo('Cambié mi horario');
    expect(cubit.state.puedeCancelar, isFalse);
    cubit.confirmar(true);
    expect(cubit.state.puedeCancelar, isTrue);

    await cubit.cancelar();

    expect(cubit.state.cancelada?.estado, EstadoReserva.cancelada);
    expect(repo.ultimoMotivo, 'Cambié mi horario');
  });

  test('si falla conserva la reserva y muestra el error', () async {
    final repo = FakeReservationsRepository(
      actionFailure: const GenericFailure('Esta reserva ya no se puede cancelar.'),
    );
    final cubit = CancelarReservaCubit(repo, 'UTEZ-1048');
    await cubit.load();
    cubit
      ..elegirMotivo('Otro motivo')
      ..confirmar(true);

    await cubit.cancelar();

    expect(cubit.state.cancelada, isNull);
    expect(cubit.state.error, 'Esta reserva ya no se puede cancelar.');
  });
}
