import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/core/errors/app_failure.dart';
import 'package:transporte_estudiantil/src/core/widgets/ui_state.dart';
import 'package:transporte_estudiantil/src/features/profile/domain/entities/perfil_estudiante.dart';
import 'package:transporte_estudiantil/src/features/profile/presentation/ajustes/ajustes_cubit.dart';

import '../../../fakes/fake_profile_repository.dart';

void main() {
  PreferenciasNotificacion valor(AjustesCubit c) =>
      (c.state.preferencias as UiData<PreferenciasNotificacion>).value;

  test('guarda el cambio de una preferencia', () async {
    final repo = FakeProfileRepository();
    final cubit = AjustesCubit(repo);
    await cubit.load();

    await cubit.cambiar(valor(cubit).copyWith(avisosGenerales: true));

    expect(valor(cubit).avisosGenerales, isTrue);
    expect(repo.preferencias.avisosGenerales, isTrue);
  });

  test('si falla, revierte el cambio y muestra el error', () async {
    final cubit = AjustesCubit(
      FakeProfileRepository(saveFailure: const NetworkFailure()),
    );
    await cubit.load();

    await cubit.cambiar(valor(cubit).copyWith(recordatoriosSalida: false));

    expect(valor(cubit).recordatoriosSalida, isTrue);
    expect(cubit.state.error, contains('conexión'));
  });
}
