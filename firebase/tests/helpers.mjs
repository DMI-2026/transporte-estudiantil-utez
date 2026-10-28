import { readFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { initializeTestEnvironment } from '@firebase/rules-unit-testing';
import { doc, setDoc } from 'firebase/firestore';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const rulesDir = path.join(__dirname, '..');

export const PROJECT_ID = 'demo-utebus-rules';

export const UIDS = {
  estudiante: 'est-aprobado',
  estudiantePendiente: 'est-pendiente',
  operador: 'op-asignado',
  otroOperador: 'op-otro',
  admin: 'admin-1',
};

export async function crearEntorno() {
  return initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      rules: readFileSync(path.join(rulesDir, 'firestore.rules'), 'utf8'),
    },
    storage: {
      rules: readFileSync(path.join(rulesDir, 'storage.rules'), 'utf8'),
    },
  });
}

/** Perfiles y documentos base, escritos con las reglas desactivadas. */
export async function sembrar(env) {
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    const ahora = new Date();

    const perfil = (rol, estado) => ({
      email: `${rol}@utez.edu.mx`,
      nombreCompleto: `Demo ${rol}`,
      rol,
      estadoVerificacion: estado,
      creadoEn: ahora,
    });

    await setDoc(doc(db, 'usuarios', UIDS.estudiante), perfil('estudiante', 'aprobada'));
    await setDoc(doc(db, 'usuarios', UIDS.estudiantePendiente), perfil('estudiante', 'pendiente'));
    await setDoc(doc(db, 'usuarios', UIDS.operador), perfil('operador', 'aprobada'));
    await setDoc(doc(db, 'usuarios', UIDS.otroOperador), perfil('operador', 'aprobada'));
    await setDoc(doc(db, 'usuarios', UIDS.admin), perfil('administrador', 'aprobada'));

    await setDoc(doc(db, 'rutas', 'r1'), { nombre: 'Ruta 1', activa: true, creadoEn: ahora });
    await setDoc(doc(db, 'paradas', 'p1'), { rutaId: 'r1', nombre: 'Parada 1', orden: 1, activa: true });

    await setDoc(doc(db, 'salidas', 's1'), {
      rutaId: 'r1',
      operadorId: UIDS.operador,
      fechaHoraSalida: ahora,
      estado: 'programada',
      asientosTotales: 40,
      asientosDisponibles: 40,
      actualizadoEn: ahora,
    });
    await setDoc(doc(db, 'salidas', 's1', 'privado', 'qr'), {
      tokenHash: 'hash-secreto',
      rotacionEn: ahora,
    });

    await setDoc(doc(db, 'reservas', `s1_${UIDS.estudiante}`), {
      salidaId: 's1',
      estudianteId: UIDS.estudiante,
      paradaId: 'p1',
      estado: 'reservada',
      creadaEn: ahora,
    });

    await setDoc(doc(db, 'pagos', 'pago1'), {
      reservaId: `s1_${UIDS.estudiante}`,
      salidaId: 's1',
      estudianteId: UIDS.estudiante,
      monto: 15,
      estado: 'pendiente',
      creadoEn: ahora,
    });

    await setDoc(doc(db, 'reportes', 'rep-con-salida'), {
      reportadoPor: UIDS.estudiante,
      salidaId: 's1',
      tipo: 'retraso',
      descripcion: 'Demo',
      estado: 'abierto',
      creadoEn: ahora,
    });
    await setDoc(doc(db, 'reportes', 'rep-sin-salida'), {
      reportadoPor: UIDS.estudiante,
      tipo: 'otro',
      descripcion: 'Demo',
      estado: 'abierto',
      creadoEn: ahora,
    });
  });
}

export function como(env, uid) {
  return env.authenticatedContext(uid).firestore();
}

export function anonimo(env) {
  return env.unauthenticatedContext().firestore();
}
