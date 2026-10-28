/// Fallo de infraestructura o de dominio expuesto a presentation (C-10).
sealed class AppFailure implements Exception {
  const AppFailure(this.userMessage);

  final String userMessage;

  @override
  String toString() => userMessage;
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure([
    super.userMessage =
        'No se pudo completar la operación. Revisa tu conexión.',
  ]);
}

final class UnavailableFailure extends AppFailure {
  const UnavailableFailure([
    super.userMessage =
        'Firebase no está activo. Configura USE_FIREBASE y los archivos locales.',
  ]);
}

final class GenericFailure extends AppFailure {
  const GenericFailure([
    super.userMessage = 'Ocurrió un error. Intenta de nuevo.',
  ]);
}

final class FirestoreFailure extends AppFailure {
  const FirestoreFailure([
    super.userMessage = 'No pudimos leer o guardar datos. Intenta de nuevo.',
  ]);
}

final class AuthUnavailableFailure extends AppFailure {
  const AuthUnavailableFailure()
    : super(
        'Firebase no está activo. Configura USE_FIREBASE y los archivos locales.',
      );
}

final class AuthInvalidInputFailure extends AppFailure {
  const AuthInvalidInputFailure(super.userMessage);
}

final class AuthNetworkFailure extends AppFailure {
  const AuthNetworkFailure()
    : super('No se pudo completar la operación. Revisa tu conexión.');
}

final class AuthGenericFailure extends AppFailure {
  const AuthGenericFailure() : super('Ocurrió un error. Intenta de nuevo.');
}
