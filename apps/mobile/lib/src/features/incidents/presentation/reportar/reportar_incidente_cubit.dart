import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/ui_state.dart';
import '../../../reservations/domain/repositories/reservations_repository.dart';
import '../../domain/entities/reporte.dart';
import '../../domain/repositories/incidents_repository.dart';
import '../../domain/validators/reporte_validator.dart';

part 'reportar_incidente_state.dart';

class ReportarIncidenteCubit extends Cubit<ReportarIncidenteState> {
  ReportarIncidenteCubit(
    this._incidents,
    this._reservas, {
    String? referenciaInicial,
  }) : super(ReportarIncidenteState(referencia: referenciaInicial));

  final IncidentsRepository _incidents;
  final ReservationsRepository _reservas;

  /// Carga las salidas de tus reservas para relacionar el reporte.
  Future<void> load() async {
    emit(state.copyWith(referencias: const UiLoading()));
    final result = await _reservas.fetchMisReservas();
    if (result.failure != null) {
      emit(
        state.copyWith(
          referencias: UiError(
            message: result.failure!.userMessage,
            onRetry: load,
          ),
        ),
      );
      return;
    }
    final opciones = <String>{
      ?state.referencia,
      for (final r in result.value ?? const [])
        '${r.salida.id} · ${r.salida.unidad}',
    }.toList();
    emit(
      state.copyWith(
        referencias: opciones.isEmpty
            ? const UiEmpty(
                message:
                    'Necesitas una reserva para relacionar el reporte con una salida.',
              )
            : UiData(opciones),
      ),
    );
  }

  void elegirTipo(String? tipo) =>
      emit(state.copyWith(tipo: tipo, clearError: true));

  void elegirReferencia(String? referencia) =>
      emit(state.copyWith(referencia: referencia, clearError: true));

  void escribirDescripcion(String texto) =>
      emit(state.copyWith(descripcion: texto, clearError: true));

  /// Evidencia de demostración: no abre la cámara real (pendiente de O7).
  void adjuntarEvidenciaDemo() =>
      emit(state.copyWith(evidencia: 'evidencia_demo.jpg'));

  void quitarEvidencia() => emit(state.copyWith(clearEvidencia: true));

  Future<void> enviar() async {
    if (state.enviando) return;
    if (!state.esValido) {
      emit(state.copyWith(mostrarErrores: true));
      return;
    }
    emit(state.copyWith(enviando: true, clearError: true));
    final result = await _incidents.enviar(
      NuevoReporte(
        tipo: state.tipo!,
        referencia: state.referencia!,
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
