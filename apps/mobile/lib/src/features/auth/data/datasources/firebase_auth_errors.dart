import '../../../../core/errors/app_failure.dart';

/// Traduce el código de Firebase Auth a un fallo de la app.
/// La UI nunca ve la excepción de Firebase, solo [AppFailure.userMessage].
///
/// Con la protección de enumeración activa, una contraseña mala llega como
/// `invalid-credential`, no como `wrong-password`. Hay que cubrir los dos.
AppFailure authFailureDesde(String codigo) => switch (codigo) {
  'invalid-credential' ||
  'wrong-password' ||
  'user-not-found' ||
  'invalid-email' => const AuthInvalidInputFailure(
    'Correo o contraseña incorrectos.',
  ),
  'email-already-in-use' => const AuthInvalidInputFailure(
    'Ese correo ya está registrado.',
  ),
  'weak-password' => const AuthInvalidInputFailure(
    'La contraseña es demasiado débil.',
  ),
  'too-many-requests' => const AuthInvalidInputFailure(
    'Demasiados intentos. Espera un momento e intenta de nuevo.',
  ),
  'operation-not-allowed' => const AuthInvalidInputFailure(
    'El inicio con correo y contraseña está desactivado en Firebase. '
    'En la consola del proyecto activa el proveedor Correo/Contraseña.',
  ),
  'network-request-failed' => const AuthNetworkFailure(),
  _ => const AuthGenericFailure(),
};
