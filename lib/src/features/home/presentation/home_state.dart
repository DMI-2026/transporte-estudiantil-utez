import 'package:equatable/equatable.dart';

import '../../auth/domain/entities/app_user.dart';
import '../../../core/widgets/ui_state.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

final class HomeLoading extends HomeState {
  const HomeLoading();
}

final class HomeData extends HomeState {
  const HomeData(this.user);

  final AppUser user;

  @override
  List<Object?> get props => [user];
}

final class HomeEmpty extends HomeState {
  const HomeEmpty();
}

final class HomeError extends HomeState {
  const HomeError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

extension HomeStateUiState on HomeState {
  UiState<AppUser> toUiState() {
    return switch (this) {
      HomeLoading() => const UiLoading(),
      HomeData(:final user) => UiData(user),
      HomeEmpty() => const UiEmpty(message: 'No hay sesión activa.'),
      HomeError(:final message) => UiError(message: message),
    };
  }
}