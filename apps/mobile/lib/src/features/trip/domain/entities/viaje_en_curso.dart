import 'package:equatable/equatable.dart';

import '../../../reservations/domain/entities/reserva.dart';
import '../../../reservations/domain/entities/salida.dart';

/// Coordenada WGS84 para el mapa del viaje.
class PuntoMapa extends Equatable {
  const PuntoMapa({required this.latitud, required this.longitud});

  final double latitud;
  final double longitud;

  @override
  List<Object?> get props => [latitud, longitud];
}

/// Progreso del viaje de una reserva (ubicación/ETA desde Firestore + Functions).
class ViajeEnCurso extends Equatable {
  const ViajeEnCurso({
    required this.reserva,
    required this.indiceParadaActual,
    required this.minutosParaLlegar,
    required this.actualizadoA,
    this.ubicacionCombi,
    this.ubicacionParada,
    this.polyline = const [],
  });

  final Reserva reserva;
  final int indiceParadaActual;
  final int minutosParaLlegar;
  final String actualizadoA;
  final PuntoMapa? ubicacionCombi;
  final PuntoMapa? ubicacionParada;
  final List<PuntoMapa> polyline;

  List<Parada> get paradas => reserva.salida.paradas;
  Parada get paradaActual => paradas[indiceParadaActual];

  @override
  List<Object?> get props => [
        reserva,
        indiceParadaActual,
        minutosParaLlegar,
        ubicacionCombi,
        ubicacionParada,
      ];
}
