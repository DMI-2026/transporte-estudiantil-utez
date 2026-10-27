# Diseño de Componentes (UI) — transporte-estudiantil-utez

Guía de organización de widgets UI de la app Flutter. Complementa [arquitectura.md](../arquitectura.md) con reglas concretas sobre **dónde colocar** cada pieza de interfaz dentro de una feature.

---

## 1. Resumen

La app combina dos ideas:

1. **Arquitectura por capas (feature-first)** — `presentation/` → `domain/` → `data/`.
2. **Niveles de composición UI** — átomo → molécula → organismo → template → page.

Cada feature vive en `lib/src/features/<nombre>/` con las capas `domain/`, `data/` y `presentation/`. Los widgets van en `presentation/`.

| Nivel | Ubicación | Responsabilidad |
|-------|-----------|-----------------|
| Átomos | `presentation/widgets/atoms/` | Elementos mínimos de UI, sin lógica de negocio |
| Moléculas | `presentation/widgets/molecules/` | Combinaciones simples de átomos con función concreta |
| Organismos | `presentation/widgets/organisms/` | Secciones completas de interfaz (formularios, listas) |
| Templates | `presentation/widgets/templates/` | Estructuras con slots, sin datos ni rutas |
| Pages | `presentation/<feature>_page.dart` | Pantallas finales conectadas al router |

---

## 2. Los cinco niveles

### 2.1 Átomos

Elementos mínimos de UI. Sin lógica de negocio ni llamadas a repositorio.

**Ubicación:** `lib/src/features/<nombre>/presentation/widgets/atoms/`

| Ejemplo | Descripción |
|---------|-------------|
| `AppTextField` | Campo de texto con label y error |
| `AppButton` | Botón primario con tema UTEZ |
| `AppBadge` | Badge de estado |
| `AppIcon` | Icono de la app |

**Reglas:**
- No importan moléculas, organismos ni pages.
- Props genéricas (label, onPressed, enabled…).
- Usan colores del tema (`AppColors`, `AppSpacing`, `AppRadii`) de `lib/src/core/theme/`.

### 2.2 Moléculas

Combinaciones simples de átomos con una función UI concreta.

**Ubicación:** `lib/src/features/<nombre>/presentation/widgets/molecules/`

| Ejemplo | Descripción |
|---------|-------------|
| `AuthFormField` | Campo con label, icono y mensaje de error |
| `EstadoVacíoPanel` | Estado vacío con icono y botón Reintentar |
| `ItemReserva` | Fila de reserva con datos y estado |

**Reglas:**
- Pueden importar átomos de la misma feature o de `core/`.
- No importan organismos ni pages.

### 2.3 Organismos

Secciones completas de interfaz: formularios, tablas, listas con contexto.

**Ubicación:** `lib/src/features/<nombre>/presentation/widgets/organisms/`

| Ejemplo | Descripción |
|---------|-------------|
| `LoginForm` | Formulario completo de inicio de sesión |
| `ListaRutas` | Lista de rutas con paradas y horarios |
| `PanelAbordaje` | Panel con QR y botón de validar |

**Reglas:**
- Pueden importar átomos y moléculas.
- La lógica de negocio pesada va en el Cubit, no en el organismo.
- No importan pages.

### 2.4 Templates

Estructuras de pantalla con slots (`children` o props). No conocen APIs ni rutas.

**Ubicación:** `lib/src/features/<nombre>/presentation/widgets/templates/`

| Ejemplo | Descripción |
|---------|-------------|
| `AuthLayout` | Pantalla de autenticación sin sidebar |
| `AppScaffold` | Estructura base con barra superior y cuerpo |

**Reglas:**
- Solo layout, sin fetch de datos.
- Reciben contenido vía `children` o props `Widget`.

### 2.5 Pages

Pantallas finales conectadas al router. Orquestan el Cubit, estado local y ensamblan templates/organismos.

**Ubicación:** `lib/src/features/<nombre>/presentation/<feature>_page.dart`

**Reglas:**
- Importan desde `../widgets/` y `../<feature>_cubit.dart`.
- Usan `UiState` + `UiStateView` + `MensajeEstado` para pantallas que cargan datos.
- Export nombrado o widget registrado en `app_routes.dart`.

---

## 3. Árbol de carpetas por feature

```text
lib/src/features/<nombre>/
├── domain/
│   ├── <nombre>_repository.dart     # Contrato del repositorio
│   └── <entidad>.dart               # Entidades de dominio
├── data/
│   ├── <nombre>_repository_impl.dart# Implementación del repositorio
│   └── <nombre>_remote_datasource.dart # Datasource (Firestore, etc.)
├── presentation/
│   ├── <nombre>_cubit.dart          # Cubit de estado (Equatable)
│   ├── <nombre>_state.dart          # Estado del Cubit
│   ├── <nombre>_page.dart           # Page conectada al router
│   └── widgets/
│       ├── atoms/
│       ├── molecules/
│       ├── organisms/
│       └── templates/
test/
└── features/<nombre>/
    └── <nombre>_cubit_test.dart     # Pruebas del Cubit
```

---

## 4. Árbol de decisión: ¿dónde va cada widget?

```
¿Es un elemento mínimo de UI (botón, texto, icono)?
├── Sí → presentation/widgets/atoms/
└── No → ¿Es una combinación simple de átomos con función concreta?
    ├── Sí → presentation/widgets/molecules/
    └── No → ¿Es una sección completa (formulario, lista, panel)?
        ├── Sí → presentation/widgets/organisms/
        └── No → ¿Es una estructura con slots sin datos?
            ├── Sí → presentation/widgets/templates/
            └── No → ¿Es pantalla conectada al router?
                └── Sí → presentation/<nombre>_page.dart
```

---

## 5. Reglas de capas (Flutter)

| Capa | Permite | Prohíbe |
|------|---------|---------|
| presentation | Widgets, Cubits, llamadas al repositorio del dominio | `cloud_firestore`, `firebase_auth`, `http` directo; `get_it` desde widgets para la sesión (usar `context.read<AuthSessionCubit>()`) |
| domain | Entidades, contratos de repositorio, validadores | Widgets de Flutter, SDK de Firebase |
| data | Datasources, mappers, implementación del repositorio | `BuildContext` |

Registrar dependencias nuevas en `lib/src/core/di/injection.dart`.

---

## 6. Estado de UI

- Toda la lógica de pantalla va en un Cubit (`flutter_bloc`) con estado `Equatable`.
- No introducir `ChangeNotifier` ni otro gestor de estado.
- Pantallas que cargan datos remotos usan `UiState` + `UiStateView` y muestran errores o vacíos con `MensajeEstado`.
- La sesión global está en `AuthSessionCubit`; el router la observa mediante `StreamListenable`.

---

## 7. Responsividad

- Usar `Theme` y `MediaQuery`; paddings y márgenes con `AppSpacing` de `lib/src/core/theme/`.
- Listas largas con `ListView` o `CustomScrollView`; nunca un `Column` sin scroll en pantallas pequeñas.
- Probar al menos en un ancho de unos 360 píxeles lógicos.

---

## 8. Anti-patrones (prohibidos)

| Anti-patrón | Alternativa |
|-------------|-------------|
| Widgets de 100+ líneas inline en la page | Extraer a molécula u organismo |
| Lógica de Firestore en un widget | Mover a `data/` o `domain/` |
| `ChangeNotifier` en una feature | Usar Cubit (`flutter_bloc`) |
| Colores hexadecimales sueltos | Usar `AppColors` de `core/theme/` |
| Carpeta `components/` por feature | Usar `presentation/widgets/` |
| Stubs vacíos sin propósito documentado | No crear hasta implementar |

---

## 9. Checklist al crear UI nueva

- [ ] Identificar nivel de composición (átomo / molécula / organismo / template / page).
- [ ] Colocar en la carpeta correcta según §4.
- [ ] Pages solo ensamblan; estado de negocio en el Cubit.
- [ ] Colores y espaciado desde `lib/src/core/theme/`.
- [ ] Pantallas con datos remotos usan `UiState` + `MensajeEstado`.
- [ ] No crear carpetas `components/` ni `views/` por feature.
- [ ] Escribir pruebas en `test/features/<nombre>/`.
- [ ] Documentar la pantalla en `docs/pantallas/`.
- [ ] Ejecutar `.\scripts\check.ps1`.

---

## 10. Documentación relacionada

- [../arquitectura.md](../arquitectura.md) — Capas, árbol de `lib/`, router, Firestore.
- [../reglas-desarrollo.md](../reglas-desarrollo.md) — Capas Flutter, nombres de Firestore, seguridad.
- [../pantallas/](../pantallas/README.md) — Documentación por pantalla.
- [../flujos/](../flujos/README.md) — Flujos de navegación entre pantallas.
