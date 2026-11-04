// Endpoints de Administración - Verificación de cuentas y catálogo
import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import { getFirestore, FieldValue, Query } from "firebase-admin/firestore";
import { getAuth } from "firebase-admin/auth";

const db = getFirestore();
const auth = getAuth();

/**
 * Aprueba usuario pendiente (solo admin)
 */
export const aprobarUsuario = onCall<{ uid: string }>(
  async (request) => {
    const { uid } = request.data;
    const adminUid = request.auth?.uid;

    if (!adminUid) throw new HttpsError("unauthenticated", "No autenticado");

    // Verificar que el caller es admin
    const adminDoc = await db.collection("usuarios").doc(adminUid).get();
    if (adminDoc.data()?.rol !== "admin") {
      throw new HttpsError("permission-denied", "Solo administradores");
    }

    const userSnap = await db.collection("usuarios").doc(uid).get();
    if (!userSnap.exists) throw new HttpsError("not-found", "Usuario no encontrado");

    const userData = userSnap.data()!;
    if (userData.estadoVerificacion === "aprobada") {
      throw new HttpsError("already-exists", "Usuario ya aprobado");
    }

    // Actualizar Firestore + Custom Claims
    await db.collection("usuarios").doc(uid).update({
      estadoVerificacion: "aprobada",
      aprobadoEn: FieldValue.serverTimestamp(),
      aprobadoPor: adminUid,
    });

    await auth.setCustomUserClaims(uid, { rol: userData.rol, verificado: true });

    logger.info("Usuario aprobado", { uid, adminUid });
    return { success: true };
  }
);

/**
 * Rechaza usuario pendiente (solo admin)
 */
export const rechazarUsuario = onCall<{ uid: string; motivo: string }>(
  async (request) => {
    const { uid, motivo } = request.data;
    const adminUid = request.auth?.uid;

    if (!adminUid) throw new HttpsError("unauthenticated", "No autenticado");

    const adminDoc = await db.collection("usuarios").doc(adminUid).get();
    if (adminDoc.data()?.rol !== "admin") {
      throw new HttpsError("permission-denied", "Solo administradores");
    }

    await db.collection("usuarios").doc(uid).update({
      estadoVerificacion: "rechazada",
      rechazadoEn: FieldValue.serverTimestamp(),
      rechazadoPor: adminUid,
      motivoRechazo: motivo,
    });

    // Quitar custom claims
    await auth.setCustomUserClaims(uid, { verificado: false });

    logger.info("Usuario rechazado", { uid, adminUid, motivo });
    return { success: true };
  }
);

/**
 * Lista usuarios pendientes de verificación (paginado)
 */
export const listarPendientesVerificacion = onCall<{ limite?: number; cursor?: string }>(
  async (request) => {
    const adminUid = request.auth?.uid;
    if (!adminUid) throw new HttpsError("unauthenticated", "No autenticado");

    const adminDoc = await db.collection("usuarios").doc(adminUid).get();
    if (adminDoc.data()?.rol !== "admin") {
      throw new HttpsError("permission-denied", "Solo administradores");
    }

    const { limite = 20, cursor } = request.data;
    let query: Query = db
      .collection("usuarios")
      .where("estadoVerificacion", "==", "pendiente")
      .orderBy("creadoEn", "desc")
      .limit(limite + 1);

    if (cursor) {
      const cursorDoc = await db.collection("usuarios").doc(cursor).get();
      if (cursorDoc.exists) {
        query = query.startAfter(cursorDoc);
      }
    }

    const snap = await query.get();
    const usuarios = snap.docs.slice(0, limite).map((doc) => ({ uid: doc.id, ...doc.data() }));
    const nextCursor = snap.docs.length > limite ? snap.docs[limite].id : null;

    return { usuarios, nextCursor };
  }
);