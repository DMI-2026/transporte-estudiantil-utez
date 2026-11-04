import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/entities/verification_status.dart';

abstract final class AppUserMapper {
  static AppUser? fromFirestore(String uid, Map<String, dynamic>? data) {
    if (data == null) {
      return null;
    }
    final email = data['email'] as String?;
    final rol = data['rol'] as String?;
    final estado = data['estadoVerificacion'] as String?;
    if (email == null || rol == null || estado == null) {
      return null;
    }
    final role = UserRole.fromFirestore(rol);
    final status = VerificationStatus.fromFirestore(estado);
    if (role == null || status == null) {
      // Perfil corrupto o de una versión desconocida: no inventar permisos.
      return null;
    }
    return AppUser(
      uid: uid,
      email: email,
      role: role,
      verificationStatus: status,
      displayName: data['nombreCompleto'] as String?,
    );
  }

  static Map<String, Object?> newProfile({
    required String email,
    required String displayName,
    required UserRole role,
    Object? creadoEn,
  }) {
    return {
      'email': email.trim(),
      'nombreCompleto': displayName.trim(),
      'rol': role.firestoreValue,
      'estadoVerificacion': VerificationStatus.pendiente.firestoreValue,
      'creadoEn': creadoEn ?? FieldValue.serverTimestamp(),
    };
  }
}
