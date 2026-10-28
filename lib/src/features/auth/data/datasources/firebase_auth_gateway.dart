import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/failures/auth_failure.dart';
import 'auth_gateway.dart';

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
    try {
      final cred = await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return cred.user!.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        throw const AuthGenericFailure();
      }
      throw const AuthGenericFailure();
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
      if (e.code == 'email-already-in-use') {
        throw const AuthInvalidInputFailure('Ese correo ya está registrado.');
      }
      throw const AuthGenericFailure();
    } catch (e) {
      if (e is AppFailure) rethrow;
      throw const AuthNetworkFailure();
    }
  }

  @override
  Future<void> signOut() => auth.signOut();
}
