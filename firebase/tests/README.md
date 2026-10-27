# Pruebas de reglas Firestore y Storage

Corren contra los emuladores locales (puertos en `firebase.json`: Firestore 8781, Storage 9781). No tocan el proyecto `utebus-4435b`.

Requisitos: Node, Java 21 y Firebase CLI (`firebase --version`). Las pruebas corren en serie (`--test-concurrency=1`) porque Firestore y Storage comparten el emulador.

```powershell
cd firebase\tests
npm install
npm run test:emulator
```

Integración del arranque (sin celular): `flutter test integration_test -d flutter-tester`.

Desde la raíz del repo (mismo comando que usa `verify-activity.ps1 -Tipo rules`):

```powershell
.\scripts\verify-activity.ps1 -Tipo rules
```
