import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/ui_state.dart';
import '../../domain/entities/reserva.dart';
import '../../domain/repositories/reservations_repository.dart';

/// Carga una reserva por folio. Lo usan la confirmación, el QR de abordaje
/// y la cancelación.
class ReservaDetalleCubit extends Cubit<UiState<Reserva>> {
  ReservaDetalleCubit(this._repository, this.folio) : super(const UiLoading());

  final ReservationsRepository _repository;
  final String folio;

  Future<void> load() async {
    emit(const UiLoading());
    final result = await _repository.fetchReserva(folio);
    if (result.failure != null) {
      emit(UiError(message: result.failure!.userMessage, onRetry: load));
      return;
    }
    emit(UiData(result.value!));
  }
}
