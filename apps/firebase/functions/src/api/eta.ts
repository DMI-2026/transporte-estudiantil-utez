// ETA de viaje vía OpenRouteService (clave solo en Functions).
import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import { getFirestore } from "firebase-admin/firestore";

const db = getFirestore();

/**
 * Calcula minutos estimados desde ubicacionActual de la salida hasta la
 * parada del estudiante. Cliente: httpsCallable('obtenerEtaViaje').
 */
export const obtenerEtaViaje = onCall<{
  salidaId: string;
  reservaId: string;
}>(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Usuario no autenticado");
  }

  const { salidaId, reservaId } = request.data;
  if (!salidaId || !reservaId) {
    throw new HttpsError("invalid-argument", "salidaId y reservaId son obligatorios");
  }

  const reservaSnap = await db.collection("reservas").doc(reservaId).get();
  if (!reservaSnap.exists) {
    throw new HttpsError("not-found", "Reserva no encontrada");
  }
  const reserva = reservaSnap.data()!;
  if (reserva.estudianteId !== uid) {
    throw new HttpsError("permission-denied", "No autorizado");
  }
  if (reserva.salidaId !== salidaId) {
    throw new HttpsError("failed-precondition", "La reserva no corresponde a la salida");
  }

  const salidaSnap = await db.collection("salidas").doc(salidaId).get();
  if (!salidaSnap.exists) {
    throw new HttpsError("not-found", "Salida no encontrada");
  }
  const salida = salidaSnap.data()!;
  const ubicacion = salida.ubicacionActual;
  if (!ubicacion || typeof ubicacion.latitude !== "number") {
    throw new HttpsError(
      "failed-precondition",
      "La unidad aún no reporta ubicación",
    );
  }

  const paradaSnap = await db.collection("paradas").doc(reserva.paradaId).get();
  if (!paradaSnap.exists) {
    throw new HttpsError("not-found", "Parada no encontrada");
  }
  const paradaUbicacion = paradaSnap.data()?.ubicacion;
  if (!paradaUbicacion || typeof paradaUbicacion.latitude !== "number") {
    throw new HttpsError("failed-precondition", "Parada sin coordenadas");
  }

  const apiKey = process.env.ORS_API_KEY;
  if (!apiKey) {
    throw new HttpsError("failed-precondition", "ORS no configurado en Functions");
  }

  const start = `${ubicacion.longitude},${ubicacion.latitude}`;
  const end = `${paradaUbicacion.longitude},${paradaUbicacion.latitude}`;
  const url =
    `https://api.openrouteservice.org/v2/directions/driving-car` +
    `?start=${encodeURIComponent(start)}&end=${encodeURIComponent(end)}`;

  try {
    const response = await fetch(url, {
      headers: { Authorization: apiKey, Accept: "application/json" },
    });
    if (!response.ok) {
      logger.error("ORS error", { status: response.status, salidaId });
      throw new HttpsError("internal", "No se pudo calcular el ETA");
    }
    const body = (await response.json()) as {
      features?: Array<{
        properties?: { summary?: { duration?: number } };
      }>;
    };
    const durationSec = body.features?.[0]?.properties?.summary?.duration;
    if (typeof durationSec !== "number") {
      throw new HttpsError("internal", "Respuesta ORS inválida");
    }
    const minutos = Math.max(1, Math.round(durationSec / 60));
    return { minutos, actualizadoEn: new Date().toISOString() };
  } catch (error) {
    if (error instanceof HttpsError) throw error;
    logger.error("ETA falló", { error, salidaId });
    throw new HttpsError("internal", "No se pudo calcular el ETA");
  }
});
