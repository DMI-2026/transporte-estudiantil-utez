/// Contrato de autenticación remoto. Implementación Firebase o fake de tests.
abstract interface class AuthGateway {
  Stream<String?> watchUid();

  Future<String> signIn({required String email, required String password});

  Future<String> signUp({required String email, required String password});

  Future<void> signOut();
}
