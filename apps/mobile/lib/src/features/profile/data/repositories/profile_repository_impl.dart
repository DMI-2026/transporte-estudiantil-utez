import '../../../../core/errors/app_failure.dart';
import '../../domain/entities/perfil_estudiante.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this.source);

  final ProfileDataSource source;

  @override
  Future<ProfileResult<PerfilEstudiante>> fetchPerfil() =>
      _guard(source.fetchPerfil);

  @override
  Future<ProfileResult<PerfilEstudiante>> guardarContacto({
    required String telefono,
    required ContactoEmergencia contactoEmergencia,
  }) => _guard(
    () => source.guardarContacto(
      telefono: telefono,
      contactoEmergencia: contactoEmergencia,
    ),
  );

  @override
  Future<ProfileResult<PreferenciasNotificacion>> fetchPreferencias() =>
      _guard(source.fetchPreferencias);

  @override
  Future<ProfileResult<PreferenciasNotificacion>> guardarPreferencias(
    PreferenciasNotificacion preferencias,
  ) => _guard(() => source.guardarPreferencias(preferencias));

  Future<ProfileResult<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return (value: await action(), failure: null);
    } on AppFailure catch (e) {
      return (value: null, failure: e);
    } catch (_) {
      return (value: null, failure: const GenericFailure());
    }
  }
}
