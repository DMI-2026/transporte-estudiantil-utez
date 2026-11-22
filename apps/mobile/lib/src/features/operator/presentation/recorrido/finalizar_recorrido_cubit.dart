import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/ui_state.dart';
import '../../../incidents/domain/entities/reporte.dart';
import '../../domain/entities/salida_operador.dart';
import '../../domain/repositories/operator_repository.dart';

class ResumenRecorrido extends Equatable {
  const ResumenRecorrido({required this.salida, required this.reportesAbiertos});

  final SalidaOperador salida;

  /// Reportes propios de esta salida que siguen abiertos.
  final List<Reporte> reportesAbiertos;

  @override
  List<Object?> get props => [salida, reportesAbiertos];
}

class FinalizarRecorridoState extends Equatable {
  const FinalizarRecorridoState({
    this.resumen = const UiLoading(),
    this.finalizando = false,
    this.error,
    this.finalizada,
  });

  final UiState<ResumenRecorrido> resumen;
  final bool finalizando;
  final String? error;
  final SalidaOperador? finalizada;

  @override
  List<Object?> get props => [resumen, finalizando, error, finalizada];
}

/// Pantalla 11 · Finalizar recorrido.
class FinalizarRecorridoCubit extends Cubit<FinalizarRecorridoState> {
  FinalizarRecorridoCubit(this._repository, this.salidaId)
    : super(const FinalizarRecorridoState());

  final OperatorRepository _repository;
  final String salidaId;

  Future<void> load() async {
    emit(const FinalizarRecorridoState());
    final salida = await _repository.fetchSalida(salidaId);
    final reportes = await _repository.fetchMisReportes();
    final failure = salida.failure ?? reportes.failure;
    if (failure != null) {
      emit(
        FinalizarRecorridoState(
          resumen: UiError(message: failure.userMessage, onRetry: load),
        ),
      );
      return;
    }
    emit(
      FinalizarRecorridoState(
        resumen: UiData(
          ResumenRecorrido(
            salida: salida.value!,
            reportesAbiertos: [
              for (final r in reportes.value!)
                if (r.referencia.startsWith(salidaId) &&
                    r.estado != EstadoReporte.cerrado)
                  r,
            ],
          ),
        ),
      ),
    );
  }

  Future<void> finalizar() async {
    final actual = state.resumen;
    if (actual is! UiData<ResumenRecorrido> || state.finalizando) return;
    emit(FinalizarRecorridoState(resumen: actual, finalizando: true));
    final result = await _repository.finalizarRecorrido(salidaId);
    if (result.failure != null) {
      emit(
        FinalizarRecorridoState(
          resumen: actual,
          error: result.failure!.userMessage,
        ),
      );
      return;
    }
    emit(FinalizarRecorridoState(resumen: actual, finalizada: result.value));
  }
}
