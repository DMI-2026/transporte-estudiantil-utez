import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/core/widgets/ui_state.dart';
import 'package:transporte_estudiantil/src/features/reservations/data/datasources/demo_reservations_datasource.dart';
import 'package:transporte_estudiantil/src/features/trip/data/repositories/demo_trip_repository.dart';
import 'package:transporte_estudiantil/src/features/trip/domain/entities/viaje_en_curso.dart';
import 'package:transporte_estudiantil/src/features/trip/presentation/viaje_cubit.dart';

void main() {
  late DemoTripRepository repo;

  setUp(() {
    repo = DemoTripRepository(
      DemoReservationsDataSource(latencia: Duration.zero),
    );
  });

  test('una reserva activa tiene viaje en curso', () async {
    final cubit = ViajeCubit(repo, 'UTEZ-1048');

    await cubit.load();

    final viaje = (cubit.state as UiData<ViajeEnCurso>).value;
    expect(viaje.paradaActual.nombre, 'Las Palmas');
  });

  test('una reserva cancelada no tiene viaje en curso', () async {
    final cubit = ViajeCubit(repo, 'UTEZ-1022');

    await cubit.load();

    expect(
      (cubit.state as UiError).message,
      contains('no está en curso'),
    );
  });
}
