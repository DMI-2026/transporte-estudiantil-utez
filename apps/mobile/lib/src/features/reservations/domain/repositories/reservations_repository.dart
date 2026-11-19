import '../../../../core/errors/app_failure.dart';
import '../entities/reserva.dart';
import '../entities/salida.dart';

typedef ReservasResult<T> = ({T? value, AppFailure? failure});

/// Contrato de reservas del estudiante. Hoy lo implementa una fuente de
/// demostración en memoria; la versión con Firestore (transacción de cupo)
/// la agrega quien tenga el issue de backend (#9).
abstract interface class ReservationsRepository {
  Future<ReservasResult<List<Salida>>> fetchSalidas();

  Future<ReservasResult<List<Reserva>>> fetchMisReservas();

  Future<ReservasResult<Reserva>> fetchReserva(String folio);

  Future<ReservasResult<Reserva>> reservar({
    required String salidaId,
    required String parada,
  });

  Future<ReservasResult<Reserva>> cancelar({
    required String folio,
    required String motivo,
  });
}
