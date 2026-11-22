import 'package:equatable/equatable.dart';

import 'salida_operador.dart';

enum EstadoAbordaje { reservada, abordada }

extension EstadoAbordajeTexto on EstadoAbordaje {
  String get texto => switch (this) {
    EstadoAbordaje.reservada => 'Reservada',
    EstadoAbordaje.abordada => 'Abordada',
  };
}

/// Estudiante con reserva en una salida (lista de abordaje).
class Pasajero extends Equatable {
  const Pasajero({
    required this.folio,
    required this.nombre,
    required this.parada,
    required this.estado,
  });

  final String folio;
  final String nombre;
  final String parada;
  final EstadoAbordaje estado;

  Pasajero abordar() => Pasajero(
    folio: folio,
    nombre: nombre,
    parada: parada,
    estado: EstadoAbordaje.abordada,
  );

  @override
  List<Object?> get props => [folio, nombre, parada, estado];
}

/// Resultado de leer un QR. Un QR inválido es un resultado, no un fallo:
/// la reserva puede estar cancelada, sin pago o ser de otra salida.
class LecturaQr extends Equatable {
  const LecturaQr.valida({required Pasajero this.pasajero, required this.salida})
    : valida = true,
      motivo = null;

  const LecturaQr.invalida({required String this.motivo, required this.salida})
    : valida = false,
      pasajero = null;

  final bool valida;
  final Pasajero? pasajero;
  final String? motivo;

  /// Salida con los contadores actualizados después de la lectura.
  final SalidaOperador salida;

  @override
  List<Object?> get props => [valida, pasajero, motivo, salida];
}
