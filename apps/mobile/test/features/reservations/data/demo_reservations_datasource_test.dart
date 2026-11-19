import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/core/errors/app_failure.dart';
import 'package:transporte_estudiantil/src/features/reservations/data/datasources/demo_reservations_datasource.dart';
import 'package:transporte_estudiantil/src/features/reservations/data/repositories/reservations_repository_impl.dart';
import 'package:transporte_estudiantil/src/features/reservations/domain/entities/reserva.dart';

void main() {
  late DemoReservationsDataSource source;
  late ReservationsRepositoryImpl repo;

  setUp(() {
    source = DemoReservationsDataSource(latencia: Duration.zero);
    repo = ReservationsRepositoryImpl(source);
  });

  test('reservar descuenta un lugar y deja la reserva activa', () async {
    final antes = (await repo.fetchSalidas()).value!
        .firstWhere((s) => s.id == 'SAL-002');

    final result = await repo.reservar(salidaId: 'SAL-002', parada: 'Las Palmas');

    expect(result.failure, isNull);
    expect(result.value!.estado, EstadoReserva.reservada);
    expect(result.value!.parada.nombre, 'Las Palmas');
    expect(result.value!.salida.disponibles, antes.disponibles - 1);
  });

  test('no permite reservar una salida sin lugares', () async {
    final result = await repo.reservar(salidaId: 'SAL-003', parada: 'Jiutepec');

    expect(result.value, isNull);
    expect(result.failure, isA<GenericFailure>());
    expect(result.failure!.userMessage, contains('Ya no hay lugares'));
  });

  test('no permite reservar dos veces la misma salida', () async {
    final result = await repo.reservar(salidaId: 'SAL-001', parada: 'Centro');

    expect(result.failure!.userMessage, contains('Ya tienes una reserva'));
  });

  test('cancelar reembolsa el pago y libera el lugar', () async {
    final result = await repo.cancelar(folio: 'UTEZ-1048', motivo: 'Otro motivo');

    expect(result.value!.estado, EstadoReserva.cancelada);
    expect(result.value!.pago.estado, EstadoPago.reembolsado);
    expect(result.value!.salida.reservados, 10);

    final otraVez = await repo.cancelar(folio: 'UTEZ-1048', motivo: 'Otro');
    expect(otraVez.failure, isNotNull);
  });

  test('un folio inexistente devuelve un mensaje de usuario', () async {
    final result = await repo.fetchReserva('NO-EXISTE');

    expect(result.failure!.userMessage, 'No encontramos esa reserva.');
  });
}
