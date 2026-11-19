import 'package:equatable/equatable.dart';

enum EstadoReporte { abierto, enRevision, cerrado }

extension EstadoReporteTexto on EstadoReporte {
  String get texto => switch (this) {
    EstadoReporte.abierto => 'Abierto',
    EstadoReporte.enRevision => 'En revisión',
    EstadoReporte.cerrado => 'Cerrado',
  };
}

/// Tipos de incidente del Figma (pantalla 12).
abstract final class TiposIncidente {
  static const todos = [
    'Retraso de la unidad',
    'Conducción insegura',
    'Asiento dañado',
    'Limpieza de la unidad',
    'Objeto olvidado',
    'Otro',
  ];
}

class Reporte extends Equatable {
  const Reporte({
    required this.folio,
    required this.tipo,
    required this.descripcion,
    required this.referencia,
    required this.fecha,
    required this.estado,
    this.actualizacion,
    this.evidencia,
  });

  final String folio;
  final String tipo;
  final String descripcion;

  /// Salida o ruta relacionada (por ejemplo `SAL-001 · Combi 01`).
  final String referencia;
  final DateTime fecha;
  final EstadoReporte estado;
  final String? actualizacion;
  final String? evidencia;

  @override
  List<Object?> get props => [folio, tipo, descripcion, referencia, estado];
}

/// Datos capturados en el formulario antes de enviarlo.
class NuevoReporte extends Equatable {
  const NuevoReporte({
    required this.tipo,
    required this.referencia,
    required this.descripcion,
    this.evidencia,
  });

  final String tipo;
  final String referencia;
  final String descripcion;
  final String? evidencia;

  @override
  List<Object?> get props => [tipo, referencia, descripcion, evidencia];
}
