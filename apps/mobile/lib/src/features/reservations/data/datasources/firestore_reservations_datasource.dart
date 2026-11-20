import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../auth/data/datasources/firestore_failures.dart';
import '../../domain/entities/reserva.dart';
import '../../domain/entities/salida.dart';
import '../models/reserva_firestore_mapper.dart';
import 'reservations_datasource.dart';

/// Fuente Firestore de reservas del estudiante.
///
/// Cupo atómico con transacción (crear/cancelar). El pago aprobado y el QR
/// siguen siendo responsabilidad de Cloud Functions (D-05, D-06).
class FirestoreReservationsDataSource implements ReservationsDataSource {
  FirestoreReservationsDataSource({
    required this.firestore,
    required this.currentUid,
    this.cobroActivo = true,
  });

  final FirebaseFirestore firestore;

  /// Uid de la sesión activa. Si es null, no hay usuario autenticado.
  final String? Function() currentUid;

  /// Si es true, crea la reserva en `pendientePago` (checkout MP).
  /// Si es false, modo gratuito: `reservada` sin pasar por Mercado Pago.
  final bool cobroActivo;

  CollectionReference<Map<String, dynamic>> get _salidas =>
      firestore.collection('salidas');

  CollectionReference<Map<String, dynamic>> get _reservas =>
      firestore.collection('reservas');

  CollectionReference<Map<String, dynamic>> get _rutas =>
      firestore.collection('rutas');

  CollectionReference<Map<String, dynamic>> get _paradas =>
      firestore.collection('paradas');

  CollectionReference<Map<String, dynamic>> get _usuarios =>
      firestore.collection('usuarios');

  CollectionReference<Map<String, dynamic>> get _pagos =>
      firestore.collection('pagos');

  String _requireUid() {
    final uid = currentUid();
    if (uid == null || uid.isEmpty) {
      throw const GenericFailure('Debes iniciar sesión para continuar.');
    }
    return uid;
  }

  @override
  Future<List<Salida>> fetchSalidas() async {
    try {
      final snap = await _salidas
          .where('estado', isEqualTo: 'programada')
          .orderBy('fechaHoraSalida')
          .get();
      final salidas = <Salida>[];
      for (final doc in snap.docs) {
        final salida = await _hidratarSalida(doc.id, doc.data());
        if (salida != null) {
          salidas.add(salida);
        }
      }
      return salidas;
    } on FirebaseException catch (e) {
      throw firestoreFailureDesde(e.code);
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const FirestoreFailure();
    }
  }

  @override
  Future<List<Reserva>> fetchMisReservas() async {
    try {
      final uid = _requireUid();
      final snap = await _reservas
          .where('estudianteId', isEqualTo: uid)
          .orderBy('creadaEn', descending: true)
          .get();
      final reservas = <Reserva>[];
      for (final doc in snap.docs) {
        final reserva = await _hidratarReserva(doc.id, doc.data());
        if (reserva != null) {
          reservas.add(reserva);
        }
      }
      return reservas;
    } on FirebaseException catch (e) {
      throw firestoreFailureDesde(e.code);
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const FirestoreFailure();
    }
  }

  @override
  Future<Reserva> fetchReserva(String folio) async {
    try {
      final uid = _requireUid();
      final snap = await _reservas.doc(folio).get();
      final data = snap.data();
      if (!snap.exists || data == null) {
        throw const GenericFailure('No encontramos esa reserva.');
      }
      if (data['estudianteId'] != uid) {
        throw const GenericFailure('No encontramos esa reserva.');
      }
      final reserva = await _hidratarReserva(snap.id, data);
      if (reserva == null) {
        throw const GenericFailure('No encontramos esa reserva.');
      }
      return reserva;
    } on FirebaseException catch (e) {
      throw firestoreFailureDesde(e.code);
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const FirestoreFailure();
    }
  }

  @override
  Future<Reserva> reservar({
    required String salidaId,
    required String parada,
  }) async {
    try {
      final uid = _requireUid();
      final reservaId = '${salidaId}_$uid';
      final salidaRef = _salidas.doc(salidaId);
      final reservaRef = _reservas.doc(reservaId);

      // Lecturas auxiliares fuera de la transacción (ruta/paradas).
      final salidaPrevia = await salidaRef.get();
      final salidaPreviaData = salidaPrevia.data();
      if (!salidaPrevia.exists || salidaPreviaData == null) {
        throw const GenericFailure('No encontramos esa salida.');
      }
      final rutaId = salidaPreviaData['rutaId'];
      if (rutaId is! String || rutaId.isEmpty) {
        throw const GenericFailure('No encontramos esa salida.');
      }
      final paradaId = await _resolverParadaId(
        rutaId: rutaId,
        nombreParada: parada,
      );

      await firestore.runTransaction((tx) async {
        final salidaSnap = await tx.get(salidaRef);
        final salidaData = salidaSnap.data();
        if (!salidaSnap.exists || salidaData == null) {
          throw const GenericFailure('No encontramos esa salida.');
        }
        if (salidaData['estado'] != 'programada') {
          throw const GenericFailure(
            'Esta salida ya no admite reservas.',
          );
        }
        final disponibles = salidaData['asientosDisponibles'];
        if (disponibles is! num || disponibles.toInt() <= 0) {
          throw const GenericFailure(
            'Ya no hay lugares en esta salida. Elige otra.',
          );
        }

        final existente = await tx.get(reservaRef);
        if (existente.exists) {
          final estado = existente.data()?['estado'];
          if (estado == 'pendientePago' || estado == 'reservada') {
            throw const GenericFailure('Ya tienes una reserva en esta salida.');
          }
        }

        // Cobro: pendientePago → webhook Function aprueba.
        // Sin cobro (flag): reservada directa.
        tx.set(reservaRef, {
          'salidaId': salidaId,
          'estudianteId': uid,
          'paradaId': paradaId,
          'estado': cobroActivo ? 'pendientePago' : 'reservada',
          'creadaEn': FieldValue.serverTimestamp(),
          'actualizadoEn': FieldValue.serverTimestamp(),
        });
        tx.update(salidaRef, {
          'asientosDisponibles': disponibles.toInt() - 1,
          'actualizadoEn': FieldValue.serverTimestamp(),
        });
      });

      return await fetchReserva(reservaId);
    } on FirebaseException catch (e) {
      throw firestoreFailureDesde(e.code);
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const FirestoreFailure();
    }
  }

  @override
  Future<Reserva> cancelar({
    required String folio,
    required String motivo,
  }) async {
    try {
      final uid = _requireUid();
      final reservaRef = _reservas.doc(folio);

      await firestore.runTransaction((tx) async {
        final reservaSnap = await tx.get(reservaRef);
        final data = reservaSnap.data();
        if (!reservaSnap.exists || data == null) {
          throw const GenericFailure('No encontramos esa reserva.');
        }
        if (data['estudianteId'] != uid) {
          throw const GenericFailure('No encontramos esa reserva.');
        }
        final estado = data['estado'];
        if (estado != 'pendientePago' && estado != 'reservada') {
          throw const GenericFailure('Esta reserva ya no se puede cancelar.');
        }
        final salidaId = data['salidaId'];
        if (salidaId is! String || salidaId.isEmpty) {
          throw const GenericFailure('No encontramos esa reserva.');
        }

        final salidaRef = _salidas.doc(salidaId);
        final salidaSnap = await tx.get(salidaRef);
        final salidaData = salidaSnap.data();
        final disponibles = salidaData?['asientosDisponibles'];

        tx.update(reservaRef, {
          'estado': 'cancelada',
          'motivoCancelacion': motivo.trim(),
          'actualizadoEn': FieldValue.serverTimestamp(),
        });
        if (salidaSnap.exists && disponibles is num) {
          tx.update(salidaRef, {
            'asientosDisponibles': disponibles.toInt() + 1,
            'actualizadoEn': FieldValue.serverTimestamp(),
          });
        }
      });

      return await fetchReserva(folio);
    } on FirebaseException catch (e) {
      throw firestoreFailureDesde(e.code);
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const FirestoreFailure();
    }
  }

  Future<Salida?> _hidratarSalida(
    String id,
    Map<String, dynamic> data,
  ) async {
    final rutaId = data['rutaId'];
    Map<String, dynamic>? ruta;
    var paradasDocs = <({String id, Map<String, dynamic> data})>[];
    if (rutaId is String && rutaId.isNotEmpty) {
      final rutaSnap = await _rutas.doc(rutaId).get();
      ruta = rutaSnap.data();
      final paradasSnap = await _paradas
          .where('rutaId', isEqualTo: rutaId)
          .orderBy('orden')
          .get();
      paradasDocs = [
        for (final p in paradasSnap.docs) (id: p.id, data: p.data()),
      ];
    }

    String? nombreOperador;
    final operadorId = data['operadorId'];
    if (operadorId is String && operadorId.isNotEmpty) {
      final op = await _usuarios.doc(operadorId).get();
      final nombre = op.data()?['nombreCompleto'];
      if (nombre is String) {
        nombreOperador = nombre;
      }
    }

    return ReservaFirestoreMapper.salidaDesde(
      id: id,
      data: data,
      ruta: ruta,
      paradas: paradasDocs,
      nombreOperador: nombreOperador,
    );
  }

  Future<Reserva?> _hidratarReserva(
    String id,
    Map<String, dynamic> data,
  ) async {
    final salidaId = data['salidaId'];
    if (salidaId is! String || salidaId.isEmpty) {
      return null;
    }
    final salidaSnap = await _salidas.doc(salidaId).get();
    final salidaData = salidaSnap.data();
    if (!salidaSnap.exists || salidaData == null) {
      return null;
    }
    final salida = await _hidratarSalida(salidaId, salidaData);
    if (salida == null) {
      return null;
    }

    final paradaId = data['paradaId'];
    Parada parada = salida.paradas.first;
    if (paradaId is String && paradaId.isNotEmpty) {
      final paradaSnap = await _paradas.doc(paradaId).get();
      final nombre = paradaSnap.data()?['nombre'];
      if (nombre is String && nombre.trim().isNotEmpty) {
        parada = salida.paradas.firstWhere(
          (p) => p.nombre == nombre.trim(),
          orElse: () => Parada(nombre: nombre.trim(), hora: salida.horaSalida),
        );
      }
    }

    final pagoSnap = await _pagos
        .where('reservaId', isEqualTo: id)
        .limit(1)
        .get();
    final pagoData =
        pagoSnap.docs.isEmpty ? null : pagoSnap.docs.first.data();

    return ReservaFirestoreMapper.reservaDesde(
      id: id,
      data: data,
      salida: salida,
      parada: parada,
      pago: ReservaFirestoreMapper.pagoDesde(
        pagoData,
        fallbackMonto: salida.precio,
      ),
    );
  }

  Future<String> _resolverParadaId({
    required String rutaId,
    required String nombreParada,
  }) async {
    final snap = await _paradas.where('rutaId', isEqualTo: rutaId).get();
    for (final doc in snap.docs) {
      final nombre = doc.data()['nombre'];
      if (nombre is String &&
          nombre.trim().toLowerCase() == nombreParada.trim().toLowerCase()) {
        return doc.id;
      }
    }
    if (snap.docs.isNotEmpty) {
      return snap.docs.first.id;
    }
    throw const GenericFailure('No encontramos esa parada.');
  }
}
