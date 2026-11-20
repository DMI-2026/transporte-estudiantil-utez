import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/perfil_estudiante.dart';

/// Traduce `usuarios/{uid}` al modelo de UI de perfil.
///
/// No incluye `rol`, `estadoVerificacion`, `email` ni `creadoEn` en writes
/// de contacto/preferencias (el cliente no puede alterarlos).
abstract final class PerfilFirestoreMapper {
  static EstadoCredencial? credencialDesde(String? raw) => switch (raw) {
        'pendiente' => EstadoCredencial.pendiente,
        'aprobada' => EstadoCredencial.aprobada,
        'rechazada' => EstadoCredencial.rechazada,
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

  static ContactoEmergencia? contactoDesde(Object? raw) {
    if (raw is! Map) {
      return null;
    }
    final map = Map<String, dynamic>.from(raw);
    final nombre = map['nombre'];
    final parentesco = map['parentesco'];
    final telefono = map['telefono'];
    if (nombre is! String ||
        parentesco is! String ||
        telefono is! String ||
        nombre.trim().isEmpty ||
        parentesco.trim().isEmpty ||
        telefono.trim().isEmpty) {
      return null;
    }
    return ContactoEmergencia(
      nombre: nombre.trim(),
      parentesco: parentesco.trim(),
      telefono: telefono.trim(),
    );
  }

  static Map<String, String> contactoAFirestore(ContactoEmergencia contacto) =>
      {
        'nombre': contacto.nombre,
        'parentesco': contacto.parentesco,
        'telefono': contacto.telefono,
      };

  static PreferenciasNotificacion preferenciasDesde(Object? raw) {
    if (raw is! Map) {
      return const PreferenciasNotificacion();
    }
    final map = Map<String, dynamic>.from(raw);
    return PreferenciasNotificacion(
      recordatoriosSalida: map['recordatoriosSalida'] as bool? ?? true,
      estadoReportes: map['estadoReportes'] as bool? ?? true,
      avisosGenerales: map['avisosGenerales'] as bool? ?? false,
    );
  }

  static Map<String, bool> preferenciasAFirestore(
    PreferenciasNotificacion prefs,
  ) =>
      {
        'recordatoriosSalida': prefs.recordatoriosSalida,
        'estadoReportes': prefs.estadoReportes,
        'avisosGenerales': prefs.avisosGenerales,
      };

  /// Arma [PerfilEstudiante] desde el documento. Campos faltantes usan
  /// valores seguros para no tumbar la UI.
  static PerfilEstudiante? perfilDesde(Map<String, dynamic> data) {
    final credencial = credencialDesde(data['estadoVerificacion'] as String?);
    if (credencial == null) {
      return null;
    }
    final matricula = data['matricula'];
    final carrera = data['carrera'];
    final telefono = data['telefono'];
    return PerfilEstudiante(
      matricula: matricula is String ? matricula : '',
      carrera: carrera is String ? carrera : '',
      telefono: telefono is String ? telefono : '',
      credencial: credencial,
      credencialAprobadaEl: fechaDesde(data['credencialAprobadaEl']),
      contactoEmergencia: contactoDesde(data['contactoEmergencia']),
    );
  }
}
