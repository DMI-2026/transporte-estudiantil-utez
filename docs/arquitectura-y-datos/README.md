# Arquitectura y datos (Firebase)

Proyecto: **utebus-4435b**.

| Documento | Contenido |
|-----------|-----------|
| [../05-datos.md](../05-datos.md) | Colecciones, campos, ids demo |
| [reglas-seguridad.md](reglas-seguridad.md) | Firestore + Storage, despliegue |
| [cloud-functions.md](cloud-functions.md) | Funciones previstas, triggers, estructura |

## Archivos en repo

```text
apps/firebase/
  .firebaserc              # proyecto utebus-4435b
  firebase.json            # emuladores y despliegue
  firestore.rules          # reglas de Firestore (versionadas)
  firestore.indexes.json   # índices compuestos
  storage.rules            # reglas de Cloud Storage (versionadas)
  tools/
    seed-demo-data.mjs     # seed Firestore + usuarios Auth demo
```

## Lo que no se versiona

| Elemento | Dónde va |
|----------|----------|
| Service account Admin SDK | `apps/firebase/env/firebase-admin-sa.json` |
| Secretos de Functions (Mercado Pago, QR) | Entorno de despliegue, no el repo |

Scripts en `scripts/seed-firestore.ps1` invocan el seed; cada desarrollador aporta credenciales en local.

Capas Flutter y árbol `apps/mobile/lib/`: [04-arquitectura.md](../04-arquitectura.md). Arranque e integración Git: [../contribucion-repositorio.md](../contribucion-repositorio.md).