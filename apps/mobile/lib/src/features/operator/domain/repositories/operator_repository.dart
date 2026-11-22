import '../../../../core/errors/app_failure.dart';
import '../../../incidents/domain/entities/reporte.dart';
import '../entities/pasajero.dart';
import '../entities/perfil_operador.dart';
import '../entities/salida_operador.dart';

typedef OperatorResult<T> = ({T? value, AppFailure? failure});

/// Contrato del módulo operador. Hoy lo implementa una fuente de
/// demostración; Firestore y las Cloud Functions de QR (D-06) lo
/// reemplazan en `injection.dart` (issues #83 a #87).
abstract interface class OperatorRepository {
  Future<OperatorResult<List<SalidaOperador>>> fetchSalidas();

  Future<OperatorResult<SalidaOperador>> fetchSalida(String id);

  /// Salida en curso o, si no hay, la siguiente programada.
  Future<OperatorResult<SalidaOperador>> fetchSalidaActiva();

  Future<OperatorResult<SalidaOperador>> iniciarRecorrido(String id);

  Future<OperatorResult<SalidaOperador>> marcarLlegada(String id);

  Future<OperatorResult<SalidaOperador>> finalizarRecorrido(String id);

  Future<OperatorResult<List<Pasajero>>> fetchPasajeros(String salidaId);

  /// Lectura simulada del siguiente QR (sin cámara en esta versión).
  Future<OperatorResult<LecturaQr>> leerQrSimulado(String salidaId);

  Future<OperatorResult<List<Reporte>>> fetchMisReportes();

  Future<OperatorResult<Reporte>> enviarReporte(NuevoReporte reporte);

  Future<OperatorResult<PerfilOperador>> fetchPerfil();
}
