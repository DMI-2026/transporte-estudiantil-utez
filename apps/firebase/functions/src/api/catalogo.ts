// Endpoints de Catálogo - Salidas, GPS, Rutas (solo lectura desde cliente, escritura admin/operador)
import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import { getFirestore, FieldValue, GeoPoint } from "firebase-admin/firestore";

const db = getFirestore();

/**
 * Crea nueva salida programada (solo admin)
 */
export const crearSalida = onCall<{
  rutaId: string;
  horaSalida: string; // ISO string
  cupoTotal: number;
  operadorId: string;
  vehiculoId: string;
}>(async (request) => {
  const adminUid = request.auth?.uid;
  if (!adminUid) throw new HttpsError("unauthenticated", "No autenticado");

  const adminDoc = await db.collection("usuarios").doc(adminUid).get();
  if (adminDoc.data()?.rol !== "admin") {
    throw new HttpsError("permission-denied", "Solo administradores");
  }

  const { rutaId, horaSalida, cupoTotal, operadorId, vehiculoId } = request.data;

  // Verificar operador existe y tiene rol operador
  const operadorSnap = await db.collection("usuarios").doc(operadorId).get();
  if (!operadorSnap.exists || operadorSnap.data()?.rol !== "operador") {
    throw new HttpsError("invalid-argument", "Operador inválido");
  }

  // Verificar ruta existe
  const rutaSnap = await db.collection("rutas").doc(rutaId).get();
  if (!rutaSnap.exists) throw new HttpsError("not-found", "Ruta no encontrada");

  const salidaRef = db.collection("salidas").doc();
  await salidaRef.set({
    rutaId,
    horaSalida: new Date(horaSalida),
    cupoTotal,
    cuposDisponibles: cupoTotal,
    operadorId,
    vehiculoId,
    estado: "programada",
    qrGenerado: false,
    abordados: 0,
    creadaEn: FieldValue.serverTimestamp(),
    creadaPor: adminUid,
  });

  // Set custom claim para que operador pueda leer QR privado
  await db.collection("usuarios").doc(operadorId).update({
    operadorSalidaId: salidaRef.id, // Se usa en reglas Firestore
  });

  logger.info("Salida creada", { salidaId: salidaRef.id, adminUid });
  return { salidaId: salidaRef.id };
});

/**
 * Actualiza ubicación de salida en tiempo real (solo operador de esa salida)
 * Se llama cada 5-10 segundos desde app operador
 */
export const actualizarUbicacionSalida = onCall<{
  salidaId: string;
  latitud: number;
  longitud: number;
  velocidad?: number;
  rumbo?: number;
}>(async (request) => {
  const { salidaId, latitud, longitud, velocidad, rumbo } = request.data;
  const uid = request.auth?.uid;

  if (!uid) throw new HttpsError("unauthenticated", "No autenticado");

  const salidaSnap = await db.collection("salidas").doc(salidaId).get();
  if (!salidaSnap.exists) throw new HttpsError("not-found", "Salida no encontrada");

  const salida = salidaSnap.data()!;
  if (salida.operadorId !== uid) {
    throw new HttpsError("permission-denied", "No eres el operador de esta salida");
  }

  if (salida.estado !== "enCurso") {
    throw new HttpsError("failed-precondition", "Solo salidas en curso actualizan ubicación");
  }

  await db.collection("salidas").doc(salidaId).update({
    ubicacion: new GeoPoint(latitud, longitud),
    velocidad: velocidad ?? null,
    rumbo: rumbo ?? null,
    ubicacionActualizadaEn: FieldValue.serverTimestamp(),
  });

  return { success: true };
});

/**
 * Inicia salida (cambia estado a enCurso) - solo operador
 */
export const iniciarSalida = onCall<{ salidaId: string }>(async (request) => {
  const { salidaId } = request.data;
  const uid = request.auth?.uid;

  if (!uid) throw new HttpsError("unauthenticated", "No autenticado");

  const salidaSnap = await db.collection("salidas").doc(salidaId).get();
  if (!salidaSnap.exists) throw new HttpsError("not-found", "Salida no encontrada");

  const salida = salidaSnap.data()!;
  if (salida.operadorId !== uid) {
    throw new HttpsError("permission-denied", "No autorizado");
  }

  if (salida.estado !== "programada") {
    throw new HttpsError("failed-precondition", "Solo salidas programadas se inician");
  }

  await db.collection("salidas").doc(salidaId).update({
    estado: "enCurso",
    iniciadaEn: FieldValue.serverTimestamp(),
  });

  return { success: true };
});

/**
 * Finaliza salida - solo operador
 */
export const finalizarSalida = onCall<{ salidaId: string }>(async (request) => {
  const { salidaId } = request.data;
  const uid = request.auth?.uid;

  if (!uid) throw new HttpsError("unauthenticated", "No autenticado");

  const salidaSnap = await db.collection("salidas").doc(salidaId).get();
  if (!salidaSnap.exists) throw new HttpsError("not-found", "Salida no encontrada");

  const salida = salidaSnap.data()!;
  if (salida.operadorId !== uid) {
    throw new HttpsError("permission-denied", "No autorizado");
  }

  await db.collection("salidas").doc(salidaId).update({
    estado: "finalizada",
    finalizadaEn: FieldValue.serverTimestamp(),
  });

  return { success: true };
});