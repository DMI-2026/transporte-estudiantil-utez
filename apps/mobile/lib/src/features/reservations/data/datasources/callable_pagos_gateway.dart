import 'package:cloud_functions/cloud_functions.dart';

import '../../../../core/errors/app_failure.dart';
import 'pagos_gateway.dart';

/// Llama `crearPreferenciaPago`. Nunca marca el pago como aprobado.
class CallablePagosGateway implements PagosGateway {
  CallablePagosGateway(this.functions);

  final FirebaseFunctions functions;

  @override
  Future<({String initPoint, String preferenceId})> crearPreferencia({
    required String reservaId,
    required double monto,
    String metodoPago = 'mercadoPago',
  }) async {
    try {
      final result = await functions.httpsCallable('crearPreferenciaPago').call({
        'reservaId': reservaId,
        'monto': monto,
        'metodoPago': metodoPago,
      });
      final data = Map<String, dynamic>.from(result.data as Map);
      final initPoint = data['initPoint'];
      final preferenceId = data['preferenceId'];
      if (initPoint is! String ||
          initPoint.isEmpty ||
          preferenceId is! String ||
          preferenceId.isEmpty) {
        throw const GenericFailure('No se pudo iniciar el pago.');
      }
      return (initPoint: initPoint, preferenceId: preferenceId);
    } on FirebaseFunctionsException catch (e) {
      throw GenericFailure(e.message ?? 'No se pudo iniciar el pago.');
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const GenericFailure('No se pudo iniciar el pago.');
    }
  }
}
