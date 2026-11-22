import '../../../incidents/domain/entities/reporte.dart';
import '../../domain/entities/pasajero.dart';
import '../../domain/entities/perfil_operador.dart';
import '../../domain/entities/salida_operador.dart';

/// Fuente de datos del operador. Lanza [AppFailure] con mensajes de usuario.
abstract interface class OperatorDataSource {
  Future<List<SalidaOperador>> fetchSalidas();

  Future<SalidaOperador> fetchSalida(String id);

  Future<SalidaOperador> fetchSalidaActiva();

  Future<SalidaOperador> iniciarRecorrido(String id);

  Future<SalidaOperador> marcarLlegada(String id);

  Future<SalidaOperador> finalizarRecorrido(String id);

  Future<List<Pasajero>> fetchPasajeros(String salidaId);

  Future<LecturaQr> leerQrSimulado(String salidaId);

  Future<List<Reporte>> fetchMisReportes();

  Future<Reporte> enviarReporte(NuevoReporte reporte);

  Future<PerfilOperador> fetchPerfil();
}
