import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/ui_state.dart';
import '../../domain/entities/salida_operador.dart';
import '../../domain/repositories/operator_repository.dart';

class RecorridoState extends Equatable {
  const RecorridoState({
    this.salida = const UiLoading(),
    this.marcando = false,
    this.error,
  });

  final UiState<SalidaOperador> salida;
  final bool marcando;
  final String? error;

  @override
  List<Object?> get props => [salida, marcando, error];
}

/// Pantalla 05 · Recorrido en curso.
class RecorridoCubit extends Cubit<RecorridoState> {
  RecorridoCubit(this._repository, this.salidaId)
    : super(const RecorridoState());

  final OperatorRepository _repository;
  final String salidaId;

  Future<void> load() async {
    emit(const RecorridoState());
    final result = await _repository.fetchSalida(salidaId);
    if (result.failure != null) {
      emit(
        RecorridoState(
          salida: UiError(message: result.failure!.userMessage, onRetry: load),
        ),
      );
      return;
    }
    emit(RecorridoState(salida: UiData(result.value!)));
  }

  Future<void> marcarLlegada() async {
    final actual = state.salida;
    if (actual is! UiData<SalidaOperador> || state.marcando) return;
    emit(RecorridoState(salida: actual, marcando: true));
    final result = await _repository.marcarLlegada(salidaId);
    if (result.failure != null) {
      emit(RecorridoState(salida: actual, error: result.failure!.userMessage));
      return;
    }
    emit(RecorridoState(salida: UiData(result.value!)));
  }
}
