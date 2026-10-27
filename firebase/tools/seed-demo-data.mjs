/**
 * Documentos demo (una muestra por colección) en Firestore producción.
 *
 * Credenciales (en orden):
 * 1. GOOGLE_APPLICATION_CREDENTIALS
 * 2. env/firebase-admin-sa.json (service account)
 * 3. Credenciales de `firebase login` (ADC en %APPDATA%/firebase/)
 * 4. Refresh token de firebase-tools, solo si se definen
 *    FIREBASE_TOOLS_CLIENT_ID y FIREBASE_TOOLS_CLIENT_SECRET en el entorno
 *    (nunca se incrustan en el repo).
 */
import { existsSync, readFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import os from 'node:os';
import { initializeApp, applicationDefault, cert } from 'firebase-admin/app';
import { getFirestore, Timestamp, GeoPoint } from 'firebase-admin/firestore';
import { GoogleAuth } from 'google-auth-library';
import { Firestore } from '@google-cloud/firestore';

const FIREBASE_CLIENT_ID = process.env.FIREBASE_TOOLS_CLIENT_ID ?? null;
const FIREBASE_CLIENT_SECRET = process.env.FIREBASE_TOOLS_CLIENT_SECRET ?? null;

const projectId = process.env.FIREBASE_PROJECT_ID ?? 'utebus-4435b';
const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(__dirname, '..', '..');

function emailToAdcSlug(email) {
  return email.replace('@', '_').replace('.', '_');
}

function firebaseToolsConfigPaths() {
  const paths = [];
  if (process.env.APPDATA) {
    paths.push(path.join(process.env.APPDATA, 'configstore', 'firebase-tools.json'));
  }
  paths.push(
    path.join(os.homedir(), '.config', 'configstore', 'firebase-tools.json'),
  );
  return paths;
}

function readFirebaseToolsConfig() {
  for (const configPath of firebaseToolsConfigPaths()) {
    if (existsSync(configPath)) {
      return JSON.parse(readFileSync(configPath, 'utf8'));
    }
  }
  return null;
}

function resolveCredentialsPath() {
  if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    return process.env.GOOGLE_APPLICATION_CREDENTIALS;
  }

  const saPath = path.join(repoRoot, 'env', 'firebase-admin-sa.json');
  if (existsSync(saPath)) {
    return saPath;
  }

  const config = readFirebaseToolsConfig();
  const email = config?.user?.email;
  if (!email || !process.env.APPDATA) {
    return null;
  }

  const adcPath = path.join(
    process.env.APPDATA,
    'firebase',
    `${emailToAdcSlug(email)}_application_default_credentials.json`,
  );
  return existsSync(adcPath) ? adcPath : null;
}

function refreshTokenFromConfig() {
  const config = readFirebaseToolsConfig();
  return config?.tokens?.refresh_token ?? null;
}

async function createDb() {
  const credPath = resolveCredentialsPath();
  if (credPath) {
    const raw = JSON.parse(readFileSync(credPath, 'utf8'));
    if (raw.type === 'service_account') {
      initializeApp({ credential: cert(raw), projectId });
    } else {
      process.env.GOOGLE_APPLICATION_CREDENTIALS = credPath;
      initializeApp({ credential: applicationDefault(), projectId });
    }
    return getFirestore();
  }

  const refreshToken = refreshTokenFromConfig();
  if (!refreshToken || !FIREBASE_CLIENT_ID || !FIREBASE_CLIENT_SECRET) {
    throw new Error(
      'Sin credenciales. Guarda una service account en env/firebase-admin-sa.json, define GOOGLE_APPLICATION_CREDENTIALS, o exporta FIREBASE_TOOLS_CLIENT_ID/FIREBASE_TOOLS_CLIENT_SECRET junto con `firebase login`.',
    );
  }

  const auth = new GoogleAuth({
    credentials: {
      type: 'authorized_user',
      client_id: FIREBASE_CLIENT_ID,
      client_secret: FIREBASE_CLIENT_SECRET,
      refresh_token: refreshToken,
    },
    scopes: ['https://www.googleapis.com/auth/cloud-platform'],
  });

  return new Firestore({
    projectId,
    authClient: await auth.getClient(),
  });
}

const IDS = {
  estudiante: 'demo-estudiante-001',
  operador: 'demo-operador-001',
  administrador: 'demo-admin-001',
  ruta: 'demo-ruta-utez-centro',
  paradaUtez: 'demo-parada-utez',
  paradaCentro: 'demo-parada-centro',
  salida: 'demo-salida-manana',
  reserva: 'demo-salida-manana_demo-estudiante-001',
  pago: 'demo-pago-001',
  reporte: 'demo-reporte-001',
  dispositivo: 'demo-dispositivo-android',
  qr: 'demo-qr-token',
};

async function seed() {
  const db = await createDb();
  const now = Timestamp.now();
  const tomorrow = Timestamp.fromDate(
    new Date(Date.now() + 24 * 60 * 60 * 1000),
  );

  await db.collection('usuarios').doc(IDS.estudiante).set({
    email: 'estudiante.demo@utez.edu.mx',
    nombreCompleto: 'Ana Demo Estudiante',
    rol: 'estudiante',
    estadoVerificacion: 'aprobada',
    creadoEn: now,
    actualizadoEn: now,
  });

  await db.collection('usuarios').doc(IDS.operador).set({
    email: 'operador.demo@utez.edu.mx',
    nombreCompleto: 'Luis Demo Operador',
    rol: 'operador',
    estadoVerificacion: 'aprobada',
    creadoEn: now,
    actualizadoEn: now,
  });

  await db.collection('usuarios').doc(IDS.administrador).set({
    email: 'admin.demo@utez.edu.mx',
    nombreCompleto: 'Admin Demo',
    rol: 'administrador',
    estadoVerificacion: 'aprobada',
    creadoEn: now,
    actualizadoEn: now,
  });

  await db
    .collection('usuarios')
    .doc(IDS.estudiante)
    .collection('dispositivos')
    .doc(IDS.dispositivo)
    .set({
      fcmToken: 'demo-fcm-token-no-usar-en-produccion',
      plataforma: 'android',
      actualizadoEn: now,
    });

  await db.collection('rutas').doc(IDS.ruta).set({
    nombre: 'UTEZ — Centro Cuautla',
    descripcion: 'Ruta de ejemplo para revisar el modelo en consola',
    activa: true,
    polyline: '_p~iF~ps|U_ulLnnqC_mqNvxq`@',
    creadoEn: now,
    actualizadoEn: now,
  });

  await db.collection('paradas').doc(IDS.paradaUtez).set({
    rutaId: IDS.ruta,
    nombre: 'Entrada UTEZ',
    orden: 1,
    ubicacion: new GeoPoint(18.8523, -99.2001),
    activa: true,
  });

  await db.collection('paradas').doc(IDS.paradaCentro).set({
    rutaId: IDS.ruta,
    nombre: 'Centro Cuautla',
    orden: 2,
    ubicacion: new GeoPoint(18.8778, -99.2194),
    activa: true,
  });

  await db.collection('salidas').doc(IDS.salida).set({
    rutaId: IDS.ruta,
    operadorId: IDS.operador,
    fechaHoraSalida: tomorrow,
    estado: 'programada',
    asientosTotales: 40,
    asientosDisponibles: 39,
    actualizadoEn: now,
  });

  await db
    .collection('salidas')
    .doc(IDS.salida)
    .collection('privado')
    .doc('qr')
    .set({
      tokenHash: 'demo-hash-solo-visualizacion',
      rotacionEn: now,
      actualizadoEn: now,
    });

  await db.collection('reservas').doc(IDS.reserva).set({
    salidaId: IDS.salida,
    estudianteId: IDS.estudiante,
    paradaId: IDS.paradaUtez,
    estado: 'reservada',
    creadaEn: now,
    actualizadoEn: now,
  });

  await db.collection('pagos').doc(IDS.pago).set({
    reservaId: IDS.reserva,
    salidaId: IDS.salida,
    estudianteId: IDS.estudiante,
    monto: 15,
    moneda: 'MXN',
    estado: 'pendiente',
    proveedor: 'mercadoPago',
    externalId: 'demo-mp-preference-id',
    creadoEn: now,
  });

  await db.collection('reportes').doc(IDS.reporte).set({
    reportadoPor: IDS.estudiante,
    salidaId: IDS.salida,
    tipo: 'retraso',
    descripcion: 'Ejemplo de incidencia abierta para pruebas de UI',
    estado: 'abierto',
    creadoEn: now,
  });

  console.log('Seed completado en', projectId);
  console.log(JSON.stringify(IDS, null, 2));
}

seed().catch((err) => {
  console.error(err.message ?? err);
  process.exit(1);
});
