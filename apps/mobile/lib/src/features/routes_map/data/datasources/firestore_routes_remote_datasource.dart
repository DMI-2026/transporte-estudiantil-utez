import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../auth/data/datasources/firestore_failures.dart';
import '../../domain/entities/bus_route.dart';
import 'routes_remote_datasource.dart';

class FirestoreRoutesRemoteDataSource implements RoutesRemoteDataSource {
  FirestoreRoutesRemoteDataSource(this.firestore);

  final FirebaseFirestore firestore;

  static const demoNombre = 'Ruta de prueba';
  static const demoDescripcion = 'Creada desde la app para comprobar permisos';

  CollectionReference<Map<String, dynamic>> get _rutas =>
      firestore.collection('rutas');

  @override
  Future<List<BusRoute>> fetchRoutes() async {
    try {
      final snap = await _rutas.get();
      return [for (final doc in snap.docs) ?_routeFrom(doc)];
    } on FirebaseException catch (e) {
      throw firestoreFailureDesde(e.code);
    } catch (_) {
      throw const FirestoreFailure();
    }
  }

  @override
  Future<BusRoute> createDemoRoute() async {
    try {
      final ref = _rutas.doc();
      await ref.set({
        'nombre': demoNombre,
        'descripcion': demoDescripcion,
        'activa': true,
        'creadoEn': FieldValue.serverTimestamp(),
        'actualizadoEn': FieldValue.serverTimestamp(),
      });
      return BusRoute(
        id: ref.id,
        nombre: demoNombre,
        descripcion: demoDescripcion,
      );
    } on FirebaseException catch (e) {
      throw firestoreFailureDesde(e.code);
    } catch (_) {
      throw const FirestoreFailure();
    }
  }

  BusRoute? _routeFrom(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final nombre = doc.data()['nombre'];
    if (nombre is! String || nombre.trim().isEmpty) {
      return null;
    }
    final descripcion = doc.data()['descripcion'];
    return BusRoute(
      id: doc.id,
      nombre: nombre,
      descripcion: descripcion is String ? descripcion : null,
    );
  }
}
