import 'package:equatable/equatable.dart';

import '../../../reservations/domain/entities/reserva.dart';
import '../../../reservations/domain/entities/salida.dart';

/// Progreso del viaje de una reserva. La posición es ilustrativa: no hay
/// GPS real hasta que exista la capacidad P2 (issues #12 y #14).
class ViajeEnCurso extends Equatable {
  const ViajeEnCurso({
    required this.reserva,
    required this.indiceParadaActual,
    required this.minutosParaLlegar,
    required this.actualizadoA,
  });

  final Reserva reserva;
  final int indiceParadaActual;
  final int minutosParaLlegar;
  final String actualizadoA;

  List<Parada> get paradas => reserva.salida.paradas;
  Parada get paradaActual => paradas[indiceParadaActual];

  @override
  List<Object?> get props => [reserva, indiceParadaActual, minutosParaLlegar];
}
