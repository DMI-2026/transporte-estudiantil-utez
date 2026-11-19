import '../../../../core/errors/app_failure.dart';
import '../../domain/entities/reserva.dart';
import '../../domain/entities/salida.dart';
import 'reservations_datasource.dart';

/// Datos de DEMOSTRACIÓN en memoria con los ejemplos del Figma del
/// estudiante. No usa Firebase: sirve para revisar la UI mientras el
/// backend de reservas (issue #9) no existe. Se reemplaza en `injection.dart`.
class DemoReservationsDataSource implements ReservationsDataSource {
  DemoReservationsDataSource({this.latencia = const Duration(milliseconds: 400)}) {
    _reservas.addAll(_reservasIniciales());
  }

  final Duration latencia;

  static final fechaDemo = DateTime(2026, 10, 26);

  static const _paradasR01Manana = [
    Parada(nombre: 'Centro', hora: '06:40'),
    Parada(nombre: 'Las Palmas', hora: '06:52'),
    Parada(nombre: 'Temixco Centro', hora: '07:10'),
    Parada(nombre: 'UTEZ', hora: '07:25'),
  ];

  final Map<String, Salida> _salidas = {
    'SAL-001': Salida(
      id: 'SAL-001',
      rutaCodigo: 'R01',
      rutaNombre: 'Centro de Cuernavaca — UTEZ',
      fecha: fechaDemo,
      horaSalida: '06:40',
      horaLlegada: '07:25',
      unidad: 'Combi 01',
      operador: 'Carlos M.',
      cupoTotal: 16,
      reservados: 11,
      paradas: _paradasR01Manana,
    ),
    'SAL-002': Salida(
      id: 'SAL-002',
      rutaCodigo: 'R01',
      rutaNombre: 'Centro de Cuernavaca — UTEZ',
      fecha: fechaDemo,
      horaSalida: '13:10',
      horaLlegada: '13:55',
      unidad: 'Combi 02',
      operador: 'Laura P.',
      cupoTotal: 16,
      reservados: 14,
      paradas: const [
        Parada(nombre: 'Centro', hora: '13:10'),
        Parada(nombre: 'Las Palmas', hora: '13:22'),
        Parada(nombre: 'Temixco Centro', hora: '13:40'),
        Parada(nombre: 'UTEZ', hora: '13:55'),
      ],
    ),
    'SAL-003': Salida(
      id: 'SAL-003',
      rutaCodigo: 'R02',
      rutaNombre: 'Jiutepec — UTEZ',
      fecha: fechaDemo,
      horaSalida: '06:50',
      horaLlegada: '07:20',
      unidad: 'Combi 03',
      operador: 'Jorge R.',
      cupoTotal: 16,
      reservados: 16,
      paradas: const [
        Parada(nombre: 'Jiutepec', hora: '06:50'),
        Parada(nombre: 'Tejalpa', hora: '07:02'),
        Parada(nombre: 'UTEZ', hora: '07:20'),
      ],
    ),
  };

  final List<Reserva> _reservas = [];
  int _siguienteFolio = 1049;

  static const _pagoDemo = Pago(
    monto: 20,
    referencia: 'DEMO-P1048',
    metodo: 'Tarjeta de demostración ••••4242',
    estado: EstadoPago.aprobado,
  );

  List<Reserva> _reservasIniciales() {
    Salida pasada(int dia) => Salida(
      id: 'SAL-H$dia',
      rutaCodigo: 'R01',
      rutaNombre: 'Centro de Cuernavaca — UTEZ',
      fecha: DateTime(2026, 10, dia),
      horaSalida: '06:40',
      horaLlegada: '07:25',
      unidad: 'Combi 01',
      operador: 'Carlos M.',
      cupoTotal: 16,
      reservados: 16,
      paradas: _paradasR01Manana,
    );
    return [
      Reserva(
        folio: 'UTEZ-1048',
        salida: _salidas['SAL-001']!,
        parada: _paradasR01Manana.first,
        estado: EstadoReserva.reservada,
        pago: _pagoDemo,
      ),
      Reserva(
        folio: 'UTEZ-1031',
        salida: pasada(23),
        parada: _paradasR01Manana.first,
        estado: EstadoReserva.abordada,
        pago: _pagoDemo,
        abordadaA: '06:38',
      ),
      Reserva(
        folio: 'UTEZ-1022',
        salida: pasada(22),
        parada: _paradasR01Manana.first,
        estado: EstadoReserva.cancelada,
        pago: const Pago(
          monto: 20,
          referencia: 'DEMO-P1022',
          metodo: 'Tarjeta de demostración ••••4242',
          estado: EstadoPago.reembolsado,
        ),
      ),
    ];
  }

  Future<void> _red() => Future<void>.delayed(latencia);

  @override
  Future<List<Salida>> fetchSalidas() async {
    await _red();
    return _salidas.values.toList();
  }

  @override
  Future<List<Reserva>> fetchMisReservas() async {
    await _red();
    return List.unmodifiable(_reservas);
  }

  @override
  Future<Reserva> fetchReserva(String folio) async {
    await _red();
    return _buscar(folio);
  }

  @override
  Future<Reserva> reservar({
    required String salidaId,
    required String parada,
  }) async {
    await _red();
    final salida = _salidas[salidaId];
    if (salida == null) {
      throw const GenericFailure('No encontramos esa salida.');
    }
    if (salida.llena) {
      throw const GenericFailure(
        'Ya no hay lugares en esta salida. Elige otra.',
      );
    }
    final yaReservada = _reservas.any(
      (r) => r.salida.id == salidaId && r.activa,
    );
    if (yaReservada) {
      throw const GenericFailure('Ya tienes una reserva en esta salida.');
    }
    final actualizada = salida.copyWith(reservados: salida.reservados + 1);
    _salidas[salidaId] = actualizada;
    final folio = 'UTEZ-${_siguienteFolio++}';
    final reserva = Reserva(
      folio: folio,
      salida: actualizada,
      parada: actualizada.paradas.firstWhere(
        (p) => p.nombre == parada,
        orElse: () => actualizada.paradas.first,
      ),
      // En la demo el pago se aprueba al instante.
      estado: EstadoReserva.reservada,
      pago: Pago(
        monto: actualizada.precio,
        referencia: 'DEMO-P${folio.substring(5)}',
        metodo: 'Tarjeta de demostración ••••4242',
        estado: EstadoPago.aprobado,
      ),
    );
    _reservas.insert(0, reserva);
    return reserva;
  }

  @override
  Future<Reserva> cancelar({
    required String folio,
    required String motivo,
  }) async {
    await _red();
    final actual = _buscar(folio);
    if (!actual.activa) {
      throw const GenericFailure('Esta reserva ya no se puede cancelar.');
    }
    final salida = _salidas[actual.salida.id];
    Salida? liberada;
    if (salida != null) {
      liberada = salida.copyWith(reservados: salida.reservados - actual.asientos);
      _salidas[salida.id] = liberada;
    }
    final cancelada = actual.copyWith(
      estado: EstadoReserva.cancelada,
      salida: liberada,
      pago: Pago(
        monto: actual.pago.monto,
        referencia: actual.pago.referencia,
        metodo: actual.pago.metodo,
        estado: EstadoPago.reembolsado,
      ),
    );
    _reservas[_reservas.indexOf(actual)] = cancelada;
    return cancelada;
  }

  Reserva _buscar(String folio) {
    for (final r in _reservas) {
      if (r.folio == folio) return r;
    }
    throw const GenericFailure('No encontramos esa reserva.');
  }
}
