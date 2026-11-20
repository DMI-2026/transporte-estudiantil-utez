/// Contrato del callable de ETA (ORS solo en Cloud Functions).
abstract interface class EtaGateway {
  Future<({int minutos, String actualizadoA})> obtenerEta({
    required String salidaId,
    required String reservaId,
  });
}

/// ETA fijo para Demo / pruebas sin Functions.
class DemoEtaGateway implements EtaGateway {
  const DemoEtaGateway({this.minutos = 18});

  final int minutos;

  @override
  Future<({int minutos, String actualizadoA})> obtenerEta({
    required String salidaId,
    required String reservaId,
  }) async =>
      (minutos: minutos, actualizadoA: '06:53');
}
