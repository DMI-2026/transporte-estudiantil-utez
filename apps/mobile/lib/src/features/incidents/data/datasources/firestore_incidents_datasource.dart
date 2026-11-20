import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../auth/data/datasources/firestore_failures.dart';
import '../../domain/entities/reporte.dart';
import '../models/reporte_firestore_mapper.dart';
import 'incidents_datasource.dart';

/// Reportes del estudiante en Firestore; evidencia opcional en Storage.
///
/// Ruta Storage: `reportes/{uid}/{reporteId}/{fileName}` (storage.rules).
class FirestoreIncidentsDataSource implements IncidentsDataSource {
  FirestoreIncidentsDataSource({
    required this.firestore,
    required this.storage,
    required this.currentUid,
  });

  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final String? Function() currentUid;

  CollectionReference<Map<String, dynamic>> get _reportes =>
      firestore.collection('reportes');

  String _requireUid() {
    final uid = currentUid();
    if (uid == null || uid.isEmpty) {
      throw const GenericFailure('Debes iniciar sesión para continuar.');
    }
    return uid;
  }

  @override
  Future<List<Reporte>> fetchMisReportes() async {
    try {
      final uid = _requireUid();
      final snap = await _reportes
          .where('reportadoPor', isEqualTo: uid)
          .orderBy('creadoEn', descending: true)
          .get();
      final lista = <Reporte>[];
      for (final doc in snap.docs) {
        final reporte = ReporteFirestoreMapper.desde(
          id: doc.id,
          data: doc.data(),
        );
        if (reporte != null) {
          lista.add(reporte);
        }
      }
      return lista;
    } on AppFailure {
      rethrow;
    } on FirebaseException catch (e) {
      throw firestoreFailureDesde(e.code);
    } catch (_) {
      throw const FirestoreFailure();
    }
  }

  @override
  Future<Reporte> enviar(NuevoReporte reporte) async {
    try {
      final uid = _requireUid();
      final doc = _reportes.doc();
      final salidaId =
          ReporteFirestoreMapper.salidaIdDesdeReferencia(reporte.referencia);

      String? fotoUrl;
      final evidenciaLocal = reporte.evidencia;
      if (evidenciaLocal != null &&
          evidenciaLocal.isNotEmpty &&
          File(evidenciaLocal).existsSync()) {
        final nombre = evidenciaLocal.split(RegExp(r'[\\/]')).last;
        final ref = storage.ref('reportes/$uid/${doc.id}/$nombre');
        await ref.putFile(File(evidenciaLocal));
        fotoUrl = await ref.getDownloadURL();
      }

      final data = <String, dynamic>{
        'reportadoPor': uid,
        'tipo': reporte.tipo,
        'descripcion': reporte.descripcion.trim(),
        'estado': 'abierto',
        'creadoEn': FieldValue.serverTimestamp(),
        'salidaId': ?salidaId,
        'fotoUrl': ?fotoUrl,
      };
      await doc.set(data);

      final leido = await doc.get();
      final map = Map<String, dynamic>.from(leido.data() ?? data);
      // serverTimestamp aún puede ser null en el snapshot inmediato
      map['creadoEn'] ??= Timestamp.now();
      final creado = ReporteFirestoreMapper.desde(id: doc.id, data: map);
      if (creado == null) {
        throw const GenericFailure('No se pudo registrar el reporte.');
      }
      return creado;
    } on AppFailure {
      rethrow;
    } on FirebaseException catch (e) {
      throw firestoreFailureDesde(e.code);
    } catch (_) {
      throw const FirestoreFailure();
    }
  }
}
