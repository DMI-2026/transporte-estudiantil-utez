import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/ui_state.dart';
import '../../domain/entities/reserva.dart';
import '../../domain/repositories/reservations_repository.dart';

class MisReservas extends Equatable {
  const MisReservas({required this.proximas, required this.anteriores});

  final List<Reserva> proximas;
  final List<Reserva> anteriores;

  @override
  List<Object?> get props => [proximas, anteriores];
}

class MisReservasCubit extends Cubit<UiState<MisReservas>> {
  MisReservasCubit(this._repository) : super(const UiLoading());

  final ReservationsRepository _repository;

  Future<void> load({bool mostrarCarga = true}) async {
    if (mostrarCarga || state is! UiData<MisReservas>) {
      emit(const UiLoading());
    }
    final result = await _repository.fetchMisReservas();
    if (result.failure != null) {
      emit(UiError(message: result.failure!.userMessage, onRetry: load));
      return;
    }
    final todas = result.value ?? const <Reserva>[];
    if (todas.isEmpty) {
      emit(
        const UiEmpty(
          message:
              'Sin reservas activas. Consulta horarios para elegir tu siguiente salida.',
        ),
      );
      return;
    }
    emit(
      UiData(
        MisReservas(
          proximas: [for (final r in todas) if (r.activa) r],
          anteriores: [for (final r in todas) if (!r.activa) r],
        ),
      ),
    );
  }
}
