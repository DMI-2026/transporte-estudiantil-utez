import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/ui_state.dart';
import '../../domain/entities/perfil_operador.dart';
import '../../domain/repositories/operator_repository.dart';

/// Pantalla 10 · Perfil del operador.
class OperadorPerfilCubit extends Cubit<UiState<PerfilOperador>> {
  OperadorPerfilCubit(this._repository) : super(const UiLoading());

  final OperatorRepository _repository;

  Future<void> load() async {
    emit(const UiLoading());
    final result = await _repository.fetchPerfil();
    if (result.failure != null) {
      emit(UiError(message: result.failure!.userMessage, onRetry: load));
      return;
    }
    emit(UiData(result.value!));
  }
}
