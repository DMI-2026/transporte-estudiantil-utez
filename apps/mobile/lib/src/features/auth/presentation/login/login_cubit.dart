import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/validators/registration_validator.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._repository) : super(const LoginState.initial());

  final AuthRepository _repository;

  Future<void> submit({required String email, required String password}) async {
    final passwordError = RegistrationValidator.passwordError(password);
    if (passwordError != null) {
      emit(LoginState.failure(passwordError));
      return;
    }
    final emailError = RegistrationValidator.loginEmailError(email);
    if (emailError != null) {
      emit(LoginState.failure(emailError));
      return;
    }

    emit(const LoginState.loading());
    final result = await _repository.signIn(email: email, password: password);
    if (result.failure != null) {
      emit(LoginState.failure(result.failure!.userMessage));
      return;
    }
    emit(const LoginState.success());
  }
}
