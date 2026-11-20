import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/features/reservations/data/models/reserva_firestore_mapper.dart';
import 'package:transporte_estudiantil/src/features/reservations/domain/entities/reserva.dart';

void main() {
  group('ReservaFirestoreMapper', () {
    test('estadoReservaDesde reconoce los estados canónicos', () {
      expect(
        ReservaFirestoreMapper.estadoReservaDesde('pendientePago'),
        EstadoReserva.pendientePago,
      );
      expect(
        ReservaFirestoreMapper.estadoReservaDesde('reservada'),
        EstadoReserva.reservada,
      );
      expect(ReservaFirestoreMapper.estadoReservaDesde('otro'), isNull);
    });

    test('salidaDesde calcula cupo y hora a partir del documento', () {
      final fecha = DateTime(2026, 11, 20, 6, 40);
      final salida = ReservaFirestoreMapper.salidaDesde(
        id: 'demo-salida-manana',
        data: {
          'rutaId': 'demo-ruta',
          'fechaHoraSalida': Timestamp.fromDate(fecha),
          'asientosTotales': 40,
          'asientosDisponibles': 39,
        },
        ruta: {'nombre': 'UTEZ — Centro'},
        paradas: [
          (id: 'p1', data: {'nombre': 'Entrada UTEZ', 'orden': 1}),
          (id: 'p2', data: {'nombre': 'Centro', 'orden': 2}),
        ],
        nombreOperador: 'Luis Demo',
      );

      expect(salida, isNotNull);
      expect(salida!.cupoTotal, 40);
      expect(salida.reservados, 1);
      expect(salida.horaSalida, '06:40');
      expect(salida.operador, 'Luis Demo');
      expect(salida.paradas.map((p) => p.nombre), ['Entrada UTEZ', 'Centro']);
    });

    test('salidaDesde rechaza cupos inconsistentes', () {
      final salida = ReservaFirestoreMapper.salidaDesde(
        id: 's1',
        data: {
          'fechaHoraSalida': Timestamp.fromDate(DateTime(2026, 1, 1)),
          'asientosTotales': 10,
          'asientosDisponibles': 11,
        },
        ruta: {'nombre': 'Ruta'},
        paradas: const [],
        nombreOperador: null,
      );

      expect(salida, isNull);
    });

    test('pagoDesde usa fallback cuando no hay documento', () {
      final pago = ReservaFirestoreMapper.pagoDesde(
        null,
        fallbackMonto: 20,
      );

      expect(pago.monto, 20);
      expect(pago.estado, EstadoPago.pendiente);
    });

    test('reservaDesde arma el folio con el id del documento', () {
      final fecha = DateTime(2026, 11, 20, 6, 40);
      final salida = ReservaFirestoreMapper.salidaDesde(
        id: 'salida-1',
        data: {
          'fechaHoraSalida': Timestamp.fromDate(fecha),
          'asientosTotales': 16,
          'asientosDisponibles': 15,
        },
        ruta: {'nombre': 'R01'},
        paradas: [(id: 'p1', data: {'nombre': 'Centro'})],
        nombreOperador: 'Op',
      )!;

      final reserva = ReservaFirestoreMapper.reservaDesde(
        id: 'salida-1_uid',
        data: {'estado': 'reservada'},
        salida: salida,
        parada: salida.paradas.first,
        pago: const Pago(
          monto: 20,
          referencia: 'mp-1',
          metodo: 'mercadoPago',
          estado: EstadoPago.aprobado,
        ),
      );

      expect(reserva!.folio, 'salida-1_uid');
      expect(reserva.estado, EstadoReserva.reservada);
      expect(reserva.qrValido, isTrue);
    });
  });
}
