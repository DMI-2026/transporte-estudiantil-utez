// Modelos compartidos entre Flutter y Cloud Functions
// Mantener sincronizados con functions/src/models/pagos.ts

/// Request para crear preferencia de pago en Mercado Pago
class PaymentPreferenceRequest {
  final String reservaId;
  final double monto;
  final String metodoPago; // 'credit_card', 'debit_card', 'ticket', etc.

  const PaymentPreferenceRequest({
    required this.reservaId,
    required this.monto,
    required this.metodoPago,
  });

  Map<String, dynamic> toJson() => {
        'reservaId': reservaId,
        'monto': monto,
        'metodoPago': metodoPago,
      };

  factory PaymentPreferenceRequest.fromJson(Map<String, dynamic> json) =>
      PaymentPreferenceRequest(
        reservaId: json['reservaId'] as String,
        monto: (json['monto'] as num).toDouble(),
        metodoPago: json['metodoPago'] as String,
      );
}

/// Respuesta de crear preferencia de pago
class PaymentPreferenceResponse {
  final String initPoint;
  final String preferenceId;

  const PaymentPreferenceResponse({
    required this.initPoint,
    required this.preferenceId,
  });

  factory PaymentPreferenceResponse.fromJson(Map<String, dynamic> json) =>
      PaymentPreferenceResponse(
        initPoint: json['initPoint'] as String,
        preferenceId: json['preferenceId'] as String,
      );
}

/// Payload del webhook de Mercado Pago
class PaymentWebhookPayload {
  final String type; // 'payment', 'merchant_order', etc.
  final PaymentWebhookData data;

  const PaymentWebhookPayload({
    required this.type,
    required this.data,
  });

  factory PaymentWebhookPayload.fromJson(Map<String, dynamic> json) =>
      PaymentWebhookPayload(
        type: json['type'] as String,
        data: PaymentWebhookData.fromJson(json['data'] as Map<String, dynamic>),
      );
}

class PaymentWebhookData {
  final String id;

  const PaymentWebhookData({required this.id});

  factory PaymentWebhookData.fromJson(Map<String, dynamic> json) =>
      PaymentWebhookData(id: json['id'] as String);
}

/// Estados de pago en nuestra app (debe coincidir con Firestore)
enum PaymentStatus {
  pendiente,
  aprobado,
  rechazado,
  reembolsado,
}

/// Documento de pago en Firestore
class PaymentDocument {
  final String reservaId;
  final String usuarioId;
  final double monto;
  final String metodoPago;
  final PaymentStatus estado;
  final String? mpPreferenceId;
  final String? mpPaymentId;
  final String? mpInitPoint;
  final DateTime creadaEn;
  final DateTime? aprobadoEn;
  final DateTime? reembolsoEn;
  final String? motivoReembolso;

  const PaymentDocument({
    required this.reservaId,
    required this.usuarioId,
    required this.monto,
    required this.metodoPago,
    required this.estado,
    this.mpPreferenceId,
    this.mpPaymentId,
    this.mpInitPoint,
    required this.creadaEn,
    this.aprobadoEn,
    this.reembolsoEn,
    this.motivoReembolso,
  });
}