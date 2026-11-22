import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/features/operator/data/datasources/demo_operator_datasource.dart';
import 'package:transporte_estudiantil/src/features/operator/data/repositories/operator_repository_impl.dart';
import 'package:transporte_estudiantil/src/features/operator/domain/entities/pasajero.dart';
import 'package:transporte_estudiantil/src/features/operator/domain/entities/salida_operador.dart';

void main() {
  late OperatorRepositoryImpl repo;

  setUp(() {
    repo = OperatorRepositoryImpl(DemoOperatorDataSource(latencia: Duration.zero));
  });

  test('ciclo del recorrido: iniciar, avanzar paradas y finalizar', () async {
    final iniciada = await repo.iniciarRecorrido('SAL-001');
    expect(iniciada.value!.estado, EstadoSalida.enCurso);
    expect(iniciada.value!.iniciadaA, '06:40');

    final llegada = await repo.marcarLlegada('SAL-001');
    expect(llegada.value!.paradaActual.nombre, 'Las Palmas');

    await repo.marcarLlegada('SAL-001');
    await repo.marcarLlegada('SAL-001');
    final otra = await repo.marcarLlegada('SAL-001');
    expect(otra.failure!.userMessage, 'Ya llegaste a la última parada.');

    final fin = await repo.finalizarRecorrido('SAL-001');
    expect(fin.value!.estado, EstadoSalida.finalizada);
  });

  test('no se pueden tener dos recorridos en curso', () async {
    await repo.iniciarRecorrido('SAL-001');

    final result = await repo.iniciarRecorrido('SAL-005');

    expect(result.failure!.userMessage, contains('Finaliza el recorrido'));
  });

  test('no se marca llegada sin iniciar el recorrido', () async {
    final result = await repo.marcarLlegada('SAL-001');

    expect(result.failure!.userMessage, 'Primero inicia el recorrido.');
  });

  test('la lectura simulada aborda y la tercera es inválida', () async {
    final primera = (await repo.leerQrSimulado('SAL-001')).value!;
    expect(primera.valida, isTrue);
    expect(primera.pasajero!.estado, EstadoAbordaje.abordada);
    expect(primera.salida.abordados, 1);

    await repo.leerQrSimulado('SAL-001');
    final tercera = (await repo.leerQrSimulado('SAL-001')).value!;
    expect(tercera.valida, isFalse);
    expect(tercera.salida.abordados, 2);

    final pasajeros = (await repo.fetchPasajeros('SAL-001')).value!;
    expect(
      pasajeros.where((p) => p.estado == EstadoAbordaje.abordada).length,
      2,
    );
  });

  test('una salida inexistente devuelve un mensaje de usuario', () async {
    final result = await repo.fetchSalida('NO-EXISTE');

    expect(result.failure!.userMessage, 'No encontramos esa salida.');
  });
}
