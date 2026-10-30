// Modelos compartidos Usuario/Rol - sincronizar con functions/src/models/usuarios.ts

enum UserRole { estudiante, operador, admin }

enum VerificationStatus { pendiente, aprobada, rechazada }

/// Custom claims que se guardan en Firebase Auth
class UserCustomClaims {
  final UserRole rol;
  final bool verificado;
  final String? operadorSalidaId; // Para reglas de QR privado

  const UserCustomClaims({
    required this.rol,
    required this.verificado,
    this.operadorSalidaId,
  });

  Map<String, dynamic> toJson() => {
        'rol': rol.name,
        'verificado': verificado,
        if (operadorSalidaId != null) 'operadorSalidaId': operadorSalidaId,
      };

  factory UserCustomClaims.fromJson(Map<String, dynamic> json) =>
      UserCustomClaims(
        rol: UserRole.values.firstWhere((r) => r.name == json['rol']),
        verificado: json['verificado'] as bool,
        operadorSalidaId: json['operadorSalidaId'] as String?,
      );
}

/// Documento de usuario en Firestore (colección 'usuarios')
class UserDocument {
  final String uid;
  final String email;
  final String? displayName;
  final UserRole rol;
  final VerificationStatus estadoVerificacion;
  final String? fotoCredencialUrl;
  final DateTime creadoEn;
  final DateTime actualizadoEn;
  final DateTime? aprobadoEn;
  final String? aprobadoPor;
  final DateTime? rechazadoEn;
  final String? rechazadoPor;
  final String? motivoRechazo;

  const UserDocument({
    required this.uid,
    required this.email,
    this.displayName,
    required this.rol,
    required this.estadoVerificacion,
    this.fotoCredencialUrl,
    required this.creadoEn,
    required this.actualizadoEn,
    this.aprobadoEn,
    this.aprobadoPor,
    this.rechazadoEn,
    this.rechazadoPor,
    this.motivoRechazo,
  });
}

/// Token de dispositivo para FCM
class DeviceTokenDocument {
  final String token;
  final String plataforma; // 'android', 'ios', 'web'
  final String appVersion;
  final DateTime registradoEn;
  final DateTime ultimoUsoEn;

  const DeviceTokenDocument({
    required this.token,
    required this.plataforma,
    required this.appVersion,
    required this.registradoEn,
    required this.ultimoUsoEn,
  });
}