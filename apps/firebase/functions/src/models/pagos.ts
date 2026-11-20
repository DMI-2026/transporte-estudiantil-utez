// Modelos de Pagos alineados a docs/05-datos.md
export interface PaymentPreferenceRequest {
  reservaId: string;
  monto: number;
  metodoPago: string;
}

export interface PaymentWebhookPayload {
  type: "payment" | "merchant_order" | "subscription_preapproval";
  data: {
    id: string;
  };
}

export interface MercadoPagoPreference {
  id: string;
  init_point: string;
  sandbox_init_point: string;
  external_reference: string;
}

export interface MercadoPagoPayment {
  id: number;
  status: "approved" | "pending" | "rejected" | "cancelled" | "refunded" | "charged_back";
  status_detail: string;
  external_reference: string | null;
  transaction_amount: number;
  payment_method_id: string;
  date_approved: string | null;
  date_created: string;
}

export interface RefundRequest {
  paymentId: string;
  amount?: number;
}

export interface PaymentDocument {
  reservaId: string;
  salidaId: string;
  estudianteId: string;
  monto: number;
  moneda: string;
  estado: "pendiente" | "aprobado" | "rechazado" | "reembolsado";
  proveedor: string;
  externalId?: string;
  metodoPago?: string;
  mpPreferenceId?: string;
  mpPaymentId?: string;
  mpInitPoint?: string;
  creadoEn: FirebaseFirestore.Timestamp;
  aprobadoEn?: FirebaseFirestore.Timestamp;
  reembolsoEn?: FirebaseFirestore.Timestamp;
  motivoReembolso?: string;
}
