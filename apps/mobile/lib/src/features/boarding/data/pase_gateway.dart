import 'package:cloud_functions/cloud_functions.dart';

import '../../../core/errors/app_failure.dart';

/// Payload del pase QR (secreto solo vía Cloud Functions).
abstract interface class PaseGateway {
  Future<String> obtenerPayload(String reservaId);
}

class DemoPaseGateway implements PaseGateway {
  const DemoPaseGateway();

  @override
  Future<String> obtenerPayload(String reservaId) async {
    // Sin secreto real: solo folio para pantallas Demo.
    return '$reservaId|demo-salida|demo-secret';
  }
}

class CallablePaseGateway implements PaseGateway {
  CallablePaseGateway(this.functions);

  final FirebaseFunctions functions;

  @override
  Future<String> obtenerPayload(String reservaId) async {
    try {
      final result = await functions.httpsCallable('obtenerPaseAbordaje').call({
        'reservaId': reservaId,
      });
      final data = Map<String, dynamic>.from(result.data as Map);
      final payload = data['payload'];
      if (payload is! String || payload.isEmpty) {
        throw const GenericFailure('No se pudo obtener el pase.');
      }
      return payload;
    } on FirebaseFunctionsException catch (e) {
      throw GenericFailure(e.message ?? 'No se pudo obtener el pase.');
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const GenericFailure('No se pudo obtener el pase.');
    }
  }
}
