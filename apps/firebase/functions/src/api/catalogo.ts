// Catálogo: salidas y GPS (schema canónico docs/05-datos.md)
import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import { getFirestore, FieldValue, GeoPoint } from "firebase-admin/firestore";

const db = getFirestore();

/**
 * Crea nueva salida programada (solo administrador).
 */
export const crearSalida = onCall<{
  rutaId: string;
  fechaHoraSalida: string; // ISO
  asientosTotales: number;
  operadorId: string;
}>(async (request) => {
  const adminUid = request.auth?.uid;
  if (!adminUid) throw new HttpsError("unauthenticated", "No autenticado");

  const adminDoc = await db.collection("usuarios").doc(adminUid).get();
  if (adminDoc.data()?.rol !== "administrador") {
    throw new HttpsError("permission-denied", "Solo administradores");
  }

  const { rutaId, fechaHoraSalida, asientosTotales, operadorId } = request.data;

  const operadorSnap = await db.collection("usuarios").doc(operadorId).get();
  if (!operadorSnap.exists || operadorSnap.data()?.rol !== "operador") {
    throw new HttpsError("invalid-argument", "Operador inválido");
  }

  const rutaSnap = await db.collection("rutas").doc(rutaId).get();
  if (!rutaSnap.exists) throw new HttpsError("not-found", "Ruta no encontrada");

  const salidaRef = db.collection("salidas").doc();
  await salidaRef.set({
    rutaId,
    operadorId,
    fechaHoraSalida: new Date(fechaHoraSalida),
    estado: "programada",
    asientosTotales,
    asientosDisponibles: asientosTotales,
    actualizadoEn: FieldValue.serverTimestamp(),
  });

  logger.info("Salida creada", { salidaId: salidaRef.id, adminUid });
  return { salidaId: salidaRef.id };
});

/**
 * Actualiza ubicación de salida en curso (operador asignado).
 */
export const actualizarUbicacionSalida = onCall<{
  salidaId: string;
  latitud: number;
  longitud: number;
}>(async (request) => {
  const { salidaId, latitud, longitud } = request.data;
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
    ubicacionActual: new GeoPoint(latitud, longitud),
    actualizadoEn: FieldValue.serverTimestamp(),
  });

  return { success: true };
});

/**
 * Inicia salida (estado enCurso).
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
    actualizadoEn: FieldValue.serverTimestamp(),
  });

  return { success: true };
});

/**
 * Finaliza salida.
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
    actualizadoEn: FieldValue.serverTimestamp(),
  });

  return { success: true };
});
