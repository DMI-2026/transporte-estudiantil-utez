import 'dart:async';

import 'package:transporte_estudiantil/src/features/auth/data/datasources/auth_gateway.dart';
import 'package:transporte_estudiantil/src/features/auth/domain/failures/auth_failure.dart';

class FakeAuthGateway implements AuthGateway {
  FakeAuthGateway({this.uid});

  String? uid;
  AuthFailure? fallaAlEntrar;
  AuthFailure? fallaAlRegistrar;
  int signInCalls = 0;
  int signUpCalls = 0;
  int signOutCalls = 0;
  final _controller = StreamController<String?>.broadcast();

  @override
  Stream<String?> watchUid() async* {
    yield uid;
    yield* _controller.stream;
  }

  @override
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    signInCalls++;
    if (fallaAlEntrar != null) {
      throw fallaAlEntrar!;
    }
    uid = uid ?? 'uid-1';
    _controller.add(uid);
    return uid!;
  }

  @override
  Future<String> signUp({
    required String email,
    required String password,
  }) async {
    signUpCalls++;
    if (fallaAlRegistrar != null) {
      throw fallaAlRegistrar!;
    }
    uid = uid ?? 'uid-nuevo';
    _controller.add(uid);
    return uid!;
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    uid = null;
    _controller.add(null);
  }
}
