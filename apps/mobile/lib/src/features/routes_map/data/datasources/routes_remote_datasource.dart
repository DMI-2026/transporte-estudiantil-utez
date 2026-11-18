import '../../domain/entities/bus_route.dart';

abstract interface class RoutesRemoteDataSource {
  Future<List<BusRoute>> fetchRoutes();

  Future<BusRoute> createDemoRoute();
}
