import '../../domain/entities/perfil_estudiante.dart';

abstract interface class ProfileDataSource {
  Future<PerfilEstudiante> fetchPerfil();

  Future<PerfilEstudiante> guardarContacto({
    required String telefono,
    required ContactoEmergencia contactoEmergencia,
  });

  Future<PreferenciasNotificacion> fetchPreferencias();

  Future<PreferenciasNotificacion> guardarPreferencias(
    PreferenciasNotificacion preferencias,
  );
}
