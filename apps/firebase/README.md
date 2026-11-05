# Backend · Firebase (proyecto `utebus-4435b`)

## Tecnología

- **Firebase Authentication** con correo y contraseña.
- **Cloud Firestore** para los datos (7 colecciones; ver [05-datos.md](../../docs/05-datos.md)) y **Cloud Storage** para la credencial del estudiante y las fotos de reportes.
- **Cloud Functions** en TypeScript (Node 20) para lo que el cliente no debe hacer: pagos con Mercado Pago, validación del QR y avisos push. Detalle en [functions/README.md](functions/README.md).

## Por qué la elegimos (D-03)

Decisión D-03 de [01-alcance.md](../../docs/01-alcance.md): un solo backend en la nube, sin API REST propia. Las reglas de Firestore y Storage aíslan los datos de cada rol (estudiante, operador y administrador), y las Cloud Functions son el único lugar con privilegios de administrador para aprobar pagos y validar el QR (D-05 y D-06). Descartamos una API con Node y Express porque habría que mantener servidor, autenticación y base de datos por separado.

## Qué hay en esta carpeta

| Ruta | Qué es |
|------|--------|
| `firebase.json`, `.firebaserc` | Configuración del proyecto y de los emuladores (Firestore 8781, Storage 9781) |
| `firestore.rules`, `firestore.indexes.json`, `storage.rules` | Reglas e índices que se despliegan |
| `tests/` | Pruebas de las reglas contra el emulador local |
| `tools/` | Script para cargar datos de demostración |
| `functions/` | Cloud Functions en TypeScript |

## Cómo se arranca

Requisitos: Node 20, Java 21 y Firebase CLI (`npm install -g firebase-tools`).

Emuladores locales de Firestore y Storage (no tocan el proyecto real):

```bash
cd apps/firebase
firebase emulators:start --only firestore,storage
```

Pruebas de las reglas (levantan y apagan el emulador solas):

```bash
cd apps/firebase/tests
npm install
npm run test:emulator
```

Compilar las Cloud Functions:

```bash
cd apps/firebase/functions
npm install
npm run build
```

Desplegar reglas e índices (solo después de que pasen las pruebas):

```bash
cd apps/firebase
firebase deploy --only firestore:rules,firestore:indexes,storage
```

Los secretos (llaves de Mercado Pago, service account) nunca se guardan en esta carpeta; van en el entorno de Cloud Functions. La service account para el seed local va en `env/firebase-admin-sa.json`, que está ignorada por Git.
