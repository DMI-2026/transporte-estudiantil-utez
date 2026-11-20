import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/reserva.dart';
import '../../domain/entities/salida.dart';

/// Traduce documentos de Firestore al modelo de UI de reservas.
///
/// Campos canónicos: [docs/05-datos.md]. El folio de la app es el id
/// del documento `reservas/{salidaId}_{uid}`.
abstract final class ReservaFirestoreMapper {
  static EstadoReserva? estadoReservaDesde(String? raw) => switch (raw) {
        'pendientePago' => EstadoReserva.pendientePago,
        'reservada' => EstadoReserva.reservada,
        'abordada' => EstadoReserva.abordada,
        'cancelada' => EstadoReserva.cancelada,
        _ => null,
      };

  static EstadoPago? estadoPagoDesde(String? raw) => switch (raw) {
        'pendiente' => EstadoPago.pendiente,
        'aprobado' => EstadoPago.aprobado,
        'reembolsado' => EstadoPago.reembolsado,
        _ => null,
      };

  static String estadoReservaFirestore(EstadoReserva estado) => switch (estado) {
        EstadoReserva.pendientePago => 'pendientePago',
        EstadoReserva.reservada => 'reservada',
        EstadoReserva.abordada => 'abordada',
        EstadoReserva.cancelada => 'cancelada',
      };

  static DateTime? fechaDesde(Object? raw) {
    if (raw is Timestamp) {
      return raw.toDate();
    }
    if (raw is DateTime) {
      return raw;
    }
    return null;
  }

  static String horaDesde(DateTime fecha) {
    final h = fecha.hour.toString().padLeft(2, '0');
    final m = fecha.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Construye la [Salida] de UI a partir de salida + ruta + paradas + operador.
  static Salida? salidaDesde({
    required String id,
    required Map<String, dynamic> data,
    required Map<String, dynamic>? ruta,
    required List<({String id, Map<String, dynamic> data})> paradas,
    required String? nombreOperador,
  }) {
    final fecha = fechaDesde(data['fechaHoraSalida']);
    if (fecha == null) {
      return null;
    }
    final totales = data['asientosTotales'];
    final disponibles = data['asientosDisponibles'];
    if (totales is! num || disponibles is! num) {
      return null;
    }
    final cupoTotal = totales.toInt();
    final libres = disponibles.toInt();
    if (cupoTotal < 0 || libres < 0 || libres > cupoTotal) {
      return null;
    }

    final rutaNombre = ruta?['nombre'];
    final nombre = rutaNombre is String && rutaNombre.trim().isNotEmpty
        ? rutaNombre.trim()
        : 'Ruta';
    final codigo = _codigoRuta(id: id, nombre: nombre, rutaId: data['rutaId']);

    final horaSalida = horaDesde(fecha);
    final listaParadas = <Parada>[];
    for (var i = 0; i < paradas.length; i++) {
      final nombreParada = paradas[i].data['nombre'];
      if (nombreParada is! String || nombreParada.trim().isEmpty) {
        continue;
      }
      final estimada = fecha.add(Duration(minutes: i * 12));
      listaParadas.add(
        Parada(nombre: nombreParada.trim(), hora: horaDesde(estimada)),
      );
    }
    if (listaParadas.isEmpty) {
      listaParadas.add(Parada(nombre: 'Parada', hora: horaSalida));
    }

    final llegada = listaParadas.last.hora;
    final operador = (nombreOperador != null && nombreOperador.trim().isNotEmpty)
        ? nombreOperador.trim()
        : 'Operador';

    return Salida(
      id: id,
      rutaCodigo: codigo,
      rutaNombre: nombre,
      fecha: fecha,
      horaSalida: horaSalida,
      horaLlegada: llegada,
      unidad: 'Unidad',
      operador: operador,
      cupoTotal: cupoTotal,
      reservados: cupoTotal - libres,
      paradas: listaParadas,
    );
  }

  static Reserva? reservaDesde({
    required String id,
    required Map<String, dynamic> data,
    required Salida salida,
    required Parada parada,
    required Pago pago,
  }) {
    final estado = estadoReservaDesde(data['estado'] as String?);
    if (estado == null) {
      return null;
    }
    return Reserva(
      folio: id,
      salida: salida,
      parada: parada,
      estado: estado,
      pago: pago,
    );
  }

  static Pago pagoDesde(Map<String, dynamic>? data, {required double fallbackMonto}) {
    if (data == null) {
      return Pago(
        monto: fallbackMonto,
        referencia: '—',
        metodo: 'Pendiente',
        estado: EstadoPago.pendiente,
      );
    }
    final montoRaw = data['monto'];
    final monto = montoRaw is num ? montoRaw.toDouble() : fallbackMonto;
    final estado =
        estadoPagoDesde(data['estado'] as String?) ?? EstadoPago.pendiente;
    final referencia = data['externalId'];
    final metodo = data['proveedor'];
    return Pago(
      monto: monto,
      referencia: referencia is String && referencia.isNotEmpty
          ? referencia
          : '—',
      metodo: metodo is String && metodo.isNotEmpty ? metodo : 'Pendiente',
      estado: estado,
    );
  }

  static String _codigoRuta({
    required String id,
    required String nombre,
    required Object? rutaId,
  }) {
    if (rutaId is String && rutaId.isNotEmpty) {
      final corto = rutaId.length <= 6 ? rutaId : rutaId.substring(0, 6);
      return corto.toUpperCase();
    }
    final letras = nombre.replaceAll(RegExp(r'[^A-Za-zÁÉÍÓÚáéíóú]'), '');
    if (letras.length >= 3) {
      return letras.substring(0, 3).toUpperCase();
    }
    return id.length <= 4 ? id.toUpperCase() : id.substring(0, 4).toUpperCase();
  }
}
