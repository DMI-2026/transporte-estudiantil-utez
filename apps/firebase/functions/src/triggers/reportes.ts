// Triggers de Firestore para colección reportes (incidencias)
import { onDocumentCreated, onDocumentUpdated } from "firebase-functions/v2/firestore";
import * as logger from "firebase-functions/logger";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { getMessaging, Message } from "firebase-admin/messaging";

const db = getFirestore();
const messaging = getMessaging();

/**
 * Cuando se crea un reporte -> notificar a admins y operador relevante
 */
export const onReporteCreated = onDocumentCreated("reportes/{reporteId}", async (event) => {
  const reporte = event.data?.data();
  if (!reporte) return;

  const { tipo, prioridad, usuarioId, salidaId, rutaId } = reporte;
  const reporteId = event.params.reporteId;

  // 1. Notificar a todos los admins
  const adminsSnap = await db.collection("usuarios").where("rol", "==", "admin").get();
  const adminIds = adminsSnap.docs.map((doc) => doc.id);

  // 2. Si hay salidaId, notificar al operador de esa salida
  let operadorId: string | null = null;
  if (salidaId) {
    const salidaSnap = await db.collection("salidas").doc(salidaId).get();
    operadorId = salidaSnap.data()?.operadorId ?? null;
  }

  // 3. Si hay rutaId y prioridad alta/critica, notificar operadores de esa ruta
  let operadoresRuta: string[] = [];
  if (rutaId && (prioridad === "alta" || prioridad === "critica")) {
    // Buscar salidas activas de esa ruta
    const salidasSnap = await db
      .collection("salidas")
      .where("rutaId", "==", rutaId)
      .where("estado", "in", ["programada", "enCurso"])
      .get();
    operadoresRuta = [...new Set(salidasSnap.docs.map((doc) => doc.data().operadorId).filter(Boolean))];
  }

  // Consolidar destinatarios únicos
  const destinatarios = new Set([...adminIds, ...(operadorId ? [operadorId] : []), ...operadoresRuta]);
  destinatarios.delete(usuarioId); // No notificar al que reportó

  const title = `🚨 ${tipo.charAt(0).toUpperCase() + tipo.slice(1)} - ${prioridad.toUpperCase()}`;
  const body = reporte.titulo.length > 100 ? reporte.titulo.slice(0, 100) + "..." : reporte.titulo;

  for (const destId of destinatarios) {
    const tokensSnap = await db.collection("usuarios").doc(destId).collection("dispositivos").get();
    const tokens = tokensSnap.docs.map((doc) => doc.data().token).filter(Boolean);
    if (tokens.length === 0) continue;

    const message: Message = {
      notification: { title, body },
      data: { reporteId, tipo, prioridad, salidaId: salidaId || "", rutaId: rutaId || "" },
      tokens,
    };
    await messaging.sendEachForMulticast(message);
  }

  logger.info("Notificación reporte enviada", { reporteId, destinatarios: destinatarios.size });
});

/**
 * Cuando se actualiza reporte (ej. se resuelve) -> notificar al reportante
 */
export const onReporteUpdated = onDocumentUpdated("reportes/{reporteId}", async (event) => {
  const before = event.data?.before.data();
  const after = event.data?.after.data();
  if (!before || !after) return;

  const { usuarioId, estado, resolucion } = after;
  const reporteId = event.params.reporteId;

  // Solo notificar si se cerró/resolvió
  if (before.estado === "cerrado" && after.estado === "cerrado") return;
  if (after.estado !== "cerrado") return;

  const tokensSnap = await db.collection("usuarios").doc(usuarioId).collection("dispositivos").get();
  const tokens = tokensSnap.docs.map((doc) => doc.data().token).filter(Boolean);
  if (tokens.length === 0) return;

  const message: Message = {
    notification: {
      title: "Tu reporte fue atendido",
      body: resolucion ? `Resolución: ${resolucion.slice(0, 100)}` : "El equipo revisó tu reporte",
    },
    data: { reporteId, tipo: "reporte_resuelto" },
    tokens,
  };

  await messaging.sendEachForMulticast(message);
});