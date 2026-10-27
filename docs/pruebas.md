# Pruebas

## Plan de pruebas

El enunciado pide 10 unitarias, 5 de widget y 1 de integración, más las reglas de Firestore. El plan del proyecto propone 10 unitarias, 5 de widget y 1 de integración (el mínimo es 8, 4 y 1), ejecutables con un solo comando mediante el script `scripts/test.ps1` que corre `flutter test`, `flutter test integration_test` y las pruebas de reglas.

## Dispositivo físico

**Dispositivo físico:** P1 y P2 en sus tres estados (concedido, denegado y denegado permanentemente), con capturas en este documento.

## Pruebas de reglas (S4)

- Un estudiante no puede leer una reserva ajena, bajar el cupo sin reservar ni cambiar su rol.
- Un operador solo actualiza su salida.
- La foto de credencial solo la leen el dueño y el administrador.

## Pendientes

- El script único `scripts/test.ps1` se agrega cuando haya pruebas de reglas y de integración.
