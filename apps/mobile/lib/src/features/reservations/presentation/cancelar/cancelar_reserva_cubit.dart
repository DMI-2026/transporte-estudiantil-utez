import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/ui_state.dart';
import '../../domain/entities/reserva.dart';
import '../../domain/repositories/reservations_repository.dart';

part 'cancelar_reserva_state.dart';

class CancelarReservaCubit extends Cubit<CancelarReservaState> {
  CancelarReservaCubit(this._repository, this.folio)
    : super(const CancelarReservaState());

  static const motivos = [
    'Cambié mi horario',
    'Ya no voy a viajar',
    'Elegí otra salida',
    'Otro motivo',
  ];

  final ReservationsRepository _repository;
  final String folio;

  Future<void> load() async {
    emit(state.copyWith(reserva: const UiLoading()));
    final result = await _repository.fetchReserva(folio);
    if (result.failure != null) {
      emit(
        state.copyWith(
          reserva: UiError(message: result.failure!.userMessage, onRetry: load),
        ),
      );
      return;
    }
    emit(state.copyWith(reserva: UiData(result.value!)));
  }

  void elegirMotivo(String? motivo) =>
      emit(state.copyWith(motivo: motivo, clearError: true));

  void confirmar(bool valor) =>
      emit(state.copyWith(confirmado: valor, clearError: true));

  Future<void> cancelar() async {
    if (!state.puedeCancelar) return;
    emit(state.copyWith(enviando: true, clearError: true));
    final result = await _repository.cancelar(
      folio: folio,
      motivo: state.motivo!,
    );
    if (result.failure != null) {
      emit(
        state.copyWith(enviando: false, error: result.failure!.userMessage),
      );
      return;
    }
    emit(state.copyWith(enviando: false, cancelada: result.value));
  }
}
