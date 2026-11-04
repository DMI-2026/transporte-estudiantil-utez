import { test, before, after, beforeEach } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { getBytes, ref, uploadBytes } from 'firebase/storage';

import { UIDS, crearEntorno } from './helpers.mjs';

let env;
const imagen = new Uint8Array([137, 80, 78, 71]);

before(async () => {
  env = await crearEntorno();
});

beforeEach(async () => {
  await env.clearStorage();
  await env.withSecurityRulesDisabled(async (ctx) => {
    const st = ctx.storage();
    await uploadBytes(ref(st, `credenciales/${UIDS.estudiante}/credencial.png`), imagen, {
      contentType: 'image/png',
    });
    await uploadBytes(ref(st, 'documentacion/publico/aviso-privacidad.pdf'), imagen, {
      contentType: 'application/pdf',
    });
    await uploadBytes(ref(st, `documentacion/${UIDS.estudiante}/constancia.pdf`), imagen, {
      contentType: 'application/pdf',
    });
  });
});

after(async () => {
  await env.cleanup();
});

const storageDe = (uid) => env.authenticatedContext(uid).storage();

test('credenciales: solo el dueño lee y sube; solo imágenes', async () => {
  const propia = `credenciales/${UIDS.estudiante}/credencial.png`;
  await assertSucceeds(getBytes(ref(storageDe(UIDS.estudiante), propia)));
  await assertFails(getBytes(ref(storageDe(UIDS.operador), propia)));
  await assertFails(getBytes(ref(env.unauthenticatedContext().storage(), propia)));

  await assertSucceeds(
    uploadBytes(ref(storageDe(UIDS.estudiante), `credenciales/${UIDS.estudiante}/otra.png`), imagen, {
      contentType: 'image/png',
    }),
  );
  await assertFails(
    uploadBytes(ref(storageDe(UIDS.estudiante), `credenciales/${UIDS.estudiante}/doc.pdf`), imagen, {
      contentType: 'application/pdf',
    }),
  );
  await assertFails(
    uploadBytes(ref(storageDe(UIDS.operador), `credenciales/${UIDS.estudiante}/intruso.png`), imagen, {
      contentType: 'image/png',
    }),
  );
});

test('documentacion/publico: cualquier autenticado lee; nadie escribe; un anónimo no lee', async () => {
  const archivo = 'documentacion/publico/aviso-privacidad.pdf';
  await assertSucceeds(getBytes(ref(storageDe(UIDS.estudiante), archivo)));
  await assertSucceeds(getBytes(ref(storageDe(UIDS.operador), archivo)));
  await assertFails(getBytes(ref(env.unauthenticatedContext().storage(), archivo)));
  await assertFails(
    uploadBytes(ref(storageDe(UIDS.admin), 'documentacion/publico/nuevo.pdf'), imagen, {
      contentType: 'application/pdf',
    }),
  );
});

test('documentacion/{uid}: solo el dueño lee; otro usuario no; nadie escribe', async () => {
  const propia = `documentacion/${UIDS.estudiante}/constancia.pdf`;
  await assertSucceeds(getBytes(ref(storageDe(UIDS.estudiante), propia)));
  await assertFails(getBytes(ref(storageDe(UIDS.operador), propia)));
  await assertFails(getBytes(ref(storageDe(UIDS.admin), propia)));
  await assertFails(
    uploadBytes(
      ref(storageDe(UIDS.estudiante), `documentacion/${UIDS.estudiante}/otro.pdf`),
      imagen,
      { contentType: 'application/pdf' },
    ),
  );
});

test('reportes: el autor sube fotos en su carpeta; otro usuario no', async () => {
  const propia = `reportes/${UIDS.estudiante}/rep1/foto.png`;
  await assertSucceeds(
    uploadBytes(ref(storageDe(UIDS.estudiante), propia), imagen, { contentType: 'image/png' }),
  );
  await assertFails(
    uploadBytes(ref(storageDe(UIDS.operador), propia), imagen, { contentType: 'image/png' }),
  );
});
