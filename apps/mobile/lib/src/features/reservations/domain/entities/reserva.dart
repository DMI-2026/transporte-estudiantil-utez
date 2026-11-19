import 'package:equatable/equatable.dart';

import 'salida.dart';

/// Estados de `reservas/{id}` (docs/pantallas/reservations.md).
enum EstadoReserva { pendientePago, reservada, abordada, cancelada }

enum EstadoPago { pendiente, aprobado, reembolsado }

extension EstadoReservaTexto on EstadoReserva {
  String get texto => switch (this) {
    EstadoReserva.pendientePago => 'Pendiente de pago',
    EstadoReserva.reservada => 'Reservada',
    EstadoReserva.abordada => 'Abordada',
    EstadoReserva.cancelada => 'Cancelada',
  };
}

class Pago extends Equatable {
  const Pago({
    required this.monto,
    required this.referencia,
    required this.metodo,
    required this.estado,
  });

  final double monto;
  final String referencia;
  final String metodo;
  final EstadoPago estado;

  @override
  List<Object?> get props => [monto, referencia, metodo, estado];
}

class Reserva extends Equatable {
  const Reserva({
    required this.folio,
    required this.salida,
    required this.parada,
    required this.estado,
    required this.pago,
    this.asientos = 1,
    this.abordadaA,
  });

  final String folio;
  final Salida salida;
  final Parada parada;
  final EstadoReserva estado;
  final Pago pago;
  final int asientos;
  final String? abordadaA;

  /// Una reserva activa todavía puede usarse o cancelarse.
  bool get activa =>
      estado == EstadoReserva.reservada ||
      estado == EstadoReserva.pendientePago;

  /// Solo una reserva pagada emite un QR válido.
  bool get qrValido => estado == EstadoReserva.reservada;

  Reserva copyWith({EstadoReserva? estado, Pago? pago, Salida? salida}) =>
      Reserva(
        folio: folio,
        salida: salida ?? this.salida,
        parada: parada,
        estado: estado ?? this.estado,
        pago: pago ?? this.pago,
        asientos: asientos,
        abordadaA: abordadaA,
      );

  @override
  List<Object?> get props => [folio, salida, parada, estado, pago, asientos];
}
