import '../../../../core/errors/app_failure.dart';
import '../entities/perfil_estudiante.dart';

typedef ProfileResult<T> = ({T? value, AppFailure? failure});

abstract interface class ProfileRepository {
  Future<ProfileResult<PerfilEstudiante>> fetchPerfil();

  Future<ProfileResult<PerfilEstudiante>> guardarContacto({
    required String telefono,
    required ContactoEmergencia contactoEmergencia,
  });

  Future<ProfileResult<PreferenciasNotificacion>> fetchPreferencias();

  Future<ProfileResult<PreferenciasNotificacion>> guardarPreferencias(
    PreferenciasNotificacion preferencias,
  );
}
