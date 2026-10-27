# Contribuidores y control de cambios · Transporte estudiantil UTEZ

Integrantes de la organización de GitHub **DMI-2026** (curso Desarrollo Móvil Integral) y reglas de Git. Las convenciones citadas como C-01, C-02, etc. están explicadas en [docs/convenciones.md](docs/convenciones.md).

**Docente / Coordinador:** [@carsimax](https://github.com/carsimax) · Maximiliano Carsi

## Equipo 1 (`team-1`) — este repositorio

| # | Usuario GitHub | Nombre | Enfoque inicial |
|:---:|---|---|---|
| 1 | [@DavidReds7](https://github.com/DavidReds7) | David Rojas | `home`, `trip` |
| 2 | [@Nadia05Sa](https://github.com/Nadia05Sa) | Nadia Yuridia Salinas Cervantes | Coordinación, `reservations` |
| 3 | [@JesusDre](https://github.com/JesusDre) | Jesus Juarez | `functions/`, `admin-web` |
| 4 | [@LARISSA1825alita](https://github.com/LARISSA1825alita) | Alison Larissa Martinez | Firebase rules, Functions |
| 5 | [@HannaCast](https://github.com/HannaCast) | Hanna Romybsi Pérez Caspeta | `auth`, `profile` |
| 6 | [@20233tn193](https://github.com/20233tn193) | Juan Manuel Chavez Arredondo | `routes_map` |

Equipos 2–5: mismo padrón que [DMI-2026](https://github.com/orgs/DMI-2026/teams).

## Control de cambios

### Ramas (convención C-01)

- Nunca push directo a `main` ni a `develop`.
- `feat/<n>-<tema>`, `fix/<n>-<tema>`, `docs/<tema>`, `chore/<tema>` desde `develop`.

### Commits (convención C-02)

Conventional Commits en español, tiempo presente: `feat:`, `fix:`, `docs:`, `test:`, `chore:`.

### Sensor de verificación (convención C-04)

Antes de cada commit:

```powershell
.\scripts\check.ps1
```

Activar el hook una sola vez: `git config core.hooksPath .githooks`. Está prohibido `--no-verify`.

`.\scripts\verify-activity.ps1` es un extra para el cierre de issue (secretos, Firebase); no sustituye a `check.ps1`.

### PR (convención C-03)

1. PR hacia `develop` con `Closes #<n>`.
2. Revisión y aprobación de **otra persona** del equipo.
3. El autor no autoaprueba.
