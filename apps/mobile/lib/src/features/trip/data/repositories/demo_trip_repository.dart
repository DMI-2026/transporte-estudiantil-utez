import '../../../../core/errors/app_failure.dart';
import '../../../reservations/data/datasources/reservations_datasource.dart';
import '../../domain/entities/viaje_en_curso.dart';
import '../../domain/repositories/trip_repository.dart';

/// Viaje de DEMOSTRACIÓN: toma la reserva real de la fuente de reservas y
/// coloca la unidad en la segunda parada. Sin GPS ni ETA reales.
class DemoTripRepository implements TripRepository {
  DemoTripRepository(this.reservas);

  final ReservationsDataSource reservas;

  @override
  Future<TripResult<ViajeEnCurso>> fetchViaje(String folio) async {
    try {
      final reserva = await reservas.fetchReserva(folio);
      if (!reserva.qrValido) {
        return (
          value: null,
          failure: const GenericFailure(
            'Este viaje no está en curso. Revisa el estado de tu reserva.',
          ),
        );
      }
      final indice = reserva.salida.paradas.length > 2 ? 1 : 0;
      return (
        value: ViajeEnCurso(
          reserva: reserva,
          indiceParadaActual: indice,
          minutosParaLlegar: 18,
          actualizadoA: '06:53',
        ),
        failure: null,
      );
    } on AppFailure catch (e) {
      return (value: null, failure: e);
    } catch (_) {
      return (value: null, failure: const GenericFailure());
    }
  }
}
