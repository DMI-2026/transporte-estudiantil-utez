import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/ui_state.dart';
import '../../domain/entities/pasajero.dart';
import '../../domain/entities/salida_operador.dart';
import '../../domain/repositories/operator_repository.dart';

class ValidarAbordajeState extends Equatable {
  const ValidarAbordajeState({
    this.salida = const UiLoading(),
    this.leyendo = false,
    this.ultimaValida,
    this.invalida,
    this.error,
  });

  final UiState<SalidaOperador> salida;
  final bool leyendo;

  /// Última lectura válida, para mostrar el resumen del abordaje.
  final LecturaQr? ultimaValida;

  /// Lectura no válida; la vista abre la pantalla 12.
  final LecturaQr? invalida;
  final String? error;

  @override
  List<Object?> get props => [salida, leyendo, ultimaValida, invalida, error];
}

/// Pantalla 06 · Validar abordaje con lectura simulada de QR.
class ValidarAbordajeCubit extends Cubit<ValidarAbordajeState> {
  ValidarAbordajeCubit(this._repository, {this.salidaId})
    : super(const ValidarAbordajeState());

  final OperatorRepository _repository;

  /// Si es nulo se usa la salida activa (pestaña Abordaje).
  final String? salidaId;

  Future<void> load() async {
    emit(const ValidarAbordajeState());
    final result = salidaId == null
        ? await _repository.fetchSalidaActiva()
        : await _repository.fetchSalida(salidaId!);
    if (result.failure != null) {
      emit(
        ValidarAbordajeState(
          salida: UiError(message: result.failure!.userMessage, onRetry: load),
        ),
      );
      return;
    }
    emit(ValidarAbordajeState(salida: UiData(result.value!)));
  }

  Future<void> leer() async {
    final actual = state.salida;
    if (actual is! UiData<SalidaOperador> || state.leyendo) return;
    emit(
      ValidarAbordajeState(
        salida: actual,
        leyendo: true,
        ultimaValida: state.ultimaValida,
      ),
    );
    final result = await _repository.leerQrSimulado(actual.value.id);
    if (result.failure != null) {
      emit(
        ValidarAbordajeState(
          salida: actual,
          ultimaValida: state.ultimaValida,
          error: result.failure!.userMessage,
        ),
      );
      return;
    }
    final lectura = result.value!;
    emit(
      ValidarAbordajeState(
        salida: UiData(lectura.salida),
        ultimaValida: lectura.valida ? lectura : state.ultimaValida,
        invalida: lectura.valida ? null : lectura,
      ),
    );
  }
}
