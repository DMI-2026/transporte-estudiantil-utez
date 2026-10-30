// Modelos compartidos Operación (Reservas, Salidas, Rutas, Paradas, Reportes)
// Sincronizar con functions/src/models/operacion.ts

enum ReservaEstado { pendientePago, reservada, cancelada, abordada }
enum SalidaEstado { programada, enCurso, finalizada, cancelada }
enum ReporteEstado { abierto, enRevision, cerrado }
enum ReportePrioridad { baja, media, alta, critica }
enum ReporteTipo { incidencia, sugerencia, felicitacion, otro }

/// Reserva de asiento (documento en colección 'reservas', id = {salidaId}_{uid})
class ReservaDocument {
  final String uid;
  final String salidaId;
  final String usuarioId;
  final String usuarioNombre;
  final int asiento;
  final ReservaEstado estado;
  final double monto;
  final String? metodoPago;
  final DateTime creadaEn;
  final DateTime? pagadaEn;
  final DateTime? abordadaEn;
  final DateTime? canceladaEn;
  final String? canceladaPor; // 'usuario' | 'operador' | 'admin' | 'sistema'
  final String? motivoCancelacion;

  const ReservaDocument({
    required this.uid,
    required this.salidaId,
    required this.usuarioId,
    required this.usuarioNombre,
    required this.asiento,
    required this.estado,
    required this.monto,
    this.metodoPago,
    required this.creadaEn,
    this.pagadaEn,
    this.abordadaEn,
    this.canceladaEn,
    this.canceladaPor,
    this.motivoCancelacion,
  });

  /// Genera el ID compuesto: {salidaId}_{usuarioId}
  static String generateId(String salidaId, String usuarioId) => '${salidaId}_$usuarioId';
}

/// Salida programada (documento en colección 'salidas')
class SalidaDocument {
  final String rutaId;
  final DateTime horaSalida;
  final int cupoTotal;
  final int cuposDisponibles;
  final String operadorId;
  final String vehiculoId;
  final SalidaEstado estado;
  final bool qrGenerado;
  final DateTime? qrGeneradoEn;
  final int abordados;
  final double? latitud;
  final double? longitud;
  final double? velocidad;
  final double? rumbo;
  final DateTime? ubicacionActualizadaEn;
  final DateTime? iniciadaEn;
  final DateTime? finalizadaEn;
  final DateTime creadaEn;
  final String creadaPor;

  const SalidaDocument({
    required this.rutaId,
    required this.horaSalida,
    required this.cupoTotal,
    required this.cuposDisponibles,
    required this.operadorId,
    required this.vehiculoId,
    required this.estado,
    required this.qrGenerado,
    this.qrGeneradoEn,
    required this.abordados,
    this.latitud,
    this.longitud,
    this.velocidad,
    this.rumbo,
    this.ubicacionActualizadaEn,
    this.iniciadaEn,
    this.finalizadaEn,
    required this.creadaEn,
    required this.creadaPor,
  });
}

/// Ruta (documento en colección 'rutas')
class RutaDocument {
  final String nombre;
  final String descripcion;
  final List<LatLng> polilinea; // Puntos de la ruta para mapa
  final List<ParadaReference> paradas; // Ordenadas
  final bool activa;
  final DateTime creadaEn;

  const RutaDocument({
    required this.nombre,
    required this.descripcion,
    required this.polilinea,
    required this.paradas,
    required this.activa,
    required this.creadaEn,
  });
}

/// Referencia a parada dentro de una ruta
class ParadaReference {
  final String paradaId;
  final int orden;
  final int tiempoEstimadoMin; // Minutos desde salida

  const ParadaReference({
    required this.paradaId,
    required this.orden,
    required this.tiempoEstimadoMin,
  });
}

/// Parada (documento en colección 'paradas')
class ParadaDocument {
  final String nombre;
  final String direccion;
  final LatLng ubicacion;
  final List<String> rutaIds; // Qué rutas pasan por aquí
  final bool activa;

  const ParadaDocument({
    required this.nombre,
    required this.direccion,
    required this.ubicacion,
    required this.rutaIds,
    required this.activa,
  });
}

/// Coordenadas lat/lng (equivalente a GeoPoint)
class LatLng {
  final double latitude;
  final double longitude;

  const LatLng({required this.latitude, required this.longitude});

  Map<String, dynamic> toJson() => {'latitude': latitude, 'longitude': longitude};

  factory LatLng.fromJson(Map<String, dynamic> json) => LatLng(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
      );
}

/// Vehículo (documento en colección 'vehiculos')
class VehiculoDocument {
  final String placa;
  final String modelo;
  final int capacidad;
  final String? operadorId; // Asignado actualmente
  final bool activo;

  const VehiculoDocument({
    required this.placa,
    required this.modelo,
    required this.capacidad,
    this.operadorId,
    required this.activo,
  });
}

/// Reporte/Incidencia (documento en colección 'reportes')
class ReporteDocument {
  final String uid;
  final ReporteTipo tipo;
  final String titulo;
  final String descripcion;
  final String usuarioId;
  final String usuarioNombre;
  final String? salidaId;
  final String? rutaId;
  final String? paradaId;
  final List<String> fotosUrls;
  final ReporteEstado estado;
  final ReportePrioridad prioridad;
  final DateTime creadaEn;
  final DateTime actualizadaEn;
  final String? asignadoA;
  final DateTime? resueltoEn;
  final String? resolucion;

  const ReporteDocument({
    required this.uid,
    required this.tipo,
    required this.titulo,
    required this.descripcion,
    required this.usuarioId,
    required this.usuarioNombre,
    this.salidaId,
    this.rutaId,
    this.paradaId,
    required this.fotosUrls,
    required this.estado,
    required this.prioridad,
    required this.creadaEn,
    required this.actualizadaEn,
    this.asignadoA,
    this.resueltoEn,
    this.resolucion,
  });
}