import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../auth/data/datasources/firestore_failures.dart';
import '../../../reservations/data/datasources/reservations_datasource.dart';
import '../../../reservations/domain/entities/reserva.dart';
import '../../domain/entities/viaje_en_curso.dart';
import '../../domain/repositories/trip_repository.dart';
import '../datasources/eta_gateway.dart';
import '../polyline_decoder.dart';

/// Viaje en curso desde reserva + salida `enCurso` + ETA callable.
class FirestoreTripRepository implements TripRepository {
  FirestoreTripRepository({
    required this.firestore,
    required this.reservas,
    required this.eta,
    required this.currentUid,
  });

  final FirebaseFirestore firestore;
  final ReservationsDataSource reservas;
  final EtaGateway eta;
  final String? Function() currentUid;

  @override
  Future<TripResult<ViajeEnCurso>> fetchViaje(String folio) async {
    try {
      final uid = currentUid();
      if (uid == null || uid.isEmpty) {
        return (
          value: null,
          failure: const GenericFailure('Debes iniciar sesión para continuar.'),
        );
      }

      final reserva = await reservas.fetchReserva(folio);
      if (reserva.estado != EstadoReserva.reservada &&
          reserva.estado != EstadoReserva.abordada) {
        return (
          value: null,
          failure: const GenericFailure(
            'Este viaje no está en curso. Revisa el estado de tu reserva.',
          ),
        );
      }

      final reservaSnap =
          await firestore.collection('reservas').doc(folio).get();
      final paradaId = reservaSnap.data()?['paradaId'];

      final salidaSnap =
          await firestore.collection('salidas').doc(reserva.salida.id).get();
      final salidaData = salidaSnap.data();
      if (salidaData == null) {
        return (
          value: null,
          failure: const GenericFailure('No encontramos la salida.'),
        );
      }

      final estadoSalida = salidaData['estado'] as String?;
      if (estadoSalida != 'enCurso' && estadoSalida != 'programada') {
        return (
          value: null,
          failure: const GenericFailure(
            'La unidad aún no ha iniciado el recorrido.',
          ),
        );
      }

      final combi = _puntoDesde(salidaData['ubicacionActual']);
      PuntoMapa? paradaPunto;
      if (paradaId is String && paradaId.isNotEmpty) {
        final paradaSnap =
            await firestore.collection('paradas').doc(paradaId).get();
        if (paradaSnap.exists) {
          paradaPunto = _puntoDesde(paradaSnap.data()?['ubicacion']);
        }
      }

      var polyline = <PuntoMapa>[];
      final rutaId = salidaData['rutaId'];
      if (rutaId is String && rutaId.isNotEmpty) {
        final rutaSnap = await firestore.collection('rutas').doc(rutaId).get();
        final encoded = rutaSnap.data()?['polyline'];
        if (encoded is String && encoded.isNotEmpty) {
          polyline = PolylineDecoder.decode(encoded);
        }
      }

      var minutos = 18;
      var actualizadoA = _horaAhora();
      try {
        final etaResult = await eta.obtenerEta(
          salidaId: reserva.salida.id,
          reservaId: folio,
        );
        minutos = etaResult.minutos;
        actualizadoA = etaResult.actualizadoA;
      } on AppFailure {
        // ETA opcional: el mapa sigue siendo útil sin minutos exactos.
      }

      final indice = _indiceParada(total: reserva.salida.paradas.length);

      return (
        value: ViajeEnCurso(
          reserva: reserva,
          indiceParadaActual: indice,
          minutosParaLlegar: minutos,
          actualizadoA: actualizadoA,
          ubicacionCombi: combi,
          ubicacionParada: paradaPunto,
          polyline: polyline,
        ),
        failure: null,
      );
    } on AppFailure catch (e) {
      return (value: null, failure: e);
    } on FirebaseException catch (e) {
      return (value: null, failure: firestoreFailureDesde(e.code));
    } catch (_) {
      return (value: null, failure: const GenericFailure());
    }
  }

  PuntoMapa? _puntoDesde(Object? raw) {
    if (raw is GeoPoint) {
      return PuntoMapa(latitud: raw.latitude, longitud: raw.longitude);
    }
    if (raw is Map) {
      final lat = raw['latitude'] ?? raw['lat'];
      final lng = raw['longitude'] ?? raw['lng'];
      if (lat is num && lng is num) {
        return PuntoMapa(latitud: lat.toDouble(), longitud: lng.toDouble());
      }
    }
    return null;
  }

  int _indiceParada({required int total}) {
    if (total <= 0) return 0;
    return total > 2 ? 1 : 0;
  }

  String _horaAhora() {
    final n = DateTime.now();
    final h = n.hour.toString().padLeft(2, '0');
    final m = n.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
