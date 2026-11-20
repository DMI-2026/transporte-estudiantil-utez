import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/reporte.dart';

/// Traduce documentos `reportes` al modelo de UI.
abstract final class ReporteFirestoreMapper {
  static EstadoReporte? estadoDesde(String? raw) => switch (raw) {
        'abierto' => EstadoReporte.abierto,
        'enRevision' => EstadoReporte.enRevision,
        'cerrado' => EstadoReporte.cerrado,
        _ => null,
      };

  static DateTime? fechaDesde(Object? raw) {
    if (raw is Timestamp) {
      return raw.toDate();
    }
    if (raw is DateTime) {
      return raw;
    }
    return null;
  }

  /// Extrae `salidaId` de la referencia de UI (`salidaId · unidad`).
  static String? salidaIdDesdeReferencia(String referencia) {
    final parte = referencia.split('·').first.trim();
    return parte.isEmpty ? null : parte;
  }

  static Reporte? desde({
    required String id,
    required Map<String, dynamic> data,
  }) {
    final estado = estadoDesde(data['estado'] as String?);
    final tipo = data['tipo'];
    final descripcion = data['descripcion'];
    final fecha = fechaDesde(data['creadoEn']);
    if (estado == null ||
        tipo is! String ||
        tipo.trim().isEmpty ||
        descripcion is! String ||
        descripcion.trim().isEmpty ||
        fecha == null) {
      return null;
    }
    final salidaId = data['salidaId'];
    final fotoUrl = data['fotoUrl'];
    final actualizacion = data['actualizacion'];
    return Reporte(
      folio: id,
      tipo: tipo.trim(),
      descripcion: descripcion.trim(),
      referencia: salidaId is String && salidaId.isNotEmpty ? salidaId : '—',
      fecha: fecha,
      estado: estado,
      actualizacion: actualizacion is String ? actualizacion : null,
      evidencia: fotoUrl is String && fotoUrl.isNotEmpty ? fotoUrl : null,
    );
  }
}
