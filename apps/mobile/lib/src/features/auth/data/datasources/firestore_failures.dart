import '../../../../core/errors/app_failure.dart';

/// Traduce el código de Firestore al fallo que ya muestra la UI.
/// No hay HTTP: `permission-denied` equivale al 403 de las reglas.
AppFailure firestoreFailureDesde(String codigo) => switch (codigo) {
  'permission-denied' => const FirestoreFailure(
    'No tienes permiso para leer o guardar estos datos.',
  ),
  'unavailable' || 'deadline-exceeded' => const NetworkFailure(),
  _ => const FirestoreFailure(),
};
