import 'package:equatable/equatable.dart';

class ContactoEmergencia extends Equatable {
  const ContactoEmergencia({
    required this.nombre,
    required this.parentesco,
    required this.telefono,
  });

  final String nombre;
  final String parentesco;
  final String telefono;

  @override
  List<Object?> get props => [nombre, parentesco, telefono];
}

enum EstadoCredencial { pendiente, aprobada, rechazada }

extension EstadoCredencialTexto on EstadoCredencial {
  String get texto => switch (this) {
    EstadoCredencial.pendiente => 'En revisión',
    EstadoCredencial.aprobada => 'Aprobada por administración',
    EstadoCredencial.rechazada => 'Rechazada',
  };
}

/// Datos del estudiante que complementan `usuarios/{uid}` (nombre y correo
/// vienen de la sesión de `auth`).
class PerfilEstudiante extends Equatable {
  const PerfilEstudiante({
    required this.matricula,
    required this.carrera,
    required this.telefono,
    required this.credencial,
    this.credencialAprobadaEl,
    this.contactoEmergencia,
  });

  final String matricula;
  final String carrera;
  final String telefono;
  final EstadoCredencial credencial;
  final DateTime? credencialAprobadaEl;
  final ContactoEmergencia? contactoEmergencia;

  PerfilEstudiante copyWith({
    String? telefono,
    ContactoEmergencia? contactoEmergencia,
  }) => PerfilEstudiante(
    matricula: matricula,
    carrera: carrera,
    telefono: telefono ?? this.telefono,
    credencial: credencial,
    credencialAprobadaEl: credencialAprobadaEl,
    contactoEmergencia: contactoEmergencia ?? this.contactoEmergencia,
  );

  @override
  List<Object?> get props => [
    matricula,
    carrera,
    telefono,
    credencial,
    credencialAprobadaEl,
    contactoEmergencia,
  ];
}

class PreferenciasNotificacion extends Equatable {
  const PreferenciasNotificacion({
    this.recordatoriosSalida = true,
    this.estadoReportes = true,
    this.avisosGenerales = false,
  });

  final bool recordatoriosSalida;
  final bool estadoReportes;
  final bool avisosGenerales;

  PreferenciasNotificacion copyWith({
    bool? recordatoriosSalida,
    bool? estadoReportes,
    bool? avisosGenerales,
  }) => PreferenciasNotificacion(
    recordatoriosSalida: recordatoriosSalida ?? this.recordatoriosSalida,
    estadoReportes: estadoReportes ?? this.estadoReportes,
    avisosGenerales: avisosGenerales ?? this.avisosGenerales,
  );

  @override
  List<Object?> get props => [
    recordatoriosSalida,
    estadoReportes,
    avisosGenerales,
  ];
}
