import '../../../../core/errors/app_failure.dart';
import '../../domain/entities/reporte.dart';
import '../../domain/repositories/incidents_repository.dart';
import '../datasources/incidents_datasource.dart';

class IncidentsRepositoryImpl implements IncidentsRepository {
  IncidentsRepositoryImpl(this.source);

  final IncidentsDataSource source;

  @override
  Future<IncidentsResult<List<Reporte>>> fetchMisReportes() =>
      _guard(source.fetchMisReportes);

  @override
  Future<IncidentsResult<Reporte>> enviar(NuevoReporte reporte) =>
      _guard(() => source.enviar(reporte));

  Future<IncidentsResult<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return (value: await action(), failure: null);
    } on AppFailure catch (e) {
      return (value: null, failure: e);
    } catch (_) {
      return (value: null, failure: const GenericFailure());
    }
  }
}
