// Pase de abordaje para el estudiante (secreto solo en Functions).
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getFirestore } from "firebase-admin/firestore";

const db = getFirestore();

/**
 * Devuelve el payload QR del pase sin exponer la colección privado al cliente.
 * Payload: `{reservaId}|{salidaId}|{qrSecret}` para `validarQrAbordaje`.
 */
export const obtenerPaseAbordaje = onCall<{ reservaId: string }>(
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError("unauthenticated", "Usuario no autenticado");
    }
    const { reservaId } = request.data;
    if (!reservaId) {
      throw new HttpsError("invalid-argument", "reservaId es obligatorio");
    }

    const reservaSnap = await db.collection("reservas").doc(reservaId).get();
    if (!reservaSnap.exists) {
      throw new HttpsError("not-found", "Reserva no encontrada");
    }
    const reserva = reservaSnap.data()!;
    if (reserva.estudianteId !== uid) {
      throw new HttpsError("permission-denied", "No autorizado");
    }
    if (reserva.estado !== "reservada") {
      throw new HttpsError(
        "failed-precondition",
        `La reserva está en estado ${reserva.estado}`,
      );
    }

    const salidaId = reserva.salidaId as string;
    const qrSnap = await db
      .collection("salidas")
      .doc(salidaId)
      .collection("privado")
      .doc("qr")
      .get();
    if (!qrSnap.exists) {
      throw new HttpsError(
        "failed-precondition",
        "El operador aún no generó el QR de la salida",
      );
    }
    const qrSecret = qrSnap.data()?.qrSecret;
    if (typeof qrSecret !== "string" || !qrSecret) {
      throw new HttpsError("failed-precondition", "QR incompleto");
    }

    return {
      payload: `${reservaId}|${salidaId}|${qrSecret}`,
      salidaId,
      reservaId,
    };
  },
);
