import 'package:equatable/equatable.dart';

enum EstadoSalida { programada, enCurso, finalizada }

extension EstadoSalidaTexto on EstadoSalida {
  String get texto => switch (this) {
    EstadoSalida.programada => 'Programada',
    EstadoSalida.enCurso => 'En curso',
    EstadoSalida.finalizada => 'Finalizada',
  };
}

/// Parada del recorrido con su hora estimada.
class ParadaRecorrido extends Equatable {
  const ParadaRecorrido({required this.nombre, required this.hora});

  final String nombre;
  final String hora;

  @override
  List<Object?> get props => [nombre, hora];
}

/// Salida asignada al operador (colección `salidas`).
class SalidaOperador extends Equatable {
  const SalidaOperador({
    required this.id,
    required this.rutaCodigo,
    required this.rutaNombre,
    required this.fecha,
    required this.horaSalida,
    required this.horaLlegada,
    required this.unidad,
    required this.cupoTotal,
    required this.reservas,
    required this.abordados,
    required this.paradas,
    this.estado = EstadoSalida.programada,
    this.indiceParadaActual = 0,
    this.iniciadaA,
    this.finalizadaA,
  });

  final String id;
  final String rutaCodigo;
  final String rutaNombre;
  final DateTime fecha;
  final String horaSalida;
  final String horaLlegada;
  final String unidad;
  final int cupoTotal;
  final int reservas;
  final int abordados;
  final List<ParadaRecorrido> paradas;
  final EstadoSalida estado;
  final int indiceParadaActual;
  final String? iniciadaA;
  final String? finalizadaA;

  String get origen => paradas.first.nombre;
  String get destino => paradas.last.nombre;
  int get disponibles => cupoTotal - reservas;
  int get porAbordar => reservas - abordados;
  ParadaRecorrido get paradaActual => paradas[indiceParadaActual];
  bool get enUltimaParada => indiceParadaActual >= paradas.length - 1;
  ParadaRecorrido? get siguienteParada =>
      enUltimaParada ? null : paradas[indiceParadaActual + 1];

  SalidaOperador copyWith({
    int? abordados,
    EstadoSalida? estado,
    int? indiceParadaActual,
    String? iniciadaA,
    String? finalizadaA,
  }) => SalidaOperador(
    id: id,
    rutaCodigo: rutaCodigo,
    rutaNombre: rutaNombre,
    fecha: fecha,
    horaSalida: horaSalida,
    horaLlegada: horaLlegada,
    unidad: unidad,
    cupoTotal: cupoTotal,
    reservas: reservas,
    abordados: abordados ?? this.abordados,
    paradas: paradas,
    estado: estado ?? this.estado,
    indiceParadaActual: indiceParadaActual ?? this.indiceParadaActual,
    iniciadaA: iniciadaA ?? this.iniciadaA,
    finalizadaA: finalizadaA ?? this.finalizadaA,
  );

  @override
  List<Object?> get props => [id, abordados, estado, indiceParadaActual];
}
