// Triggers de reportes (schema canónico: reportadoPor)
import { onDocumentCreated, onDocumentUpdated } from "firebase-functions/v2/firestore";
import * as logger from "firebase-functions/logger";
import { getFirestore } from "firebase-admin/firestore";
import { getMessaging, Message } from "firebase-admin/messaging";

const db = getFirestore();
const messaging = getMessaging();

export const onReporteCreated = onDocumentCreated("reportes/{reporteId}", async (event) => {
  const reporte = event.data?.data();
  if (!reporte) return;

  const { tipo, reportadoPor, salidaId } = reporte;
  const reporteId = event.params.reporteId;

  const adminsSnap = await db
    .collection("usuarios")
    .where("rol", "==", "administrador")
    .get();
  const adminIds = adminsSnap.docs.map((doc) => doc.id);

  let operadorId: string | null = null;
  if (salidaId) {
    const salidaSnap = await db.collection("salidas").doc(salidaId).get();
    operadorId = salidaSnap.data()?.operadorId ?? null;
  }

  const destinatarios = new Set([
    ...adminIds,
    ...(operadorId ? [operadorId] : []),
  ]);
  if (typeof reportadoPor === "string") {
    destinatarios.delete(reportadoPor);
  }

  const title = "Nuevo reporte";
  const body =
    typeof reporte.descripcion === "string" && reporte.descripcion.length > 100
      ? `${reporte.descripcion.slice(0, 100)}...`
      : (reporte.descripcion as string) || String(tipo ?? "incidencia");

  for (const destId of destinatarios) {
    const tokensSnap = await db
      .collection("usuarios")
      .doc(destId)
      .collection("dispositivos")
      .get();
    const tokens = tokensSnap.docs
      .map((doc) => doc.data().fcmToken ?? doc.data().token)
      .filter(Boolean);
    if (tokens.length === 0) continue;

    const message: Message = {
      notification: { title, body },
      data: {
        reporteId,
        tipo: String(tipo ?? ""),
        salidaId: salidaId || "",
      },
      tokens,
    };
    await messaging.sendEachForMulticast(message);
  }

  logger.info("Notificación reporte enviada", {
    reporteId,
    destinatarios: destinatarios.size,
  });
});

export const onReporteUpdated = onDocumentUpdated("reportes/{reporteId}", async (event) => {
  const before = event.data?.before.data();
  const after = event.data?.after.data();
  if (!before || !after) return;

  const { reportadoPor, estado } = after;
  const reporteId = event.params.reporteId;

  if (before.estado === "cerrado" && after.estado === "cerrado") return;
  if (estado !== "cerrado") return;
  if (typeof reportadoPor !== "string") return;

  const tokensSnap = await db
    .collection("usuarios")
    .doc(reportadoPor)
    .collection("dispositivos")
    .get();
  const tokens = tokensSnap.docs
    .map((doc) => doc.data().fcmToken ?? doc.data().token)
    .filter(Boolean);
  if (tokens.length === 0) return;

  const message: Message = {
    notification: {
      title: "Tu reporte fue atendido",
      body: "El equipo revisó tu reporte",
    },
    data: { reporteId, tipo: "reporte_resuelto" },
    tokens,
  };

  await messaging.sendEachForMulticast(message);
});
