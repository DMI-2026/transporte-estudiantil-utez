import '../../../../core/errors/app_failure.dart';
import '../../domain/entities/bus_route.dart';
import '../../domain/repositories/routes_repository.dart';
import '../datasources/routes_remote_datasource.dart';

class RoutesRepositoryImpl implements RoutesRepository {
  RoutesRepositoryImpl(this.remote);

  final RoutesRemoteDataSource remote;

  @override
  Future<RoutesResult<List<BusRoute>>> fetchRoutes() {
    return _guard(remote.fetchRoutes);
  }

  @override
  Future<RoutesResult<BusRoute>> createDemoRoute() {
    return _guard(remote.createDemoRoute);
  }

  Future<RoutesResult<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return (value: await action(), failure: null);
    } on AppFailure catch (e) {
      return (value: null, failure: e);
    } on StateError {
      return (value: null, failure: const UnavailableFailure());
    } catch (_) {
      return (value: null, failure: const FirestoreFailure());
    }
  }
}
