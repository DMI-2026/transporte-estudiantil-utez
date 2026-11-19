import '../../../../core/errors/app_failure.dart';
import '../../domain/entities/reserva.dart';
import '../../domain/entities/salida.dart';
import '../../domain/repositories/reservations_repository.dart';
import '../datasources/reservations_datasource.dart';

class ReservationsRepositoryImpl implements ReservationsRepository {
  ReservationsRepositoryImpl(this.source);

  final ReservationsDataSource source;

  @override
  Future<ReservasResult<List<Salida>>> fetchSalidas() =>
      _guard(source.fetchSalidas);

  @override
  Future<ReservasResult<List<Reserva>>> fetchMisReservas() =>
      _guard(source.fetchMisReservas);

  @override
  Future<ReservasResult<Reserva>> fetchReserva(String folio) =>
      _guard(() => source.fetchReserva(folio));

  @override
  Future<ReservasResult<Reserva>> reservar({
    required String salidaId,
    required String parada,
  }) => _guard(() => source.reservar(salidaId: salidaId, parada: parada));

  @override
  Future<ReservasResult<Reserva>> cancelar({
    required String folio,
    required String motivo,
  }) => _guard(() => source.cancelar(folio: folio, motivo: motivo));

  Future<ReservasResult<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return (value: await action(), failure: null);
    } on AppFailure catch (e) {
      return (value: null, failure: e);
    } catch (_) {
      return (value: null, failure: const GenericFailure());
    }
  }
}
