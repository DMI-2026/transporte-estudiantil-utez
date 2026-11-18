import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/ui_state.dart';
import '../domain/entities/bus_route.dart';
import '../domain/repositories/routes_repository.dart';

part 'routes_state.dart';

class RoutesCubit extends Cubit<RoutesState> {
  RoutesCubit(this._repository) : super(const RoutesState());

  final RoutesRepository _repository;

  Future<void> load() => _load(clearAction: true);

  Future<void> createDemoRoute() async {
    emit(state.copyWith(creating: true, clearAction: true));
    final result = await _repository.createDemoRoute();
    if (result.failure != null) {
      emit(
        state.copyWith(
          creating: false,
          actionMessage: result.failure!.userMessage,
          actionIsError: true,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        creating: false,
        actionMessage: 'Ruta de prueba guardada.',
        actionIsError: false,
      ),
    );
    await _load(clearAction: false);
  }

  Future<void> _load({required bool clearAction}) async {
    final actionMessage = clearAction ? null : state.actionMessage;
    final actionIsError = clearAction ? null : state.actionIsError;
    if (clearAction || state.routes is! UiData<List<BusRoute>>) {
      emit(state.copyWith(routes: const UiLoading(), clearAction: clearAction));
    }
    final result = await _repository.fetchRoutes();
    if (result.failure != null) {
      emit(
        state.copyWith(
          routes: UiError(
            message: result.failure!.userMessage,
            onRetry: () {
              load();
            },
          ),
          actionMessage: actionMessage,
          actionIsError: actionIsError,
        ),
      );
      return;
    }
    final routes = result.value ?? const <BusRoute>[];
    emit(
      state.copyWith(
        routes: routes.isEmpty
            ? const UiEmpty(message: 'Todavía no hay rutas publicadas.')
            : UiData(routes),
        actionMessage: actionMessage,
        actionIsError: actionIsError,
      ),
    );
  }
}
