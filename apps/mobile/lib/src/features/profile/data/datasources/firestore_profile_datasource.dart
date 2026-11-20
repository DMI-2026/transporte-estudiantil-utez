import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../auth/data/datasources/firestore_failures.dart';
import '../../domain/entities/perfil_estudiante.dart';
import '../models/perfil_firestore_mapper.dart';
import 'profile_datasource.dart';

/// Perfil del estudiante en `usuarios/{uid}`.
///
/// Solo escribe teléfono, contacto de emergencia y preferencias; no toca
/// `rol`, `estadoVerificacion`, `email` ni `creadoEn`.
class FirestoreProfileDataSource implements ProfileDataSource {
  FirestoreProfileDataSource({
    required this.firestore,
    required this.currentUid,
  });

  final FirebaseFirestore firestore;

  /// Uid de la sesión activa. Si es null, no hay usuario autenticado.
  final String? Function() currentUid;

  CollectionReference<Map<String, dynamic>> get _usuarios =>
      firestore.collection('usuarios');

  String _requireUid() {
    final uid = currentUid();
    if (uid == null || uid.isEmpty) {
      throw const GenericFailure('Debes iniciar sesión para continuar.');
    }
    return uid;
  }

  DocumentReference<Map<String, dynamic>> _doc() =>
      _usuarios.doc(_requireUid());

  @override
  Future<PerfilEstudiante> fetchPerfil() async {
    try {
      final snap = await _doc().get();
      final data = snap.data();
      if (data == null) {
        throw const GenericFailure('No se encontró el perfil.');
      }
      final perfil = PerfilFirestoreMapper.perfilDesde(data);
      if (perfil == null) {
        throw const GenericFailure('El perfil no es válido.');
      }
      return perfil;
    } on AppFailure {
      rethrow;
    } on FirebaseException catch (e) {
      throw firestoreFailureDesde(e.code);
    } catch (_) {
      throw const FirestoreFailure();
    }
  }

  @override
  Future<PerfilEstudiante> guardarContacto({
    required String telefono,
    required ContactoEmergencia contactoEmergencia,
  }) async {
    try {
      await _doc().update({
        'telefono': telefono,
        'contactoEmergencia':
            PerfilFirestoreMapper.contactoAFirestore(contactoEmergencia),
        'actualizadoEn': FieldValue.serverTimestamp(),
      });
      return await fetchPerfil();
    } on AppFailure {
      rethrow;
    } on FirebaseException catch (e) {
      throw firestoreFailureDesde(e.code);
    } catch (_) {
      throw const FirestoreFailure();
    }
  }

  @override
  Future<PreferenciasNotificacion> fetchPreferencias() async {
    try {
      final snap = await _doc().get();
      final data = snap.data();
      if (data == null) {
        throw const GenericFailure('No se encontró el perfil.');
      }
      return PerfilFirestoreMapper.preferenciasDesde(
        data['preferenciasNotificacion'],
      );
    } on AppFailure {
      rethrow;
    } on FirebaseException catch (e) {
      throw firestoreFailureDesde(e.code);
    } catch (_) {
      throw const FirestoreFailure();
    }
  }

  @override
  Future<PreferenciasNotificacion> guardarPreferencias(
    PreferenciasNotificacion preferencias,
  ) async {
    try {
      await _doc().update({
        'preferenciasNotificacion':
            PerfilFirestoreMapper.preferenciasAFirestore(preferencias),
        'actualizadoEn': FieldValue.serverTimestamp(),
      });
      return preferencias;
    } on AppFailure {
      rethrow;
    } on FirebaseException catch (e) {
      throw firestoreFailureDesde(e.code);
    } catch (_) {
      throw const FirestoreFailure();
    }
  }
}
