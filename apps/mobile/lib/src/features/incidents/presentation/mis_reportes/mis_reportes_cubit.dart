import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/ui_state.dart';
import '../../domain/entities/reporte.dart';
import '../../domain/repositories/incidents_repository.dart';

class MisReportesCubit extends Cubit<UiState<List<Reporte>>> {
  MisReportesCubit(this._repository) : super(const UiLoading());

  final IncidentsRepository _repository;

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
              message:
                  'No has enviado reportes. Si algo pasa en tu viaje, avísanos aquí.',
            )
          : UiData(reportes),
    );
  }
}
