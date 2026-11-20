/// Preferencia de pago Mercado Pago (solo Cloud Functions aprueban).
abstract interface class PagosGateway {
  Future<({String initPoint, String preferenceId})> crearPreferencia({
    required String reservaId,
    required double monto,
    String metodoPago,
  });
}

/// Sin checkout: útil en Demo / pruebas.
class DemoPagosGateway implements PagosGateway {
  const DemoPagosGateway();

  @override
  Future<({String initPoint, String preferenceId})> crearPreferencia({
    required String reservaId,
    required double monto,
    String metodoPago = 'mercadoPago',
  }) async =>
      (
        initPoint: 'https://example.com/pago-demo/$reservaId',
        preferenceId: 'demo-$reservaId',
      );
}
