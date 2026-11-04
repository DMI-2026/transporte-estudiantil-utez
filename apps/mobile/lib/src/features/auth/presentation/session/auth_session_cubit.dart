import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/entities/verification_status.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_session_state.dart';

/// Sesión global de la app (C-08: Bloc/Cubit para todo el estado de UI).
///
/// Escucha [AuthRepository.watchSessionUser] y traduce el perfil a un
/// [AuthSessionStatus] que el router usa para redirigir.
class AuthSessionCubit extends Cubit<AuthSessionState> {
  AuthSessionCubit(this._repository) : super(const AuthSessionState.loading());

  final AuthRepository _repository;
  StreamSubscription<AppUser?>? _subscription;

  bool get backendAvailable => _repository.isAvailable;

  void start() {
    _subscription?.cancel();
    _subscription = _repository.watchSessionUser().listen(_onUser);
  }

  void _onUser(AppUser? profile) {
    if (profile == null) {
      emit(const AuthSessionState.unauthenticated());
      return;
    }
    final status = switch (profile.verificationStatus) {
      VerificationStatus.aprobada => AuthSessionStatus.authenticated,
      VerificationStatus.pendiente => AuthSessionStatus.pendingVerification,
      VerificationStatus.rechazada => AuthSessionStatus.rejected,
    };
    emit(AuthSessionState(status: status, user: profile));
  }

  Future<void> signOut() => _repository.signOut();

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
