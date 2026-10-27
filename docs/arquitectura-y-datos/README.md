# Arquitectura y datos (Firebase)

Proyecto: **utebus-4435b**.

| Documento | Contenido |
|-----------|-----------|
| [modelo-firestore.md](modelo-firestore.md) | Colecciones, campos, ids demo |
| [reglas-seguridad.md](reglas-seguridad.md) | Firestore + Storage, despliegue |

## Archivos en repo

```text
firebase/
  firestore.rules
  firestore.indexes.json
  firestore.rules.seed-open   # solo para seed con -AbrirReglas (último recurso)
  storage.rules
  tools/                      # seed-demo-data.mjs
.firebaserc
firebase.json
scripts/seed-firestore-prod.ps1
scripts/seed-firestore.ps1
```

Capas Flutter y árbol `lib/`: [arquitectura.md](../arquitectura.md).
