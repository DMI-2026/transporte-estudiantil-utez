// Endpoints de Pagos - Mercado Pago
import { onCall, onRequest, HttpsError } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import { getFirestore, FieldValue, Transaction } from "firebase-admin/firestore";
import { MercadoPagoService } from "../services/mercadopago";
import { PaymentPreferenceRequest, PaymentWebhookPayload } from "../models/pagos";

const db = getFirestore();
const mp = new MercadoPagoService();

/**
 * Crea preferencia de pago en Mercado Pago
 * Cliente llama desde Flutter: FirebaseFunctions.instance.httpsCallable('crearPreferenciaPago')
 */
export const crearPreferenciaPago = onCall<PaymentPreferenceRequest>(
  async (request) => {
    const { reservaId, monto, metodoPago } = request.data;
    const uid = request.auth?.uid;

    if (!uid) {
      throw new HttpsError("unauthenticated", "Usuario no autenticado");
    }

    // Verificar que la reserva pertenece al usuario
    const reservaSnap = await db.collection("reservas").doc(reservaId).get();
    if (!reservaSnap.exists) {
      throw new HttpsError("not-found", "Reserva no encontrada");
    }
    const reserva = reservaSnap.data()!;
    if (reserva.usuarioId !== uid) {
      throw new HttpsError("permission-denied", "No autorizado para esta reserva");
    }

    try {
      const preference = await mp.createPreference({
        externalReference: reservaId,
        amount: monto,
        paymentMethodId: metodoPago,
        backUrls: {
          success: `https://utebus-4435b.web.app/pago/exito?reserva=${reservaId}`,
          failure: `https://utebus-4435b.web.app/pago/fallo?reserva=${reservaId}`,
          pending: `https://utebus-4435b.web.app/pago/pendiente?reserva=${reservaId}`,
        },
      });

      // Guardar referencia del pago en Firestore
      await db.collection("pagos").doc(reservaId).set({
        reservaId,
        salidaId: reserva.salidaId,
        usuarioId: uid,
        monto,
        metodoPago,
        estado: "pendiente",
        mpPreferenceId: preference.id,
        mpInitPoint: preference.init_point,
        creadaEn: FieldValue.serverTimestamp(),
      });

      return { initPoint: preference.init_point, preferenceId: preference.id };
    } catch (error) {
      logger.error("Error creando preferencia MP", { error, reservaId });
      throw new HttpsError("internal", "Error procesando pago");
    }
  }
);

/**
 * Webhook público de Mercado Pago
 * Recibe notificaciones de cambio de estado de pago
 */
export const mercadoPagoWebhook = onRequest(
  { cors: true, region: "us-central1" },
  async (request, response) => {
    const body = request.body as PaymentWebhookPayload | undefined;
    const type = typeof body?.type === "string"
      ? body.type
      : typeof request.query.type === "string"
        ? request.query.type
        : undefined;
    const dataId = typeof body?.data?.id === "string"
      ? body.data.id
      : typeof request.query["data.id"] === "string"
        ? request.query["data.id"]
        : undefined;
    const requestId = request.header("x-request-id");
    const signature = request.header("x-signature");
    const webhookSecret = process.env.MERCADOPAGO_WEBHOOK_SECRET;

    if (
      !webhookSecret ||
      !requestId ||
      !signature ||
      !dataId ||
      !MercadoPagoService.verifySignature(dataId, requestId, signature, webhookSecret)
    ) {
      response.status(401).json({ error: "Firma inválida" });
      return;
    }

    if (type !== "payment") {
      response.status(200).json({ received: true });
      return;
    }

    const paymentId = dataId;
    const payment = await mp.getPayment(paymentId);
    const reservaId = payment.external_reference;

    if (!reservaId) {
      response.status(200).json({ received: true });
      return;
    }

    // Transacción atómica: actualizar pago + reserva + cupo salida
    await db.runTransaction(async (tx: Transaction) => {
      const pagoRef = db.collection("pagos").doc(reservaId);
      const reservaRef = db.collection("reservas").doc(reservaId);
      const pagoSnap = await tx.get(pagoRef);
      const reservaSnap = await tx.get(reservaRef);
      if (!pagoSnap.exists || !reservaSnap.exists) throw new Error("Pago o reserva no encontrado");

      const salidaId = reservaSnap.data()?.salidaId;
      if (typeof salidaId !== "string" || salidaId.length === 0) {
        throw new Error("Reserva sin salidaId");
      }
      const salidaRef = db.collection("salidas").doc(salidaId);
      const pago = pagoSnap.data()!;

      if (payment.status === "approved") {
        if (pago.estado === "aprobado") return;
        tx.update(pagoRef, {
          estado: "aprobado",
          mpPaymentId: paymentId,
          aprobadoEn: FieldValue.serverTimestamp(),
        });
        tx.update(reservaRef, { estado: "reservada" });
        tx.update(salidaRef, { cuposDisponibles: FieldValue.increment(-1) });
      } else if (payment.status === "rejected" || payment.status === "cancelled") {
        if (pago.estado === "rechazado") return;
        tx.update(pagoRef, { estado: "rechazado", mpPaymentId: paymentId });
        tx.update(reservaRef, { estado: "cancelada" });
      }
    });

    response.status(200).json({ received: true });
  }
);

/**
 * Reembolso de pago (solo admin/operador)
 */
export const reembolsarPago = onCall<{ reservaId: string; motivo: string }>(
  async (request) => {
    const { reservaId, motivo } = request.data;
    const uid = request.auth?.uid;

    if (!uid) throw new HttpsError("unauthenticated", "No autenticado");

    // Verificar rol admin/operador (custom claim)
    const userDoc = await db.collection("usuarios").doc(uid).get();
    const role = userDoc.data()?.rol;
    if (role !== "admin" && role !== "operador") {
      throw new HttpsError("permission-denied", "Solo admin/operador");
    }

    const pagoSnap = await db.collection("pagos").doc(reservaId).get();
    if (!pagoSnap.exists) throw new HttpsError("not-found", "Pago no encontrado");

    const pago = pagoSnap.data()!;
    if (pago.estado !== "aprobado") {
      throw new HttpsError("failed-precondition", "Solo pagos aprobados se reembolsan");
    }

    const reservaSnap = await db.collection("reservas").doc(reservaId).get();
    const salidaId = pago.salidaId ?? reservaSnap.data()?.salidaId;
    if (typeof salidaId !== "string" || salidaId.length === 0 || !pago.mpPaymentId) {
      throw new HttpsError("failed-precondition", "Pago sin datos de reembolso");
    }

    try {
      await mp.createRefund(pago.mpPaymentId!);

      await db.runTransaction(async (tx) => {
        const pagoRef = db.collection("pagos").doc(reservaId);
        const reservaRef = db.collection("reservas").doc(reservaId);
        const salidaRef = db.collection("salidas").doc(salidaId);

        tx.update(pagoRef, { estado: "reembolsado", reembolsoEn: FieldValue.serverTimestamp(), motivo });
        tx.update(reservaRef, { estado: "cancelada" });
        tx.update(salidaRef, { cuposDisponibles: FieldValue.increment(1) });
      });

      return { success: true };
    } catch (error) {
      logger.error("Error reembolsando", { error, reservaId });
      throw new HttpsError("internal", "Error procesando reembolso");
    }
  }
);