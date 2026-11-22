import '../../../../core/errors/app_failure.dart';
import '../../../incidents/domain/entities/reporte.dart';
import '../../domain/entities/pasajero.dart';
import '../../domain/entities/perfil_operador.dart';
import '../../domain/entities/salida_operador.dart';
import '../../domain/repositories/operator_repository.dart';
import '../datasources/operator_datasource.dart';

class OperatorRepositoryImpl implements OperatorRepository {
  OperatorRepositoryImpl(this.source);

  final OperatorDataSource source;

  @override
  Future<OperatorResult<List<SalidaOperador>>> fetchSalidas() =>
      _guard(source.fetchSalidas);

  @override
  Future<OperatorResult<SalidaOperador>> fetchSalida(String id) =>
      _guard(() => source.fetchSalida(id));

  @override
  Future<OperatorResult<SalidaOperador>> fetchSalidaActiva() =>
      _guard(source.fetchSalidaActiva);

  @override
  Future<OperatorResult<SalidaOperador>> iniciarRecorrido(String id) =>
      _guard(() => source.iniciarRecorrido(id));

  @override
  Future<OperatorResult<SalidaOperador>> marcarLlegada(String id) =>
      _guard(() => source.marcarLlegada(id));

  @override
  Future<OperatorResult<SalidaOperador>> finalizarRecorrido(String id) =>
      _guard(() => source.finalizarRecorrido(id));

  @override
  Future<OperatorResult<List<Pasajero>>> fetchPasajeros(String salidaId) =>
      _guard(() => source.fetchPasajeros(salidaId));

  @override
  Future<OperatorResult<LecturaQr>> leerQrSimulado(String salidaId) =>
      _guard(() => source.leerQrSimulado(salidaId));

  @override
  Future<OperatorResult<List<Reporte>>> fetchMisReportes() =>
      _guard(source.fetchMisReportes);

  @override
  Future<OperatorResult<Reporte>> enviarReporte(NuevoReporte reporte) =>
      _guard(() => source.enviarReporte(reporte));

  @override
  Future<OperatorResult<PerfilOperador>> fetchPerfil() =>
      _guard(source.fetchPerfil);

  Future<OperatorResult<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return (value: await action(), failure: null);
    } on AppFailure catch (e) {
      return (value: null, failure: e);
    } catch (_) {
      return (value: null, failure: const GenericFailure());
    }
  }
}
