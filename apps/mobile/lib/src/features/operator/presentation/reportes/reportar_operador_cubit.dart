import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/ui_state.dart';
import '../../../incidents/domain/entities/reporte.dart';
import '../../../incidents/domain/validators/reporte_validator.dart';
import '../../domain/entities/salida_operador.dart';
import '../../domain/repositories/operator_repository.dart';

/// Tipos de incidente que reporta el operador (pantalla 08).
abstract final class TiposIncidenteOperador {
  static const todos = [
    'Falla mecánica',
    'Iluminación',
    'Llanta ponchada',
    'Tráfico o desvío',
    'Situación con un pasajero',
    'Limpieza de la unidad',
    'Otro',
  ];
}

class ReportarOperadorState extends Equatable {
  const ReportarOperadorState({
    this.salida = const UiLoading(),
    this.tipo,
    this.parada,
    this.descripcion = '',
    this.evidencia,
    this.mostrarErrores = false,
    this.enviando = false,
    this.error,
    this.enviado,
  });

  final UiState<SalidaOperador> salida;
  final String? tipo;
  final String? parada;
  final String descripcion;
  final String? evidencia;
  final bool mostrarErrores;
  final bool enviando;
  final String? error;
  final Reporte? enviado;

  String? get errorTipo => mostrarErrores ? ReporteValidator.tipo(tipo) : null;
  String? get errorParada =>
      mostrarErrores ? (parada == null ? 'Elige la parada relacionada.' : null) : null;
  String? get errorDescripcion =>
      mostrarErrores ? ReporteValidator.descripcion(descripcion) : null;

  bool get esValido =>
      ReporteValidator.tipo(tipo) == null &&
      parada != null &&
      ReporteValidator.descripcion(descripcion) == null;

  ReportarOperadorState copyWith({
    UiState<SalidaOperador>? salida,
    String? tipo,
    String? parada,
    String? descripcion,
    String? evidencia,
    bool? mostrarErrores,
    bool? enviando,
    String? error,
    Reporte? enviado,
    bool clearError = false,
    bool clearEvidencia = false,
  }) {
    return ReportarOperadorState(
      salida: salida ?? this.salida,
      tipo: tipo ?? this.tipo,
      parada: parada ?? this.parada,
      descripcion: descripcion ?? this.descripcion,
      evidencia: clearEvidencia ? null : evidencia ?? this.evidencia,
      mostrarErrores: mostrarErrores ?? this.mostrarErrores,
      enviando: enviando ?? this.enviando,
      error: clearError ? null : error ?? this.error,
      enviado: enviado ?? this.enviado,
    );
  }

  @override
  List<Object?> get props => [
    salida,
    tipo,
    parada,
    descripcion,
    evidencia,
    mostrarErrores,
    enviando,
    error,
    enviado,
  ];
}

/// Pantalla 08 · Reportar incidente desde la unidad.
class ReportarOperadorCubit extends Cubit<ReportarOperadorState> {
  ReportarOperadorCubit(this._repository, {this.salidaId})
    : super(const ReportarOperadorState());

  final OperatorRepository _repository;
  final String? salidaId;

  Future<void> load() async {
    emit(state.copyWith(salida: const UiLoading()));
    final result = salidaId == null
        ? await _repository.fetchSalidaActiva()
        : await _repository.fetchSalida(salidaId!);
    if (result.failure != null) {
      emit(
        state.copyWith(
          salida: UiError(message: result.failure!.userMessage, onRetry: load),
        ),
      );
      return;
    }
    final salida = result.value!;
    emit(
      state.copyWith(
        salida: UiData(salida),
        parada: state.parada ?? salida.paradaActual.nombre,
      ),
    );
  }

  void elegirTipo(String? tipo) =>
      emit(state.copyWith(tipo: tipo, clearError: true));

  void elegirParada(String? parada) =>
      emit(state.copyWith(parada: parada, clearError: true));

  void escribirDescripcion(String texto) =>
      emit(state.copyWith(descripcion: texto, clearError: true));

  /// Evidencia de demostración: no abre la cámara real.
  void adjuntarEvidenciaDemo() =>
      emit(state.copyWith(evidencia: 'evidencia_unidad_demo.jpg'));

  void quitarEvidencia() => emit(state.copyWith(clearEvidencia: true));

  Future<void> enviar() async {
    final salida = state.salida;
    if (salida is! UiData<SalidaOperador> || state.enviando) return;
    if (!state.esValido) {
      emit(state.copyWith(mostrarErrores: true));
      return;
    }
    emit(state.copyWith(enviando: true, clearError: true));
    final s = salida.value;
    final result = await _repository.enviarReporte(
      NuevoReporte(
        tipo: state.tipo!,
        referencia: '${s.id} · ${s.unidad} · ${state.parada}',
        descripcion: state.descripcion.trim(),
        evidencia: state.evidencia,
      ),
    );
    if (result.failure != null) {
      emit(
        state.copyWith(enviando: false, error: result.failure!.userMessage),
      );
      return;
    }
    emit(state.copyWith(enviando: false, enviado: result.value));
  }
}
