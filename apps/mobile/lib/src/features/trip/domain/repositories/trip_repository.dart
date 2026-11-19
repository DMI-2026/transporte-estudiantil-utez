import '../../../../core/errors/app_failure.dart';
import '../entities/viaje_en_curso.dart';

typedef TripResult<T> = ({T? value, AppFailure? failure});

abstract interface class TripRepository {
  Future<TripResult<ViajeEnCurso>> fetchViaje(String folio);
}
