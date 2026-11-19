import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/ui_state.dart';
import '../domain/entities/viaje_en_curso.dart';
import '../domain/repositories/trip_repository.dart';

class ViajeCubit extends Cubit<UiState<ViajeEnCurso>> {
  ViajeCubit(this._repository, this.folio) : super(const UiLoading());

  final TripRepository _repository;
  final String folio;

  Future<void> load() async {
    emit(const UiLoading());
    final result = await _repository.fetchViaje(folio);
    if (result.failure != null) {
      emit(UiError(message: result.failure!.userMessage, onRetry: load));
      return;
    }
    emit(UiData(result.value!));
  }
}
