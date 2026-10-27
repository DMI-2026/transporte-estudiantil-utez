part of 'register_cubit.dart';

class RegisterState extends Equatable {
  const RegisterState._({required this.status, this.message});

  const RegisterState.initial() : this._(status: RegisterStatus.initial);
  const RegisterState.loading() : this._(status: RegisterStatus.loading);
  const RegisterState.success() : this._(status: RegisterStatus.success);
  const RegisterState.failure(String message)
    : this._(status: RegisterStatus.failure, message: message);

  final RegisterStatus status;
  final String? message;

  @override
  List<Object?> get props => [status, message];
}

enum RegisterStatus { initial, loading, success, failure }
