part of 'routes_cubit.dart';

class RoutesState extends Equatable {
  const RoutesState({
    this.routes = const UiLoading(),
    this.creating = false,
    this.actionMessage,
    this.actionIsError,
  });

  final UiState<List<BusRoute>> routes;
  final bool creating;
  final String? actionMessage;
  final bool? actionIsError;

  RoutesState copyWith({
    UiState<List<BusRoute>>? routes,
    bool? creating,
    String? actionMessage,
    bool? actionIsError,
    bool clearAction = false,
  }) {
    return RoutesState(
      routes: routes ?? this.routes,
      creating: creating ?? this.creating,
      actionMessage: clearAction ? null : actionMessage ?? this.actionMessage,
      actionIsError: clearAction ? null : actionIsError ?? this.actionIsError,
    );
  }

  @override
  List<Object?> get props => [routes, creating, actionMessage, actionIsError];
}
