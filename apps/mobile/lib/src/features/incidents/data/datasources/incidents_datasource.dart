import '../../domain/entities/reporte.dart';

abstract interface class IncidentsDataSource {
  Future<List<Reporte>> fetchMisReportes();

  Future<Reporte> enviar(NuevoReporte reporte);
}
