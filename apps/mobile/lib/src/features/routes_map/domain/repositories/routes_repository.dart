import '../../../../core/errors/app_failure.dart';
import '../entities/bus_route.dart';

typedef RoutesResult<T> = ({T? value, AppFailure? failure});

abstract interface class RoutesRepository {
  Future<RoutesResult<List<BusRoute>>> fetchRoutes();

  /// Intenta crear una ruta de prueba. Las reglas solo lo permiten al admin.
  Future<RoutesResult<BusRoute>> createDemoRoute();
}
