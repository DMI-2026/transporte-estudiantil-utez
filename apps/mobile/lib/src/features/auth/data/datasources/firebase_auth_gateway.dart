import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/failures/auth_failure.dart';
import 'auth_gateway.dart';
import 'firebase_auth_errors.dart';

class FirebaseAuthGateway implements AuthGateway {
  FirebaseAuthGateway(this.auth);

  final FirebaseAuth auth;

  @override
  Stream<String?> watchUid() => auth.authStateChanges().map((u) => u?.uid);

  @override
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    final trimmed = email.trim();
    try {
      final cred = await auth.signInWithEmailAndPassword(
        email: trimmed,
        password: password,
      );
      return cred.user!.uid;
    } on FirebaseAuthException catch (e) {
      throw authFailureDesde(e.code);
    } catch (e) {
      if (e is AppFailure) rethrow;
      throw const AuthNetworkFailure();
    }
  }

  @override
  Future<String> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return cred.user!.uid;
    } on FirebaseAuthException catch (e) {
      throw authFailureDesde(e.code);
    } catch (e) {
      if (e is AppFailure) rethrow;
      throw const AuthNetworkFailure();
    }
  }

  @override
  Future<void> signOut() => auth.signOut();
}