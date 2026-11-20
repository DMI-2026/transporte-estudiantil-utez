import 'package:cloud_functions/cloud_functions.dart';

import '../../../../core/errors/app_failure.dart';
import 'eta_gateway.dart';

/// Llama `obtenerEtaViaje` en Cloud Functions.
class CallableEtaGateway implements EtaGateway {
  CallableEtaGateway(this.functions);

  final FirebaseFunctions functions;

  @override
  Future<({int minutos, String actualizadoA})> obtenerEta({
    required String salidaId,
    required String reservaId,
  }) async {
    try {
      final result = await functions.httpsCallable('obtenerEtaViaje').call({
        'salidaId': salidaId,
        'reservaId': reservaId,
      });
      final data = Map<String, dynamic>.from(result.data as Map);
      final minutos = data['minutos'];
      final actualizado = data['actualizadoEn'];
      if (minutos is! num) {
        throw const GenericFailure('No se pudo obtener el ETA.');
      }
      final iso = actualizado is String ? actualizado : '';
      final hora = iso.length >= 16 ? iso.substring(11, 16) : '--:--';
      return (minutos: minutos.round(), actualizadoA: hora);
    } on FirebaseFunctionsException catch (e) {
      throw GenericFailure(e.message ?? 'No se pudo obtener el ETA.');
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const GenericFailure('No se pudo obtener el ETA.');
    }
  }
}
