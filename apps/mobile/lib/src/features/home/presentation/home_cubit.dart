import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/ui_state.dart';
import '../../reservations/domain/entities/reserva.dart';
import '../../reservations/domain/repositories/reservations_repository.dart';

part 'home_state.dart';

/// Inicio del estudiante: saludo + próxima reserva activa.
class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._reservas) : super(const HomeState());

  final ReservationsRepository _reservas;

  Future<void> load() async {
    emit(state.copyWith(proxima: const UiLoading()));
    final result = await _reservas.fetchMisReservas();
    if (result.failure != null) {
      emit(
        state.copyWith(
          proxima: UiError(
            message: result.failure!.userMessage,
            onRetry: load,
          ),
        ),
      );
      return;
    }
    final activas = [
      for (final r in result.value ?? const <Reserva>[])
        if (r.activa) r,
    ]..sort((a, b) => a.salida.fecha.compareTo(b.salida.fecha));

    if (activas.isEmpty) {
      emit(
        state.copyWith(
          proxima: const UiEmpty(
            message: 'Aún no tienes una reserva próxima.',
          ),
        ),
      );
      return;
    }
    emit(state.copyWith(proxima: UiData(activas.first)));
  }
}
