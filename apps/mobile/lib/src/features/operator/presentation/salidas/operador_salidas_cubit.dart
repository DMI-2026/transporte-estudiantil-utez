import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/ui_state.dart';
import '../../domain/entities/salida_operador.dart';
import '../../domain/repositories/operator_repository.dart';

class OperadorSalidasState extends Equatable {
  const OperadorSalidasState({
    this.salidas = const UiLoading(),
    this.iniciando = false,
    this.error,
    this.iniciada,
  });

  final UiState<List<SalidaOperador>> salidas;
  final bool iniciando;
  final String? error;

  /// Salida que se acaba de iniciar; la vista navega al recorrido.
  final SalidaOperador? iniciada;

  OperadorSalidasState copyWith({
    UiState<List<SalidaOperador>>? salidas,
    bool? iniciando,
    String? error,
    SalidaOperador? iniciada,
    bool clearError = false,
    bool clearIniciada = false,
  }) {
    return OperadorSalidasState(
      salidas: salidas ?? this.salidas,
      iniciando: iniciando ?? this.iniciando,
      error: clearError ? null : error ?? this.error,
      iniciada: clearIniciada ? null : iniciada ?? this.iniciada,
    );
  }

  @override
  List<Object?> get props => [salidas, iniciando, error, iniciada];
}

/// Pantalla 04 · Mis salidas del operador.
class OperadorSalidasCubit extends Cubit<OperadorSalidasState> {
  OperadorSalidasCubit(this._repository) : super(const OperadorSalidasState());

  final OperatorRepository _repository;

  Future<void> load({bool mostrarCarga = true}) async {
    if (mostrarCarga) {
      emit(state.copyWith(salidas: const UiLoading(), clearError: true));
    }
    final result = await _repository.fetchSalidas();
    if (result.failure != null) {
      emit(
        state.copyWith(
          salidas: UiError(message: result.failure!.userMessage, onRetry: load),
        ),
      );
      return;
    }
    final salidas = result.value ?? const <SalidaOperador>[];
    emit(
      state.copyWith(
        clearIniciada: true,
        salidas: salidas.isEmpty
            ? const UiEmpty(
                message: 'Administración aún no te asigna salidas para hoy.',
              )
            : UiData(salidas),
      ),
    );
  }

  Future<void> iniciar(SalidaOperador salida) async {
    if (state.iniciando) return;
    emit(state.copyWith(iniciando: true, clearError: true));
    final result = await _repository.iniciarRecorrido(salida.id);
    if (result.failure != null) {
      emit(
        state.copyWith(iniciando: false, error: result.failure!.userMessage),
      );
      return;
    }
    emit(state.copyWith(iniciando: false, iniciada: result.value));
  }
}
