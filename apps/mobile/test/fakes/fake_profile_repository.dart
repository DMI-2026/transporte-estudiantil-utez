import 'package:transporte_estudiantil/src/core/errors/app_failure.dart';
import 'package:transporte_estudiantil/src/features/profile/domain/entities/perfil_estudiante.dart';
import 'package:transporte_estudiantil/src/features/profile/domain/repositories/profile_repository.dart';

class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository({this.failure, this.saveFailure});

  static const perfilDemo = PerfilEstudiante(
    matricula: '202601234',
    carrera: 'Ingeniería en Desarrollo de Software',
    telefono: '7770000234',
    credencial: EstadoCredencial.aprobada,
    contactoEmergencia: ContactoEmergencia(
      nombre: 'Ana Hernández',
      parentesco: 'Madre',
      telefono: '7770000235',
    ),
  );

  PerfilEstudiante perfil = perfilDemo;
  PreferenciasNotificacion preferencias = const PreferenciasNotificacion();
  AppFailure? failure;
  AppFailure? saveFailure;
  int guardados = 0;

  @override
  Future<ProfileResult<PerfilEstudiante>> fetchPerfil() async =>
      failure != null ? (value: null, failure: failure) : (value: perfil, failure: null);

  @override
  Future<ProfileResult<PerfilEstudiante>> guardarContacto({
    required String telefono,
    required ContactoEmergencia contactoEmergencia,
  }) async {
    if (saveFailure != null) return (value: null, failure: saveFailure);
    guardados++;
    perfil = perfil.copyWith(
      telefono: telefono,
      contactoEmergencia: contactoEmergencia,
    );
    return (value: perfil, failure: null);
  }

  @override
  Future<ProfileResult<PreferenciasNotificacion>> fetchPreferencias() async =>
      failure != null
          ? (value: null, failure: failure)
          : (value: preferencias, failure: null);

  @override
  Future<ProfileResult<PreferenciasNotificacion>> guardarPreferencias(
    PreferenciasNotificacion nuevas,
  ) async {
    if (saveFailure != null) return (value: null, failure: saveFailure);
    guardados++;
    preferencias = nuevas;
    return (value: nuevas, failure: null);
  }
}
