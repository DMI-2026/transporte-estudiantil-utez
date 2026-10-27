import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/app_failure.dart';
import 'user_remote_datasource.dart';

class FirestoreUserRemoteDataSource implements UserRemoteDataSource {
  FirestoreUserRemoteDataSource(this.firestore);

  final FirebaseFirestore firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      firestore.collection('usuarios');

  @override
  Future<Map<String, dynamic>?> fetchProfile(String uid) async {
    try {
      final snap = await _users.doc(uid).get();
      return snap.data();
    } catch (_) {
      throw const FirestoreFailure();
    }
  }

  @override
  Future<void> saveProfile(String uid, Map<String, Object?> data) async {
    try {
      await _users.doc(uid).set(data);
    } catch (_) {
      throw const FirestoreFailure();
    }
  }
}
