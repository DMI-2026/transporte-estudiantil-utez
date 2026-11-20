// Endpoints QR - Generación y validación (schema canónico)
import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import { getFirestore, FieldValue, Transaction } from "firebase-admin/firestore";
import { v4 as uuidv4 } from "uuid";

const db = getFirestore();

/**
 * Genera secreto QR para una salida (operador asignado).
 */
export const generarQrSalida = onCall<{ salidaId: string }>(
  async (request) => {
    const { salidaId } = request.data;
    const uid = request.auth?.uid;

    if (!uid) throw new HttpsError("unauthenticated", "No autenticado");

    const salidaSnap = await db.collection("salidas").doc(salidaId).get();
    if (!salidaSnap.exists) throw new HttpsError("not-found", "Salida no encontrada");

    const salida = salidaSnap.data()!;
    if (salida.operadorId !== uid) {
      throw new HttpsError("permission-denied", "No eres el operador de esta salida");
    }

    if (salida.estado !== "programada") {
      throw new HttpsError("failed-precondition", "Solo salidas programadas generan QR");
    }

    const fecha = salida.fechaHoraSalida;
    if (!fecha || typeof fecha.toMillis !== "function") {
      throw new HttpsError("failed-precondition", "Salida sin fechaHoraSalida");
    }
    const qrSecret = uuidv4();
    const expiraEn = new Date(fecha.toMillis() + 2 * 60 * 60 * 1000);

    await db.collection("salidas").doc(salidaId).collection("privado").doc("qr").set({
      qrSecret,
      qrExpiraEn: expiraEn,
      generadoEn: FieldValue.serverTimestamp(),
      generadoPor: uid,
    });

    await db.collection("salidas").doc(salidaId).update({
      qrGenerado: true,
      qrGeneradoEn: FieldValue.serverTimestamp(),
      actualizadoEn: FieldValue.serverTimestamp(),
    });

    logger.info("QR generado", { salidaId });
    return { qrSecret, expiraEn: expiraEn.toISOString() };
  }
);

/**
 * Valida el pase del estudiante escaneado por el operador.
 * Payload esperado del QR estudiante: `{reservaId}|{salidaId}|{qrSecret}`
 * o solo el secreto de la salida si se valida junto con reservaId.
 */
export const validarQrAbordaje = onCall<{
  salidaId: string;
  qrScaneado: string;
  reservaId: string;
}>(
  async (request) => {
    const { salidaId, qrScaneado, reservaId } = request.data;
    const uid = request.auth?.uid;

    if (!uid) throw new HttpsError("unauthenticated", "No autenticado");

    const salidaSnap = await db.collection("salidas").doc(salidaId).get();
    if (!salidaSnap.exists) throw new HttpsError("not-found", "Salida no encontrada");

    const salida = salidaSnap.data()!;
    if (salida.operadorId !== uid) {
      throw new HttpsError("permission-denied", "No autorizado");
    }

    const qrSnap = await db
      .collection("salidas")
      .doc(salidaId)
      .collection("privado")
      .doc("qr")
      .get();
    if (!qrSnap.exists) {
      throw new HttpsError("failed-precondition", "QR no generado para esta salida");
    }

    const qrData = qrSnap.data()!;
    const { qrSecret, qrExpiraEn } = qrData;

    const secretoEscaneado = qrScaneado.includes("|")
      ? qrScaneado.split("|").pop()!
      : qrScaneado;

    if (secretoEscaneado !== qrSecret) {
      return { valido: false, motivo: "QR inválido" };
    }

    if (qrExpiraEn && typeof qrExpiraEn.toDate === "function" && new Date() > qrExpiraEn.toDate()) {
      return { valido: false, motivo: "QR expirado" };
    }

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

    await db.runTransaction(async (tx: Transaction) => {
      const reservaRef = db.collection("reservas").doc(reservaId);
      const salidaRef = db.collection("salidas").doc(salidaId);

      tx.update(reservaRef, {
        estado: "abordada",
        abordadaEn: FieldValue.serverTimestamp(),
        actualizadoEn: FieldValue.serverTimestamp(),
      });
      tx.update(salidaRef, {
        abordados: FieldValue.increment(1),
        actualizadoEn: FieldValue.serverTimestamp(),
      });
    });

    const estudianteSnap = await db.collection("usuarios").doc(reserva.estudianteId).get();
    const nombre = estudianteSnap.data()?.nombreCompleto ?? "Estudiante";

    return {
      valido: true,
      pasajero: nombre,
      estudianteId: reserva.estudianteId,
      paradaId: reserva.paradaId,
    };
  }
);
