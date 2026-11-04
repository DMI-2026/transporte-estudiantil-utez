// Triggers de Firestore para colección salidas
import { onDocumentCreated, onDocumentUpdated } from "firebase-functions/v2/firestore";
import * as logger from "firebase-functions/logger";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { getMessaging, Message } from "firebase-admin/messaging";

const db = getFirestore();
const messaging = getMessaging();

/**
 * Cuando se crea una salida -> notificar al operador asignado
 */
export const onSalidaCreated = onDocumentCreated("salidas/{salidaId}", async (event) => {
  const salida = event.data?.data();
  if (!salida) return;

  const { operadorId, rutaId, horaSalida } = salida;

  // Obtener nombre de ruta
  const rutaSnap = await db.collection("rutas").doc(rutaId).get();
  const rutaNombre = rutaSnap.data()?.nombre || "desconocida";

  // Notificar al operador
  const tokensSnap = await db.collection("usuarios").doc(operadorId).collection("dispositivos").get();
  const tokens = tokensSnap.docs.map((doc) => doc.data().token).filter(Boolean);

  if (tokens.length > 0) {
    const message: Message = {
      notification: {
        title: "Nueva salida asignada",
        body: `Te asignaron la salida ${rutaNombre} para ${new Date(horaSalida.seconds * 1000).toLocaleString()}`,
      },
      data: { salidaId: event.params.salidaId, tipo: "salida_asignada" },
      tokens,
    };
    await messaging.sendEachForMulticast(message);
  }
});

/**
 * Cuando cambia estado de salida -> notificar a pasajeros y operador
 */
export const onSalidaUpdated = onDocumentUpdated("salidas/{salidaId}", async (event) => {
  const before = event.data?.before.data();
  const after = event.data?.after.data();
  if (!before || !after) return;

  const { operadorId, rutaId, horaSalida } = after;
  const salidaId = event.params.salidaId;

  // Solo notificar en cambios de estado importantes
  if (before.estado === after.estado) return;

  let title = "";
  let body = "";
  let notifyPasajeros = false;

  switch (after.estado) {
    case "enCurso":
      title = "Salida iniciada";
      body = `La combi de la ruta ${rutaId} ya salió. Dirígete a tu parada.`;
      notifyPasajeros = true;
      break;
    case "finalizada":
      title = "Salida finalizada";
      body = `La ruta ${rutaId} llegó a su destino.`;
      notifyPasajeros = true;
      break;
    case "cancelada":
      title = "Salida cancelada";
      body = `La salida de la ruta ${rutaId} fue cancelada. Se reembolsará tu reserva.`;
      notifyPasajeros = true;
      break;
    default:
      return;
  }

  // Notificar a pasajeros con reserva confirmada
  if (notifyPasajeros) {
    const reservasSnap = await db
      .collection("reservas")
      .where("salidaId", "==", salidaId)
      .where("estado", "==", "reservada")
      .get();

    const userIds = [...new Set(reservasSnap.docs.map((doc) => doc.data().usuarioId))];

    for (const userId of userIds) {
      const tokensSnap = await db.collection("usuarios").doc(userId).collection("dispositivos").get();
      const tokens = tokensSnap.docs.map((doc) => doc.data().token).filter(Boolean);
      if (tokens.length === 0) continue;

      const message: Message = {
        notification: { title, body },
        data: { salidaId, tipo: "salida_estado" },
        tokens,
      };
      await messaging.sendEachForMulticast(message);
    }
  }

  // Notificar al operador también
  const opTokensSnap = await db.collection("usuarios").doc(operadorId).collection("dispositivos").get();
  const opTokens = opTokensSnap.docs.map((doc) => doc.data().token).filter(Boolean);
  if (opTokens.length > 0) {
    const message: Message = {
      notification: { title, body },
      data: { salidaId, tipo: "salida_estado_operador" },
      tokens: opTokens,
    };
    await messaging.sendEachForMulticast(message);
  }
});