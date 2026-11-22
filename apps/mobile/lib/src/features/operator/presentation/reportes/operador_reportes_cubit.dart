import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/ui_state.dart';
import '../../../incidents/domain/entities/reporte.dart';
import '../../domain/repositories/operator_repository.dart';

/// Pantalla 09 · Mis reportes del operador.
class OperadorReportesCubit extends Cubit<UiState<List<Reporte>>> {
  OperadorReportesCubit(this._repository) : super(const UiLoading());

  final OperatorRepository _repository;

  Future<void> load() async {
    emit(const UiLoading());
    final result = await _repository.fetchMisReportes();
    if (result.failure != null) {
      emit(UiError(message: result.failure!.userMessage, onRetry: load));
      return;
    }
    final reportes = result.value ?? const <Reporte>[];
    emit(
      reportes.isEmpty
          ? const UiEmpty(
              message: 'No has creado reportes. Si algo pasa en la unidad, avísanos aquí.',
            )
          : UiData(reportes),
    );
  }
}
