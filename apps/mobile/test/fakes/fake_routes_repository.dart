import 'package:transporte_estudiantil/src/core/errors/app_failure.dart';
import 'package:transporte_estudiantil/src/features/routes_map/domain/entities/bus_route.dart';
import 'package:transporte_estudiantil/src/features/routes_map/domain/repositories/routes_repository.dart';

class FakeRoutesRepository implements RoutesRepository {
  FakeRoutesRepository({
    this.routes = const [],
    this.fetchFailure,
    this.createFailure,
  });

  List<BusRoute> routes;
  AppFailure? fetchFailure;
  AppFailure? createFailure;
  int createCalls = 0;

  @override
  Future<RoutesResult<List<BusRoute>>> fetchRoutes() async {
    if (fetchFailure != null) {
      return (value: null, failure: fetchFailure);
    }
    return (value: routes, failure: null);
  }

  @override
  Future<RoutesResult<BusRoute>> createDemoRoute() async {
    createCalls++;
    if (createFailure != null) {
      return (value: null, failure: createFailure);
    }
    final created = BusRoute(
      id: 'nueva-$createCalls',
      nombre: 'Ruta de prueba',
    );
    routes = [...routes, created];
    return (value: created, failure: null);
  }
}
