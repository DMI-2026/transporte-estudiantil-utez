import 'package:equatable/equatable.dart';

/// Estados de pantalla para datos remotos: cargando, datos, error, vacío.
sealed class UiState<T> extends Equatable {
  const UiState();

  @override
  List<Object?> get props => [];
}

final class UiLoading<T> extends UiState<T> {
  const UiLoading();
}

final class UiData<T> extends UiState<T> {
  const UiData(this.value);

  final T value;

  @override
  List<Object?> get props => [value];
}

final class UiError<T> extends UiState<T> {
  const UiError({required this.message, this.onRetry});

  final String message;
  final void Function()? onRetry;

  @override
  List<Object?> get props => [message];
}

final class UiEmpty<T> extends UiState<T> {
  const UiEmpty({this.message});

  final String? message;

  @override
  List<Object?> get props => [message];
}
