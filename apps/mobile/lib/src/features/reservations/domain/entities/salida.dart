import 'package:equatable/equatable.dart';

/// Parada de una salida con su hora estimada ("Las Palmas", "06:52").
class Parada extends Equatable {
  const Parada({required this.nombre, required this.hora});

  final String nombre;
  final String hora;

  @override
  List<Object?> get props => [nombre, hora];
}

/// Salida programada de una ruta (combi, horario y cupo).
class Salida extends Equatable {
  const Salida({
    required this.id,
    required this.rutaCodigo,
    required this.rutaNombre,
    required this.fecha,
    required this.horaSalida,
    required this.horaLlegada,
    required this.unidad,
    required this.operador,
    required this.cupoTotal,
    required this.reservados,
    required this.paradas,
    this.precio = 20,
  });

  final String id;
  final String rutaCodigo;
  final String rutaNombre;
  final DateTime fecha;
  final String horaSalida;
  final String horaLlegada;
  final String unidad;
  final String operador;
  final int cupoTotal;
  final int reservados;
  final List<Parada> paradas;

  /// Importe de demostración; la tarifa real la define administración.
  final double precio;

  int get disponibles => cupoTotal - reservados;
  bool get llena => disponibles <= 0;
  bool get pocosLugares => !llena && disponibles <= 3;
  String get origen => paradas.first.nombre;
  String get destino => paradas.last.nombre;

  Salida copyWith({int? reservados}) => Salida(
    id: id,
    rutaCodigo: rutaCodigo,
    rutaNombre: rutaNombre,
    fecha: fecha,
    horaSalida: horaSalida,
    horaLlegada: horaLlegada,
    unidad: unidad,
    operador: operador,
    cupoTotal: cupoTotal,
    reservados: reservados ?? this.reservados,
    paradas: paradas,
    precio: precio,
  );

  @override
  List<Object?> get props => [id, fecha, reservados];
}
