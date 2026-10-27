part of 'auth_session_cubit.dart';

enum AuthSessionStatus {
  loading,
  unauthenticated,
  pendingVerification,
  rejected,
  authenticated,
}

class AuthSessionState extends Equatable {
  const AuthSessionState({required this.status, this.user});

  const AuthSessionState.loading()
    : status = AuthSessionStatus.loading,
      user = null;

  const AuthSessionState.unauthenticated()
    : status = AuthSessionStatus.unauthenticated,
      user = null;

  final AuthSessionStatus status;
  final AppUser? user;

  bool get isRejected =>
      user?.verificationStatus == VerificationStatus.rechazada;

  @override
  List<Object?> get props => [status, user];
}
