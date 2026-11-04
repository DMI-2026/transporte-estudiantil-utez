// Triggers de Firestore para colección reservas
import { onDocumentCreated, onDocumentUpdated, onDocumentDeleted } from "firebase-functions/v2/firestore";
import * as logger from "firebase-functions/logger";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { getMessaging, Message } from "firebase-admin/messaging";

const db = getFirestore();
const messaging = getMessaging();

/**
 * Cuando se crea una reserva -> notificar al usuario confirmación
 */
export const onReservaCreated = onDocumentCreated("reservas/{reservaId}", async (event) => {
  const reserva = event.data?.data();
  if (!reserva) return;

  const { usuarioId, salidaId, asiento, estado } = reserva;

  // Obtener info de la salida para el mensaje
  const salidaSnap = await db.collection("salidas").doc(salidaId).get();
  const salida = salidaSnap.data();
  const rutaNombre = salida?.rutaId ? (await db.collection("rutas").doc(salida.rutaId).get()).data()?.nombre : "desconocida";

  // Enviar push al usuario
  const tokensSnap = await db.collection("usuarios").doc(usuarioId).collection("dispositivos").get();
  const tokens = tokensSnap.docs.map((doc) => doc.data().token).filter(Boolean);

  if (tokens.length > 0) {
    const message: Message = {
      notification: {
        title: "Reserva creada",
        body: `Tu reserva para la ruta ${rutaNombre} (asiento ${asiento}) está ${estado === "pendientePago" ? "pendiente de pago" : "confirmada"}`,
      },
      data: { reservaId: event.params.reservaId, salidaId, tipo: "reserva" },
      tokens,
    };

    await messaging.sendEachForMulticast(message);
    logger.info("Notificación reserva creada enviada", { reservaId: event.params.reservaId, tokens: tokens.length });
  }
});

/**
 * Cuando cambia estado de reserva -> notificar según nuevo estado
 */
export const onReservaUpdated = onDocumentUpdated("reservas/{reservaId}", async (event) => {
  const before = event.data?.before.data();
  const after = event.data?.after.data();
  if (!before || !after) return;

  const { usuarioId, salidaId, asiento } = after;

  // Solo notificar si cambió el estado
  if (before.estado === after.estado) return;

  let title = "";
  let body = "";

  switch (after.estado) {
    case "reservada":
      title = "Pago confirmado";
      body = `Tu reserva (asiento ${asiento}) está confirmada. ¡Nos vemos en la parada!`;
      break;
    case "cancelada":
      title = "Reserva cancelada";
      body = `Tu reserva (asiento ${asiento}) fue cancelada${after.motivoCancelacion ? `: ${after.motivoCancelacion}` : ""}`;
      break;
    case "abordada":
      title = "¡Abordaste!";
      body = `Registramos tu abordaje en la salida. ¡Buen viaje!`;
      break;
    default:
      return;
  }

  const tokensSnap = await db.collection("usuarios").doc(usuarioId).collection("dispositivos").get();
  const tokens = tokensSnap.docs.map((doc) => doc.data().token).filter(Boolean);

  if (tokens.length > 0) {
    const message: Message = {
      notification: { title, body },
      data: { reservaId: event.params.reservaId, salidaId, tipo: "reserva_estado" },
      tokens,
    };
    await messaging.sendEachForMulticast(message);
  }
});

/**
 * Cuando se elimina reserva -> liberar cupo si estaba reservada
 */
export const onReservaDeleted = onDocumentDeleted("reservas/{reservaId}", async (event) => {
  const reserva = event.data?.data();
  if (!reserva) return;

  const { salidaId, estado } = reserva;

  // Solo liberar cupo si estaba en estado reservada o abordada
  if (estado === "reservada" || estado === "abordada") {
    await db.collection("salidas").doc(salidaId).update({
      cuposDisponibles: FieldValue.increment(1),
    });
    logger.info("Cupo liberado por reserva eliminada", { reservaId: event.params.reservaId, salidaId });
  }
});