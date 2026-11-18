import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/core/errors/app_failure.dart';
import 'package:transporte_estudiantil/src/core/widgets/ui_state.dart';
import 'package:transporte_estudiantil/src/features/routes_map/domain/entities/bus_route.dart';
import 'package:transporte_estudiantil/src/features/routes_map/presentation/routes_cubit.dart';

import '../../../fakes/fake_routes_repository.dart';

void main() {
  const ruta = BusRoute(id: 'r1', nombre: 'UTEZ — Centro');

  group('RoutesCubit', () {
    test('carga las rutas', () async {
      final cubit = RoutesCubit(FakeRoutesRepository(routes: const [ruta]));

      await cubit.load();

      expect(cubit.state.routes, isA<UiData<List<BusRoute>>>());
      final data = cubit.state.routes as UiData<List<BusRoute>>;
      expect(data.value, [ruta]);
    });

    test(
      'un permiso denegado al crear deja el mensaje y conserva la lista',
      () async {
        final cubit = RoutesCubit(
          FakeRoutesRepository(
            routes: const [ruta],
            createFailure: const FirestoreFailure(
              'No tienes permiso para leer o guardar estos datos.',
            ),
          ),
        );
        await cubit.load();

        await cubit.createDemoRoute();

        expect(
          cubit.state.actionMessage,
          'No tienes permiso para leer o guardar estos datos.',
        );
        expect(cubit.state.actionIsError, isTrue);
        final data = cubit.state.routes as UiData<List<BusRoute>>;
        expect(data.value, [ruta]);
      },
    );

    test('crear recarga la lista', () async {
      final repo = FakeRoutesRepository(routes: const [ruta]);
      final cubit = RoutesCubit(repo);
      await cubit.load();

      await cubit.createDemoRoute();

      expect(cubit.state.actionMessage, 'Ruta de prueba guardada.');
      expect(repo.createCalls, 1);
      final data = cubit.state.routes as UiData<List<BusRoute>>;
      expect(data.value, hasLength(2));
    });
  });
}
