part of 'home_cubit.dart';

class HomeState extends Equatable {
  const HomeState({this.proxima = const UiLoading()});

  final UiState<Reserva> proxima;

  HomeState copyWith({UiState<Reserva>? proxima}) =>
      HomeState(proxima: proxima ?? this.proxima);

  @override
  List<Object?> get props => [proxima];
}
