import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/features/reservations/data/datasources/pagos_gateway.dart';

void main() {
  test('DemoPagosGateway devuelve initPoint sin marcar aprobado', () async {
    const gateway = DemoPagosGateway();
    final result = await gateway.crearPreferencia(
      reservaId: 'sal-1_uid',
      monto: 20,
    );

    expect(result.preferenceId, 'demo-sal-1_uid');
    expect(result.initPoint, contains('sal-1_uid'));
  });
}
