import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/core/errors/app_failure.dart';
import 'package:transporte_estudiantil/src/features/routes_map/data/datasources/routes_remote_datasource.dart';
import 'package:transporte_estudiantil/src/features/routes_map/data/repositories/routes_repository_impl.dart';
import 'package:transporte_estudiantil/src/features/routes_map/domain/entities/bus_route.dart';

void main() {
  test('traduce un fallo de Firestore sin relanzarlo', () async {
    final repo = RoutesRepositoryImpl(
      _FakeSource(
        error: const FirestoreFailure(
          'No tienes permiso para leer o guardar estos datos.',
        ),
      ),
    );

    final result = await repo.createDemoRoute();

    expect(result.value, isNull);
    expect(
      result.failure?.userMessage,
      'No tienes permiso para leer o guardar estos datos.',
    );
  });

  test('devuelve las rutas del origen', () async {
    const ruta = BusRoute(id: 'r1', nombre: 'Centro');
    final repo = RoutesRepositoryImpl(_FakeSource(routes: const [ruta]));

    final result = await repo.fetchRoutes();

    expect(result.failure, isNull);
    expect(result.value, [ruta]);
  });
}

class _FakeSource implements RoutesRemoteDataSource {
  _FakeSource({this.routes = const [], this.error});

  final List<BusRoute> routes;
  final AppFailure? error;

  @override
  Future<BusRoute> createDemoRoute() async {
    if (error != null) {
      throw error!;
    }
    return const BusRoute(id: 'nueva', nombre: 'Ruta de prueba');
  }

  @override
  Future<List<BusRoute>> fetchRoutes() async {
    if (error != null) {
      throw error!;
    }
    return routes;
  }
}
