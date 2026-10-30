import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/presentation/session/auth_session_cubit.dart';
import 'home_state.dart';

/// Cubit para la pantalla de inicio.
/// Envuelve el usuario de la sesión y expone UiState para loading/error/empty.
class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._sessionCubit) : super(const HomeLoading()) {
    _listenSession();
  }

  final AuthSessionCubit _sessionCubit;
  late final StreamSubscription<AuthSessionState> _subscription;

  void _listenSession() {
    _subscription = _sessionCubit.stream.listen(_onSessionState);
  }

  void _onSessionState(AuthSessionState sessionState) {
    final user = sessionState.user;
    if (user == null) {
      emit(const HomeEmpty());
      return;
    }
    emit(HomeData(user));
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}