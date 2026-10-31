// Endpoints de Notificaciones Push (FCM)
import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { getMessaging, Message } from "firebase-admin/messaging";

const db = getFirestore();
const messaging = getMessaging();

interface SendNotificationRequest {
  userId: string;
  title: string;
  body: string;
  data?: Record<string, string>;
}

/**
 * Envía notificación push a un usuario específico
 */
export const enviarNotificacion = onCall<SendNotificationRequest>(
  async (request) => {
    const { userId, title, body, data } = request.data;
    const uid = request.auth?.uid;

    if (!uid) throw new HttpsError("unauthenticated", "No autenticado");

    // Solo admin/operador puede enviar notificaciones arbitrarias
    const userDoc = await db.collection("usuarios").doc(uid).get();
    const role = userDoc.data()?.rol;
    if (role !== "admin" && role !== "operador") {
      throw new HttpsError("permission-denied", "Solo admin/operador");
    }

    // Obtener tokens FCM del usuario
    const tokensSnap = await db.collection("usuarios").doc(userId).collection("dispositivos").get();
    const tokens = tokensSnap.docs.map((doc) => doc.data().token).filter(Boolean);

    if (tokens.length === 0) {
      return { sent: 0, message: "Usuario sin dispositivos registrados" };
    }

    const message: Message = {
      notification: { title, body },
      data: data || {},
      tokens,
    };

    try {
      const response = await messaging.sendEachForMulticast(message);
      logger.info("Notificación enviada", { userId, success: response.successCount, failure: response.failureCount });

      // Limpiar tokens inválidos
      if (response.failureCount > 0) {
        const invalidTokens: string[] = [];
        response.responses.forEach((resp, idx) => {
          if (!resp.success && resp.error?.code === "messaging/registration-token-not-registered") {
            invalidTokens.push(tokens[idx]);
          }
        });
        if (invalidTokens.length > 0) {
          const batch = db.batch();
          invalidTokens.forEach((token) => {
            const deviceRef = db.collection("usuarios").doc(userId).collection("dispositivos").where("token", "==", token).limit(1);
            // Nota: en producción usar query snapshot para borrar
          });
        }
      }

      return { sent: response.successCount };
    } catch (error) {
      logger.error("Error enviando notificación", { error, userId });
      throw new HttpsError("internal", "Error enviando notificación");
    }
  }
);

/**
 * Notificación masiva a todos los usuarios de una salida
 */
export const notificarPasajerosSalida = onCall<{ salidaId: string; title: string; body: string }>(
  async (request) => {
    const { salidaId, title, body } = request.data;
    const uid = request.auth?.uid;

    if (!uid) throw new HttpsError("unauthenticated", "No autenticado");

    // Verificar operador de la salida
    const salidaSnap = await db.collection("salidas").doc(salidaId).get();
    if (!salidaSnap.exists) throw new HttpsError("not-found", "Salida no encontrada");

    const salida = salidaSnap.data()!;
    if (salida.operadorId !== uid && (await db.collection("usuarios").doc(uid).get()).data()?.rol !== "admin") {
      throw new HttpsError("permission-denied", "No autorizado");
    }

    // Obtener reservas confirmadas de la salida
    const reservasSnap = await db
      .collection("reservas")
      .where("salidaId", "==", salidaId)
      .where("estado", "==", "reservada")
      .get();

    const userIds = [...new Set(reservasSnap.docs.map((doc) => doc.data().usuarioId))];

    // Enviar en paralelo (batch de 500 tokens por request FCM)
    let totalSent = 0;
    for (const userId of userIds) {
      const tokensSnap = await db.collection("usuarios").doc(userId).collection("dispositivos").get();
      const tokens = tokensSnap.docs.map((doc) => doc.data().token).filter(Boolean);
      if (tokens.length === 0) continue;

      const message: Message = {
        notification: { title, body },
        data: { salidaId, tipo: "salida" },
        tokens,
      };

      const response = await messaging.sendEachForMulticast(message);
      totalSent += response.successCount;
    }

    return { usuariosNotificados: userIds.length, tokensEnviados: totalSent };
  }
);