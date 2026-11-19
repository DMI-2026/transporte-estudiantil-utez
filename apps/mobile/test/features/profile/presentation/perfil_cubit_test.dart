import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/core/errors/app_failure.dart';
import 'package:transporte_estudiantil/src/core/widgets/ui_state.dart';
import 'package:transporte_estudiantil/src/features/profile/domain/entities/perfil_estudiante.dart';
import 'package:transporte_estudiantil/src/features/profile/presentation/perfil/perfil_cubit.dart';

import '../../../fakes/fake_profile_repository.dart';

void main() {
  const contacto = ContactoEmergencia(
    nombre: 'Luis Pérez',
    parentesco: 'Padre',
    telefono: '777 111 2233',
  );

  test('carga el perfil', () async {
    final cubit = PerfilCubit(FakeProfileRepository());

    await cubit.load();

    expect(
      (cubit.state.perfil as UiData<PerfilEstudiante>).value.matricula,
      '202601234',
    );
  });

  test('no guarda un teléfono inválido', () async {
    final repo = FakeProfileRepository();
    final cubit = PerfilCubit(repo);
    await cubit.load();

    final ok = await cubit.guardarContacto(telefono: '123', contacto: contacto);

    expect(ok, isFalse);
    expect(repo.guardados, 0);
    expect(cubit.state.error, 'El teléfono debe tener 10 dígitos.');
  });

  test('guarda solo dígitos y actualiza el perfil', () async {
    final repo = FakeProfileRepository();
    final cubit = PerfilCubit(repo);
    await cubit.load();

    final ok = await cubit.guardarContacto(
      telefono: '777 999 8877',
      contacto: contacto,
    );

    expect(ok, isTrue);
    final perfil = (cubit.state.perfil as UiData<PerfilEstudiante>).value;
    expect(perfil.telefono, '7779998877');
    expect(perfil.contactoEmergencia?.telefono, '7771112233');
  });

  test('si falla el guardado muestra el mensaje', () async {
    final cubit = PerfilCubit(
      FakeProfileRepository(saveFailure: const NetworkFailure()),
    );
    await cubit.load();

    final ok = await cubit.guardarContacto(
      telefono: '7779998877',
      contacto: contacto,
    );

    expect(ok, isFalse);
    expect(cubit.state.error, contains('conexión'));
  });
}
