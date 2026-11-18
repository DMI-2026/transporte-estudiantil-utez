import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/core/errors/app_failure.dart';
import 'package:transporte_estudiantil/src/features/auth/data/datasources/firebase_auth_errors.dart';

void main() {
  group('authFailureDesde traduce los códigos de Firebase Auth', () {
    final casos = <String, AppFailure>{
      'invalid-credential': const AuthInvalidInputFailure(
        'Correo o contraseña incorrectos.',
      ),
      'wrong-password': const AuthInvalidInputFailure(
        'Correo o contraseña incorrectos.',
      ),
      'user-not-found': const AuthInvalidInputFailure(
        'Correo o contraseña incorrectos.',
      ),
      'invalid-email': const AuthInvalidInputFailure(
        'Correo o contraseña incorrectos.',
      ),
      'email-already-in-use': const AuthInvalidInputFailure(
        'Ese correo ya está registrado.',
      ),
      'weak-password': const AuthInvalidInputFailure(
        'La contraseña es demasiado débil.',
      ),
      'too-many-requests': const AuthInvalidInputFailure(
        'Demasiados intentos. Espera un momento e intenta de nuevo.',
      ),
      'operation-not-allowed': const AuthInvalidInputFailure(
        'El inicio con correo y contraseña está desactivado en Firebase. '
        'En la consola del proyecto activa el proveedor Correo/Contraseña.',
      ),
      'network-request-failed': const AuthNetworkFailure(),
      'algo-nuevo': const AuthGenericFailure(),
    };

    casos.forEach((codigo, esperado) {
      test('$codigo -> ${esperado.runtimeType}', () {
        final fallo = authFailureDesde(codigo);
        expect(fallo.runtimeType, esperado.runtimeType);
        expect(fallo.userMessage, esperado.userMessage);
      });
    });
  });
}
