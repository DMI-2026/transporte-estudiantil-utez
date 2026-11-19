part of 'cancelar_reserva_cubit.dart';

class CancelarReservaState extends Equatable {
  const CancelarReservaState({
    this.reserva = const UiLoading(),
    this.motivo,
    this.confirmado = false,
    this.enviando = false,
    this.error,
    this.cancelada,
  });

  final UiState<Reserva> reserva;
  final String? motivo;
  final bool confirmado;
  final bool enviando;
  final String? error;
  final Reserva? cancelada;

  bool get puedeCancelar =>
      motivo != null && confirmado && !enviando && reserva is UiData<Reserva>;

  CancelarReservaState copyWith({
    UiState<Reserva>? reserva,
    String? motivo,
    bool? confirmado,
    bool? enviando,
    String? error,
    Reserva? cancelada,
    bool clearError = false,
  }) {
    return CancelarReservaState(
      reserva: reserva ?? this.reserva,
      motivo: motivo ?? this.motivo,
      confirmado: confirmado ?? this.confirmado,
      enviando: enviando ?? this.enviando,
      error: clearError ? null : error ?? this.error,
      cancelada: cancelada ?? this.cancelada,
    );
  }

  @override
  List<Object?> get props => [
    reserva,
    motivo,
    confirmado,
    enviando,
    error,
    cancelada,
  ];
}
