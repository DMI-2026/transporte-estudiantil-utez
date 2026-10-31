// Endpoints QR - Generación y validación de QR para abordaje
import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import { getFirestore, FieldValue, Transaction } from "firebase-admin/firestore";
import { v4 as uuidv4 } from "uuid";

const db = getFirestore();

/**
 * Genera QR secreto para una salida
 * Se ejecuta: manualmente por operador, o via cron 5 min antes de la salida
 */
export const generarQrSalida = onCall<{ salidaId: string }>(
  async (request) => {
    const { salidaId } = request.data;
    const uid = request.auth?.uid;

    if (!uid) throw new HttpsError("unauthenticated", "No autenticado");

    // Verificar que el operador está asignado a esta salida
    const salidaSnap = await db.collection("salidas").doc(salidaId).get();
    if (!salidaSnap.exists) throw new HttpsError("not-found", "Salida no encontrada");

    const salida = salidaSnap.data()!;
    if (salida.operadorId !== uid) {
      throw new HttpsError("permission-denied", "No eres el operador de esta salida");
    }

    if (salida.estado !== "programada") {
      throw new HttpsError("failed-precondition", "Solo salidas programadas generan QR");
    }

    const qrSecret = uuidv4();
    const expiraEn = new Date(salida.horaSalida.toMillis() + 2 * 60 * 60 * 1000); // 2h después

    // Guardar en subcolección privada (reglas: solo Cloud Functions escribe)
    await db.collection("salidas").doc(salidaId).collection("privado").doc("qr").set({
      qrSecret,
      qrExpiraEn: expiraEn,
      generadoEn: FieldValue.serverTimestamp(),
      generadoPor: uid,
    });

    // Actualizar salida con flag de QR listo
    await db.collection("salidas").doc(salidaId).update({
      qrGenerado: true,
      qrGeneradoEn: FieldValue.serverTimestamp(),
    });

    logger.info("QR generado", { salidaId });
    return { qrSecret, expiraEn: expiraEn.toISOString() };
  }
);

/**
 * Valida QR de abordaje escaneado por operador
 * Operador escanea QR del estudiante desde la app
 */
export const validarQrAbordaje = onCall<{ salidaId: string; qrScaneado: string; reservaId: string }>(
  async (request) => {
    const { salidaId, qrScaneado, reservaId } = request.data;
    const uid = request.auth?.uid;

    if (!uid) throw new HttpsError("unauthenticated", "No autenticado");

    // Verificar operador de la salida
    const salidaSnap = await db.collection("salidas").doc(salidaId).get();
    if (!salidaSnap.exists) throw new HttpsError("not-found", "Salida no encontrada");

    const salida = salidaSnap.data()!;
    if (salida.operadorId !== uid) {
      throw new HttpsError("permission-denied", "No autorizado");
    }

    // Leer QR secreto de la subcolección privada
    const qrSnap = await db.collection("salidas").doc(salidaId).collection("privado").doc("qr").get();
    if (!qrSnap.exists) {
      throw new HttpsError("failed-precondition", "QR no generado para esta salida");
    }

    const qrData = qrSnap.data()!;
    const { qrSecret, qrExpiraEn } = qrData;

    // Validaciones
    if (qrScaneado !== qrSecret) {
      return { valido: false, motivo: "QR inválido" };
    }

    if (new Date() > qrExpiraEn.toDate()) {
      return { valido: false, motivo: "QR expirado" };
    }

    // Verificar reserva
    const reservaSnap = await db.collection("reservas").doc(reservaId).get();
    if (!reservaSnap.exists) {
      return { valido: false, motivo: "Reserva no existe" };
    }

    const reserva = reservaSnap.data()!;
    if (reserva.salidaId !== salidaId) {
      return { valido: false, motivo: "Reserva no corresponde a esta salida" };
    }

    if (reserva.estado !== "reservada") {
      return { valido: false, motivo: `Reserva en estado ${reserva.estado}` };
    }

    // Todo OK - marcar como abordada (transacción atómica)
    await db.runTransaction(async (tx: Transaction) => {
      const reservaRef = db.collection("reservas").doc(reservaId);
      const salidaRef = db.collection("salidas").doc(salidaId);

      tx.update(reservaRef, {
        estado: "abordada",
        abordadaEn: FieldValue.serverTimestamp(),
      });
      tx.update(salidaRef, {
        abordados: FieldValue.increment(1),
      });
    });

    return {
      valido: true,
      pasajero: reserva.usuarioNombre,
      asiento: reserva.asiento,
    };
  }
);