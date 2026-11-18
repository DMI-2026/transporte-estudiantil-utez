import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/core/errors/app_failure.dart';
import 'package:transporte_estudiantil/src/features/auth/data/datasources/firestore_failures.dart';

void main() {
  group('firestoreFailureDesde traduce los códigos de Firestore', () {
    test('permission-denied dice que no hay permiso', () {
      final fallo = firestoreFailureDesde('permission-denied');
      expect(fallo, isA<FirestoreFailure>());
      expect(fallo.userMessage, contains('No tienes permiso'));
    });

    test('unavailable y deadline-exceeded son fallo de conexión', () {
      expect(firestoreFailureDesde('unavailable'), isA<NetworkFailure>());
      expect(firestoreFailureDesde('deadline-exceeded'), isA<NetworkFailure>());
    });

    test('un código desconocido no filtra el detalle técnico', () {
      final fallo = firestoreFailureDesde('algo-nuevo');
      expect(fallo, isA<FirestoreFailure>());
      expect(fallo.userMessage, isNot(contains('algo-nuevo')));
    });
  });
}
