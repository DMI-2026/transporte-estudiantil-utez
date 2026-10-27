# Módulo: operador (app Flutter)

Feature: `lib/src/features/operator/` (stub).

## Responsabilidades

- Ver las salidas asignadas; iniciar y finalizar una salida.
- Transmitir ubicación en primer plano durante el recorrido.
- Mostrar el QR de abordaje para que el estudiante lo escanee.
- Ver la lista de abordaje en tiempo real.

## Relacionado

- Validación del QR: [funcionalidades/qr.md](funcionalidades/qr.md)
- Estados de salida: [README, sección Estados de dominio](README.md#estados-de-dominio)
- Historias del operador: [referencia-dmi.md](../referencia-dmi.md)

## Archivos a crear al implementar el issue

`domain/` con repositorios de salida y abordaje; `data/` con Firestore y la función callable del QR; `presentation/` con las pantallas de ruta y lista, cada una con su Cubit.
