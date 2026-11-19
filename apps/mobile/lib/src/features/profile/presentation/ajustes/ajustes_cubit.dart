import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/ui_state.dart';
import '../../domain/entities/perfil_estudiante.dart';
import '../../domain/repositories/profile_repository.dart';

class AjustesState extends Equatable {
  const AjustesState({
    this.preferencias = const UiLoading(),
    this.guardando = false,
    this.error,
  });

  final UiState<PreferenciasNotificacion> preferencias;
  final bool guardando;
  final String? error;

  @override
  List<Object?> get props => [preferencias, guardando, error];
}

class AjustesCubit extends Cubit<AjustesState> {
  AjustesCubit(this._repository) : super(const AjustesState());

  final ProfileRepository _repository;

  Future<void> load() async {
    emit(const AjustesState());
    final result = await _repository.fetchPreferencias();
    if (result.failure != null) {
      emit(
        AjustesState(
          preferencias: UiError(
            message: result.failure!.userMessage,
            onRetry: load,
          ),
        ),
      );
      return;
    }
    emit(AjustesState(preferencias: UiData(result.value!)));
  }

  /// Cambio optimista: se muestra al instante y se revierte si falla.
  Future<void> cambiar(PreferenciasNotificacion nuevas) async {
    final anterior = state.preferencias;
    if (anterior is! UiData<PreferenciasNotificacion> || state.guardando) {
      return;
    }
    emit(AjustesState(preferencias: UiData(nuevas), guardando: true));
    final result = await _repository.guardarPreferencias(nuevas);
    if (result.failure != null) {
      emit(
        AjustesState(
          preferencias: anterior,
          error: result.failure!.userMessage,
        ),
      );
      return;
    }
    emit(AjustesState(preferencias: UiData(result.value!)));
  }
}
