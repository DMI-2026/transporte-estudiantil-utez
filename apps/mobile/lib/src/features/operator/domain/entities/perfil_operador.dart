import 'package:equatable/equatable.dart';

/// Datos del operador aprobados por administración (pantalla 10).
class PerfilOperador extends Equatable {
  const PerfilOperador({
    required this.nombre,
    required this.numero,
    required this.correo,
    required this.telefono,
    required this.direccion,
    required this.unidad,
    required this.cupoUnidad,
    required this.contactoNombre,
    required this.contactoParentesco,
    required this.contactoTelefono,
    required this.licencia,
    required this.vigenciaLicencia,
    required this.documentos,
    this.aprobado = true,
  });

  final String nombre;
  final String numero;
  final String correo;
  final String telefono;
  final String direccion;
  final String unidad;
  final int cupoUnidad;
  final String contactoNombre;
  final String contactoParentesco;
  final String contactoTelefono;
  final String licencia;
  final DateTime vigenciaLicencia;
  final List<String> documentos;
  final bool aprobado;

  @override
  List<Object?> get props => [numero, correo, telefono, licencia, aprobado];
}
