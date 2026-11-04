import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/features/auth/data/models/app_user_mapper.dart';
import 'package:transporte_estudiantil/src/features/auth/domain/entities/user_role.dart';
import 'package:transporte_estudiantil/src/features/auth/domain/entities/verification_status.dart';

void main() {
  group('AppUserMapper', () {
    test('fromFirestore arma el perfil con rol y verificación', () {
      final user = AppUserMapper.fromFirestore('u1', {
        'email': 'a@utez.edu.mx',
        'rol': 'estudiante',
        'estadoVerificacion': 'aprobada',
        'nombreCompleto': 'Ana',
      });

      expect(user, isNotNull);
      expect(user!.uid, 'u1');
      expect(user.role, UserRole.estudiante);
      expect(user.verificationStatus, VerificationStatus.aprobada);
      expect(user.displayName, 'Ana');
    });

    test('fromFirestore regresa null si faltan campos', () {
      expect(AppUserMapper.fromFirestore('u1', null), isNull);
      expect(AppUserMapper.fromFirestore('u1', {'email': 'a@x.com'}), isNull);
    });

    test('fromFirestore regresa null con rol o estado desconocidos', () {
      expect(
        AppUserMapper.fromFirestore('u1', {
          'email': 'a@utez.edu.mx',
          'rol': 'superusuario',
          'estadoVerificacion': 'aprobada',
        }),
        isNull,
      );
      expect(
        AppUserMapper.fromFirestore('u1', {
          'email': 'a@utez.edu.mx',
          'rol': 'estudiante',
          'estadoVerificacion': 'otro',
        }),
        isNull,
      );
    });

    test('newProfile deja verificación pendiente y rol pedido', () {
      final data = AppUserMapper.newProfile(
        email: ' op@mail.com ',
        displayName: ' Luis ',
        role: UserRole.operador,
        creadoEn: DateTime.utc(2026, 1, 1),
      );

      expect(data['email'], 'op@mail.com');
      expect(data['nombreCompleto'], 'Luis');
      expect(data['rol'], 'operador');
      expect(data['estadoVerificacion'], 'pendiente');
      expect(data['creadoEn'], DateTime.utc(2026, 1, 1));
    });
  });
}
