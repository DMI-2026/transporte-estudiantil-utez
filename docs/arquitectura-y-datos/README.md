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
  firestore.rules          # reglas de Firestore (versionadas)
  firestore.indexes.json   # índices compuestos
  storage.rules            # reglas de Cloud Storage (versionadas)
```

> Los archivos `.firebaserc`, `firebase.json`, service accounts y scripts de seed **no se versionan** ni existen en el repositorio. Cada desarrollador los configura localmente.

Capas Flutter y árbol `apps/mobile/lib/`: [04-arquitectura.md](../04-arquitectura.md).
