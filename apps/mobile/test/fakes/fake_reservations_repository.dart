import 'package:transporte_estudiantil/src/core/errors/app_failure.dart';
import 'package:transporte_estudiantil/src/features/reservations/domain/entities/reserva.dart';
import 'package:transporte_estudiantil/src/features/reservations/domain/entities/salida.dart';
import 'package:transporte_estudiantil/src/features/reservations/domain/repositories/reservations_repository.dart';

/// Datos fijos para pruebas del módulo estudiante.
abstract final class FixturesEstudiante {
  static final salida = Salida(
    id: 'SAL-001',
    rutaCodigo: 'R01',
    rutaNombre: 'Centro de Cuernavaca — UTEZ',
    fecha: DateTime(2026, 10, 26),
    horaSalida: '06:40',
    horaLlegada: '07:25',
    unidad: 'Combi 01',
    operador: 'Carlos M.',
    cupoTotal: 16,
    reservados: 11,
    paradas: const [
      Parada(nombre: 'Centro', hora: '06:40'),
      Parada(nombre: 'Las Palmas', hora: '06:52'),
      Parada(nombre: 'UTEZ', hora: '07:25'),
    ],
  );

  static final salidaLlena = Salida(
    id: 'SAL-003',
    rutaCodigo: 'R02',
    rutaNombre: 'Jiutepec — UTEZ',
    fecha: DateTime(2026, 10, 26),
    horaSalida: '06:50',
    horaLlegada: '07:20',
    unidad: 'Combi 03',
    operador: 'Jorge R.',
    cupoTotal: 16,
    reservados: 16,
    paradas: const [
      Parada(nombre: 'Jiutepec', hora: '06:50'),
      Parada(nombre: 'UTEZ', hora: '07:20'),
    ],
  );

  static const pago = Pago(
    monto: 20,
    referencia: 'DEMO-P1048',
    metodo: 'Tarjeta demo',
    estado: EstadoPago.aprobado,
  );

  static final activa = Reserva(
    folio: 'UTEZ-1048',
    salida: salida,
    parada: salida.paradas.first,
    estado: EstadoReserva.reservada,
    pago: pago,
  );

  static final abordada = Reserva(
    folio: 'UTEZ-1031',
    salida: salida,
    parada: salida.paradas.first,
    estado: EstadoReserva.abordada,
    pago: pago,
  );

  static final cancelada = Reserva(
    folio: 'UTEZ-1022',
    salida: salida,
    parada: salida.paradas.first,
    estado: EstadoReserva.cancelada,
    pago: pago,
  );
}

class FakeReservationsRepository implements ReservationsRepository {
  FakeReservationsRepository({
    List<Salida>? salidas,
    List<Reserva>? reservas,
    this.failure,
    this.actionFailure,
  }) : salidas = salidas ?? [FixturesEstudiante.salida],
       reservas = reservas ?? [FixturesEstudiante.activa];

  List<Salida> salidas;
  List<Reserva> reservas;

  /// Falla al leer (salidas, reservas, detalle).
  AppFailure? failure;

  /// Falla al reservar o cancelar.
  AppFailure? actionFailure;

  String? ultimoMotivo;

  @override
  Future<ReservasResult<List<Salida>>> fetchSalidas() async =>
      failure != null ? (value: null, failure: failure) : (value: salidas, failure: null);

  @override
  Future<ReservasResult<List<Reserva>>> fetchMisReservas() async =>
      failure != null ? (value: null, failure: failure) : (value: reservas, failure: null);

  @override
  Future<ReservasResult<Reserva>> fetchReserva(String folio) async {
    if (failure != null) return (value: null, failure: failure);
    for (final r in reservas) {
      if (r.folio == folio) return (value: r, failure: null);
    }
    return (value: null, failure: const GenericFailure('No encontramos esa reserva.'));
  }

  @override
  Future<ReservasResult<Reserva>> reservar({
    required String salidaId,
    required String parada,
  }) async {
    if (actionFailure != null) return (value: null, failure: actionFailure);
    final salida = salidas.firstWhere((s) => s.id == salidaId);
    final nueva = Reserva(
      folio: 'UTEZ-2000',
      salida: salida,
      parada: salida.paradas.firstWhere((p) => p.nombre == parada),
      estado: EstadoReserva.reservada,
      pago: FixturesEstudiante.pago,
    );
    reservas = [nueva, ...reservas];
    return (value: nueva, failure: null);
  }

  @override
  Future<ReservasResult<Reserva>> cancelar({
    required String folio,
    required String motivo,
  }) async {
    if (actionFailure != null) return (value: null, failure: actionFailure);
    ultimoMotivo = motivo;
    final actual = reservas.firstWhere((r) => r.folio == folio);
    final cancelada = actual.copyWith(estado: EstadoReserva.cancelada);
    reservas = [for (final r in reservas) r.folio == folio ? cancelada : r];
    return (value: cancelada, failure: null);
  }
}
