part of 'salidas_cubit.dart';

class SalidasState extends Equatable {
  const SalidasState({
    this.salidas = const UiLoading(),
    this.seleccionada,
    this.parada,
    this.reservando = false,
    this.error,
    this.reservaCreada,
  });

  final UiState<List<Salida>> salidas;
  final Salida? seleccionada;
  final String? parada;
  final bool reservando;
  final String? error;
  final Reserva? reservaCreada;

  bool get puedeReservar =>
      seleccionada != null && parada != null && !reservando;

  SalidasState copyWith({
    UiState<List<Salida>>? salidas,
    Salida? seleccionada,
    String? parada,
    bool? reservando,
    String? error,
    Reserva? reservaCreada,
    bool clearError = false,
  }) {
    return SalidasState(
      salidas: salidas ?? this.salidas,
      seleccionada: seleccionada ?? this.seleccionada,
      parada: parada ?? this.parada,
      reservando: reservando ?? this.reservando,
      error: clearError ? null : error ?? this.error,
      reservaCreada: reservaCreada ?? this.reservaCreada,
    );
  }

  @override
  List<Object?> get props => [
    salidas,
    seleccionada,
    parada,
    reservando,
    error,
    reservaCreada,
  ];
}
