import { test, before, after, beforeEach } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { doc, getDoc, setDoc, updateDoc, deleteDoc } from 'firebase/firestore';

import { UIDS, anonimo, como, crearEntorno, sembrar } from './helpers.mjs';

let env;

before(async () => {
  env = await crearEntorno();
});

beforeEach(async () => {
  await env.clearFirestore();
  await sembrar(env);
});

after(async () => {
  await env.cleanup();
});

// --- usuarios ---------------------------------------------------------------

test('usuarios: cada quien lee su perfil; el admin lee cualquiera; un anónimo no lee', async () => {
  await assertSucceeds(getDoc(doc(como(env, UIDS.estudiante), 'usuarios', UIDS.estudiante)));
  await assertFails(getDoc(doc(como(env, UIDS.estudiante), 'usuarios', UIDS.operador)));
  await assertSucceeds(getDoc(doc(como(env, UIDS.admin), 'usuarios', UIDS.estudiante)));
  await assertFails(getDoc(doc(anonimo(env), 'usuarios', UIDS.estudiante)));
});

test('usuarios: el cliente no cambia rol, estadoVerificacion ni email; sí su nombre', async () => {
  const yo = doc(como(env, UIDS.estudiante), 'usuarios', UIDS.estudiante);
  await assertFails(updateDoc(yo, { rol: 'administrador' }));
  await assertFails(updateDoc(yo, { estadoVerificacion: 'rechazada' }));
  // Escribir el mismo valor no cambia nada: no cuenta como modificación.
  const pendiente = doc(como(env, UIDS.estudiantePendiente), 'usuarios', UIDS.estudiantePendiente);
  await assertFails(updateDoc(pendiente, { estadoVerificacion: 'aprobada' }));
  await assertFails(updateDoc(yo, { email: 'otro@utez.edu.mx' }));
  await assertSucceeds(updateDoc(yo, { nombreCompleto: 'Nuevo nombre' }));
});

test('usuarios: al registrarse solo se permite estudiante u operador en estado pendiente', async () => {
  const nuevo = (rol, estado) =>
    setDoc(doc(como(env, 'nuevo-uid'), 'usuarios', 'nuevo-uid'), {
      email: 'n@utez.edu.mx',
      rol,
      estadoVerificacion: estado,
      creadoEn: new Date(),
    });
  await assertFails(nuevo('administrador', 'pendiente'));
  await assertFails(nuevo('estudiante', 'aprobada'));
  await assertSucceeds(nuevo('estudiante', 'pendiente'));
});

// --- catálogo ---------------------------------------------------------------

test('rutas: solo cuentas aprobadas leen; solo el admin escribe', async () => {
  await assertSucceeds(getDoc(doc(como(env, UIDS.estudiante), 'rutas', 'r1')));
  await assertFails(getDoc(doc(como(env, UIDS.estudiantePendiente), 'rutas', 'r1')));
  await assertFails(updateDoc(doc(como(env, UIDS.estudiante), 'rutas', 'r1'), { activa: false }));
  await assertSucceeds(updateDoc(doc(como(env, UIDS.admin), 'rutas', 'r1'), { activa: false }));
});

// --- salidas y QR -----------------------------------------------------------

test('salidas: el operador asignado cambia estado; no puede reasignarse la salida', async () => {
  const salida = doc(como(env, UIDS.operador), 'salidas', 's1');
  await assertSucceeds(updateDoc(salida, { estado: 'enCurso', actualizadoEn: new Date() }));
  await assertFails(updateDoc(salida, { operadorId: UIDS.otroOperador }));
  await assertFails(
    updateDoc(doc(como(env, UIDS.otroOperador), 'salidas', 's1'), { estado: 'enCurso' }),
  );
});

test('QR: lo lee el operador asignado o el admin; nadie más lo lee y nadie lo escribe', async () => {
  const ruta = ['salidas', 's1', 'privado', 'qr'];
  await assertSucceeds(getDoc(doc(como(env, UIDS.operador), ...ruta)));
  await assertSucceeds(getDoc(doc(como(env, UIDS.admin), ...ruta)));
  await assertFails(getDoc(doc(como(env, UIDS.otroOperador), ...ruta)));
  await assertFails(getDoc(doc(como(env, UIDS.estudiante), ...ruta)));
  await assertFails(updateDoc(doc(como(env, UIDS.admin), ...ruta), { tokenHash: 'nuevo' }));
  await assertFails(updateDoc(doc(como(env, UIDS.operador), ...ruta), { tokenHash: 'nuevo' }));
});

// --- reservas ---------------------------------------------------------------

test('reservas: el id debe ser {salidaId}_{uid} y la cuenta debe estar aprobada', async () => {
  const datos = (uid) => ({
    salidaId: 's1',
    estudianteId: uid,
    paradaId: 'p1',
    estado: 'reservada',
    creadaEn: new Date(),
  });
  const otroEst = 'est-aprobado-2';
  await env.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), 'usuarios', otroEst), {
      email: 'x@utez.edu.mx',
      rol: 'estudiante',
      estadoVerificacion: 'aprobada',
      creadoEn: new Date(),
    });
  });

  await assertSucceeds(setDoc(doc(como(env, otroEst), 'reservas', `s1_${otroEst}`), datos(otroEst)));
  await assertFails(setDoc(doc(como(env, otroEst), 'reservas', 'id-libre'), datos(otroEst)));
  await assertFails(
    setDoc(
      doc(como(env, UIDS.estudiantePendiente), 'reservas', `s1_${UIDS.estudiantePendiente}`),
      datos(UIDS.estudiantePendiente),
    ),
  );
});

test('reservas: el estudiante no se marca a sí mismo como abordada; el operador asignado sí', async () => {
  const id = `s1_${UIDS.estudiante}`;
  await assertFails(updateDoc(doc(como(env, UIDS.estudiante), 'reservas', id), { estado: 'abordada' }));
  await assertSucceeds(
    updateDoc(doc(como(env, UIDS.operador), 'reservas', id), {
      estado: 'abordada',
      actualizadoEn: new Date(),
    }),
  );
  await assertFails(
    updateDoc(doc(como(env, UIDS.otroOperador), 'reservas', id), { estado: 'abordada' }),
  );
});

// --- pagos ------------------------------------------------------------------

test('pagos: el cliente solo crea en pendiente y nunca actualiza', async () => {
  const base = {
    reservaId: `s1_${UIDS.estudiante}`,
    salidaId: 's1',
    estudianteId: UIDS.estudiante,
    monto: 15,
    creadoEn: new Date(),
  };
  const db = como(env, UIDS.estudiante);
  await assertSucceeds(setDoc(doc(db, 'pagos', 'nuevo-pendiente'), { ...base, estado: 'pendiente' }));
  await assertFails(setDoc(doc(db, 'pagos', 'nuevo-aprobado'), { ...base, estado: 'aprobado' }));
  await assertFails(updateDoc(doc(db, 'pagos', 'pago1'), { estado: 'aprobado' }));
  await assertFails(updateDoc(doc(como(env, UIDS.admin), 'pagos', 'pago1'), { estado: 'aprobado' }));
  await assertFails(deleteDoc(doc(como(env, UIDS.admin), 'pagos', 'pago1')));
});

// --- reportes ---------------------------------------------------------------

test('reportes: el autor y el admin leen; el operador solo los de sus salidas', async () => {
  await assertSucceeds(getDoc(doc(como(env, UIDS.estudiante), 'reportes', 'rep-con-salida')));
  await assertSucceeds(getDoc(doc(como(env, UIDS.admin), 'reportes', 'rep-sin-salida')));
  await assertSucceeds(getDoc(doc(como(env, UIDS.operador), 'reportes', 'rep-con-salida')));
  await assertFails(getDoc(doc(como(env, UIDS.otroOperador), 'reportes', 'rep-con-salida')));
  await assertFails(getDoc(doc(como(env, UIDS.operador), 'reportes', 'rep-sin-salida')));
});
