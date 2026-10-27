# Reglas de seguridad

Fuente versionada:

| Recurso | Archivo |
|---------|---------|
| Firestore | `firebase/firestore.rules` |
| Índices | `firebase/firestore.indexes.json` |
| Storage | `firebase/storage.rules` · bucket `gs://utebus-4435b.firebasestorage.app` |

## Principios

- Privilegio mínimo por rol (`estudiante`, `operador`, `administrador`) leído de `usuarios/{uid}`.
- Cuenta debe estar `estadoVerificacion == aprobada` para leer catálogo y reservar.
- Cliente no cambia `rol`, `estadoVerificacion`, `email` ni `creadoEn` de su propio documento.
- `pagos`: creación en `pendiente`; **`aprobado` solo Admin SDK / Cloud Functions**.
- QR: `salidas/{id}/privado/qr` legible por operador asignado o admin; escritura denegada al cliente (regla `match /privado/{docId}`).
- `reportes`: operador solo lee los de salidas asignadas a él (`salidaId`); admin lee todo.
- Cliente Flutter: un rol o estado desconocido en `usuarios/{uid}` se trata como perfil inválido (no se asume `estudiante`).
- Storage `documentacion/publico/{archivo}`: lectura de cualquier cuenta autenticada; escritura solo admin.
- Storage `documentacion/{uid}/{archivo}`: solo el dueño lee/escribe.
- Storage `credenciales/{uid}/{archivo}`: solo el dueño lee/escribe (subida de credencial de estudiante).
- Storage `reportes/{uid}/{archivo}`: solo el dueño escribe; admin lee todo.
- Storage `privado/{ruta=**}`: denegado al cliente (QR, secretos).
- Storage no consulta Firestore. El panel admin lee y escribe archivos con Admin SDK (ignora estas reglas). Un custom claim de rol queda para cuando existan Cloud Functions.

## Archivos versionados

| Recurso | Archivo |
|---------|---------|
| Firestore | `firebase/firestore.rules` |
| Storage | `firebase/storage.rules` |
| Índices | `firebase/firestore.indexes.json` |

## Despliegue

```powershell
firebase deploy --only firestore --project utebus-4435b
firebase deploy --only storage --project utebus-4435b
```

Proyecto por defecto: `.firebaserc` → `utebus-4435b`.

Desplegar reglas solo tras revisar y probar en el emulador local. Las pruebas de reglas contra emulador (`firebase/tests/`) están pendientes de creación.

Desplegar reglas solo tras revisar y probar en el emulador. No desplegar directamente a producción sin pruebas locales.
