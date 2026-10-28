import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_role.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/validators/registration_validator.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit(this._repository) : super(const RegisterState.initial());

  final AuthRepository _repository;

  Future<void> submit({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  }) async {
    final nameError = RegistrationValidator.nameError(displayName);
    final emailError = RegistrationValidator.emailError(email, role);
    final passwordError = RegistrationValidator.passwordError(password);
    final firstError = nameError ?? emailError ?? passwordError;
    if (firstError != null) {
      emit(RegisterState.failure(firstError));
      return;
    }

    emit(const RegisterState.loading());
    final result = await _repository.signUp(
      email: email,
      password: password,
      displayName: displayName,
      role: role,
    );
    if (result.failure != null) {
      emit(RegisterState.failure(result.failure!.userMessage));
      return;
    }
    emit(const RegisterState.success());
  }
}
