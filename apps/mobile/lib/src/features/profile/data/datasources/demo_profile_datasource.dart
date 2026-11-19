import '../../domain/entities/perfil_estudiante.dart';
import 'profile_datasource.dart';

/// Perfil de DEMOSTRACIÓN en memoria (Figma, pantallas 14 y 15).
/// El backend real (issue #18) reemplaza esta clase en `injection.dart`.
class DemoProfileDataSource implements ProfileDataSource {
  DemoProfileDataSource({this.latencia = const Duration(milliseconds: 400)});

  final Duration latencia;

  PerfilEstudiante _perfil = PerfilEstudiante(
    matricula: '202601234',
    carrera: 'Ingeniería en Desarrollo de Software',
    telefono: '7770000234',
    credencial: EstadoCredencial.aprobada,
    credencialAprobadaEl: DateTime(2026, 10, 21, 11, 40),
    contactoEmergencia: const ContactoEmergencia(
      nombre: 'Ana Hernández Ríos',
      parentesco: 'Madre',
      telefono: '7770000235',
    ),
  );

  PreferenciasNotificacion _preferencias = const PreferenciasNotificacion();

  Future<void> _red() => Future<void>.delayed(latencia);

  @override
  Future<PerfilEstudiante> fetchPerfil() async {
    await _red();
    return _perfil;
  }

  @override
  Future<PerfilEstudiante> guardarContacto({
    required String telefono,
    required ContactoEmergencia contactoEmergencia,
  }) async {
    await _red();
    return _perfil = _perfil.copyWith(
      telefono: telefono,
      contactoEmergencia: contactoEmergencia,
    );
  }

  @override
  Future<PreferenciasNotificacion> fetchPreferencias() async {
    await _red();
    return _preferencias;
  }

  @override
  Future<PreferenciasNotificacion> guardarPreferencias(
    PreferenciasNotificacion preferencias,
  ) async {
    await _red();
    return _preferencias = preferencias;
  }
}
