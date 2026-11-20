// Triggers de Firestore para colección reservas (schema canónico)
import { onDocumentCreated, onDocumentUpdated, onDocumentDeleted } from "firebase-functions/v2/firestore";
import * as logger from "firebase-functions/logger";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { getMessaging, Message } from "firebase-admin/messaging";

const db = getFirestore();
const messaging = getMessaging();

export const onReservaCreated = onDocumentCreated("reservas/{reservaId}", async (event) => {
  const reserva = event.data?.data();
  if (!reserva) return;

  const { estudianteId, salidaId, estado } = reserva;
  if (typeof estudianteId !== "string") return;

  const salidaSnap = await db.collection("salidas").doc(salidaId).get();
  const salida = salidaSnap.data();
  const rutaNombre = salida?.rutaId
    ? (await db.collection("rutas").doc(salida.rutaId).get()).data()?.nombre
    : "desconocida";

  const tokensSnap = await db
    .collection("usuarios")
    .doc(estudianteId)
    .collection("dispositivos")
    .get();
  const tokens = tokensSnap.docs
    .map((doc) => doc.data().fcmToken ?? doc.data().token)
    .filter(Boolean);

  if (tokens.length > 0) {
    const message: Message = {
      notification: {
        title: "Reserva creada",
        body: `Tu reserva para la ruta ${rutaNombre} está ${
          estado === "pendientePago" ? "pendiente de pago" : "confirmada"
        }`,
      },
      data: { reservaId: event.params.reservaId, salidaId, tipo: "reserva" },
      tokens,
    };

    await messaging.sendEachForMulticast(message);
    logger.info("Notificación reserva creada enviada", {
      reservaId: event.params.reservaId,
      tokens: tokens.length,
    });
  }
});

export const onReservaUpdated = onDocumentUpdated("reservas/{reservaId}", async (event) => {
  const before = event.data?.before.data();
  const after = event.data?.after.data();
  if (!before || !after) return;

  const { estudianteId, salidaId } = after;
  if (typeof estudianteId !== "string") return;
  if (before.estado === after.estado) return;

  let title = "";
  let body = "";

  switch (after.estado) {
    case "reservada":
      title = "Pago confirmado";
      body = "Tu reserva está confirmada. ¡Nos vemos en la parada!";
      break;
    case "cancelada":
      title = "Reserva cancelada";
      body = `Tu reserva fue cancelada${
        after.motivoCancelacion ? `: ${after.motivoCancelacion}` : ""
      }`;
      break;
    case "abordada":
      title = "¡Abordaste!";
      body = "Registramos tu abordaje. ¡Buen viaje!";
      break;
    default:
      return;
  }

  const tokensSnap = await db
    .collection("usuarios")
    .doc(estudianteId)
    .collection("dispositivos")
    .get();
  const tokens = tokensSnap.docs
    .map((doc) => doc.data().fcmToken ?? doc.data().token)
    .filter(Boolean);

  if (tokens.length > 0) {
    const message: Message = {
      notification: { title, body },
      data: { reservaId: event.params.reservaId, salidaId, tipo: "reserva_estado" },
      tokens,
    };
    await messaging.sendEachForMulticast(message);
  }
});

export const onReservaDeleted = onDocumentDeleted("reservas/{reservaId}", async (event) => {
  const reserva = event.data?.data();
  if (!reserva) return;

  const { salidaId, estado } = reserva;

  if (estado === "reservada" || estado === "abordada" || estado === "pendientePago") {
    await db.collection("salidas").doc(salidaId).update({
      asientosDisponibles: FieldValue.increment(1),
      actualizadoEn: FieldValue.serverTimestamp(),
    });
    logger.info("Cupo liberado por reserva eliminada", {
      reservaId: event.params.reservaId,
      salidaId,
    });
  }
});
