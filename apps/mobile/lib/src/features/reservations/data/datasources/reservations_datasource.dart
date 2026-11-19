import '../../domain/entities/reserva.dart';
import '../../domain/entities/salida.dart';

/// Fuente de datos de reservas. Lanza [AppFailure] con mensajes de usuario.
abstract interface class ReservationsDataSource {
  Future<List<Salida>> fetchSalidas();

  Future<List<Reserva>> fetchMisReservas();

  Future<Reserva> fetchReserva(String folio);

  Future<Reserva> reservar({required String salidaId, required String parada});

  Future<Reserva> cancelar({required String folio, required String motivo});
}
