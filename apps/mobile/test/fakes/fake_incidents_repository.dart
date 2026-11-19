import 'package:transporte_estudiantil/src/core/errors/app_failure.dart';
import 'package:transporte_estudiantil/src/features/incidents/domain/entities/reporte.dart';
import 'package:transporte_estudiantil/src/features/incidents/domain/repositories/incidents_repository.dart';

class FakeIncidentsRepository implements IncidentsRepository {
  FakeIncidentsRepository({List<Reporte>? reportes, this.failure, this.sendFailure})
    : reportes = reportes ?? [];

  List<Reporte> reportes;
  AppFailure? failure;
  AppFailure? sendFailure;
  NuevoReporte? ultimoEnviado;

  @override
  Future<IncidentsResult<List<Reporte>>> fetchMisReportes() async =>
      failure != null ? (value: null, failure: failure) : (value: reportes, failure: null);

  @override
  Future<IncidentsResult<Reporte>> enviar(NuevoReporte reporte) async {
    if (sendFailure != null) return (value: null, failure: sendFailure);
    ultimoEnviado = reporte;
    final creado = Reporte(
      folio: 'INC-100',
      tipo: reporte.tipo,
      descripcion: reporte.descripcion,
      referencia: reporte.referencia,
      fecha: DateTime(2026, 10, 26, 7),
      estado: EstadoReporte.abierto,
      evidencia: reporte.evidencia,
    );
    reportes = [creado, ...reportes];
    return (value: creado, failure: null);
  }
}
