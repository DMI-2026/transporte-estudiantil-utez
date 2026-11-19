import '../../../../core/errors/app_failure.dart';
import '../entities/reporte.dart';

typedef IncidentsResult<T> = ({T? value, AppFailure? failure});

abstract interface class IncidentsRepository {
  Future<IncidentsResult<List<Reporte>>> fetchMisReportes();

  Future<IncidentsResult<Reporte>> enviar(NuevoReporte reporte);
}
