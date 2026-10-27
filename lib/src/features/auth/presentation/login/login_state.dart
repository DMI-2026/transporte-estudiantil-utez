part of 'login_cubit.dart';

class LoginState extends Equatable {
  const LoginState._({required this.status, this.message});

  const LoginState.initial() : this._(status: LoginStatus.initial);
  const LoginState.loading() : this._(status: LoginStatus.loading);
  const LoginState.success() : this._(status: LoginStatus.success);
  const LoginState.failure(String message)
    : this._(status: LoginStatus.failure, message: message);

  final LoginStatus status;
  final String? message;

  @override
  List<Object?> get props => [status, message];
}

enum LoginStatus { initial, loading, success, failure }
