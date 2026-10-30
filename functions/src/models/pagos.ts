// Modelos compartidos para Pagos (Mercado Pago)
export interface PaymentPreferenceRequest {
  reservaId: string;
  monto: number;
  metodoPago: string; // "credit_card", "debit_card", "ticket", etc.
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
  amount?: number; // Parcial si se especifica
}

export interface PaymentDocument {
  reservaId: string;
  salidaId: string;
  usuarioId: string;
  monto: number;
  metodoPago: string;
  estado: "pendiente" | "aprobado" | "rechazado" | "reembolsado";
  mpPreferenceId?: string;
  mpPaymentId?: string;
  mpInitPoint?: string;
  creadaEn: FirebaseFirestore.Timestamp;
  aprobadoEn?: FirebaseFirestore.Timestamp;
  reembolsoEn?: FirebaseFirestore.Timestamp;
  motivoReembolso?: string;
}