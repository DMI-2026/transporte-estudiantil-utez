import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/ui_state.dart';
import '../../domain/entities/reserva.dart';
import '../../domain/entities/salida.dart';
import '../../domain/repositories/reservations_repository.dart';

part 'salidas_state.dart';

class SalidasCubit extends Cubit<SalidasState> {
  SalidasCubit(this._repository) : super(const SalidasState());

  final ReservationsRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(salidas: const UiLoading(), clearError: true));
    final result = await _repository.fetchSalidas();
    if (result.failure != null) {
      emit(
        state.copyWith(
          salidas: UiError(message: result.failure!.userMessage, onRetry: load),
        ),
      );
      return;
    }
    final salidas = result.value ?? const <Salida>[];
    emit(
      state.copyWith(
        salidas: salidas.isEmpty
            ? const UiEmpty(
                message: 'No hay salidas programadas. Prueba más tarde.',
              )
            : UiData(salidas),
      ),
    );
  }

  void seleccionar(Salida salida) {
    if (salida.llena) return;
    emit(
      state.copyWith(
        seleccionada: salida,
        parada: salida.paradas.first.nombre,
        clearError: true,
      ),
    );
  }

  void elegirParada(String? parada) {
    if (parada == null) return;
    emit(state.copyWith(parada: parada, clearError: true));
  }

  Future<void> reservar() async {
    final salida = state.seleccionada;
    final parada = state.parada;
    if (salida == null || parada == null || state.reservando) return;
    emit(state.copyWith(reservando: true, clearError: true));
    final result = await _repository.reservar(
      salidaId: salida.id,
      parada: parada,
    );
    if (result.failure != null) {
      emit(
        state.copyWith(
          reservando: false,
          error: result.failure!.userMessage,
        ),
      );
      return;
    }
    emit(state.copyWith(reservando: false, reservaCreada: result.value));
  }
}
