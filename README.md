# Solo Leveling

App Flutter personal para uno mismo (el dueño), instalada en su propio teléfono.
**Login con Supabase (solo identidad)**: el único uso de la red es
autenticarse. Los datos de cada cuenta (misiones, XP, racha, metas) viven en un
SQLite propio dentro del dispositivo; el estado del "cazador" en
`SharedPreferences` con claves por usuario. Sin telemetría y sin subir nada a la
nube.

Con la sesión guardada la app funciona **sin conexión**: solo hace falta red la
primera vez o al cambiar de cuenta. Ver [`docs/supabase.md`](docs/supabase.md).

Estética: *system window* de Solo Leveling — fondo casi negro, paneles azules
holográficos con brillo, oro para recompensas, HUD tipográfico. Ver
[`docs/design-system.md`](docs/design-system.md) para los tokens.

---

## 1. Reglas del producto (invariantes de negocio)

| Regla | Dónde vive |
| --- | --- |
| **Stack fijo de 7 misiones por usuario**, sin excepción ni aleatoriedad: sale de su entrevista | `domain/interview_catalog.dart` + tabla `stack_templates` |
| La **entrevista** pregunta la meta (físico · productividad · enfoque · relaciones) y 7 preguntas propias de esa meta; la última construye el stack | `interview_screen.dart`, `buildStack()` |
| Una pregunta por meta es de **ajuste** (intensidad, duración) y modifica la misión anterior en vez de añadir una | `InterviewOption.scalePrevious` |
| Todas las combinaciones dan **exactamente 420 XP/día** y 7 títulos distintos | `normalizeXp`, `_disambiguate` |
| El set del día no se duplica; si las misiones del día no son el stack fijo se regeneran | `MissionRepository.generateDailyMissions` / `matchesFixedStack` |
| XP por misión **plano** (no multiplica por `target`) y repartido a **420 XP/día** sea cual sea la meta | `interview_catalog.dart:dailyStackXp` |
| **Castigo por no cumplir**: al abrir la app en un día nuevo se cobra, por cada día transcurrido sin liquidar, el XP de las misiones que quedaron sin completar. El XP puede quedar **negativo** (nivel 1 en deuda) | `MissionRepository.penaltyForDay` + `dailySettlementProvider` |
| Ejercicio tiene **4 subtareas** (flexiones, abdominales, sentadillas, dominadas); la primaria (target 4) solo se completa al acabar las 4 | `MissionRepository.registerSubtaskProgress` |
| Las repeticiones **escalan con el nivel**: `base + perLevel × (nivel - 1)`, congelado en `maxLevel` 30 | `SubtaskSpec.targetAt` |
| Curva de nivel: `xpToNext(n) = 325 + (n - 1) * 122` | `player_stats.dart` |
| Rangos por nivel: `E <4 · D <8 · C <14 · B <22 · A <32 · S <45 · SS <60 · SSS` | `HunterRank.fromLevel` |
| Racha = días consecutivos con ≥1 misión completada; varias el mismo día no la suben | `PlayerStats.streakAfterCompletion` |
| Una misión paga XP **una sola vez** (guarda en `mission_completions`) | `MissionRepository._settleProgress` |
| **Deshacer una subtarea** pone esa serie a 0, recalcula el contador de la primaria y, si ya estaba completa, deshace la misión y devuelve su XP | `MissionRepository.resetSubtask` |
| **Deshacer una misión** la pone a 0 (con todas sus subtareas) y devuelve su XP; botón ↺ y toque en la tarjeta completada | `MissionRepository.resetMission` |
| **Reiniciar el día** borra los completions de hoy, pone a 0 el progreso de las misiones y subtareas del día, y **devuelve el XP** | `MissionRepository.resetDay` + `PlayerController.revokeXp` |
| Metas: objetivo largo con deadline y recompensa XP propia (aún sin UI de cobro) | `goal_repository.dart` |

### Ritmo de progresión (con 270 XP/día)

| Hito | Nivel | XP total | Días aprox. |
| --- | --- | --- | --- |
| Primer nivel | 2 | 325 | 1 |
| Rango D | 8 | 4 883 | ~12 |
| Rango C | 14 | 13 741 | ~33 |
| Rango B | 22 | 32 445 | ~77 |
| Rango A | 32 | 66 805 | ~159 |
| Rango S | 45 | 129 712 | ~309 |

Con el castigo, saltarse un día completo cuesta **-420 XP**: dos semanas de
descanso equivalen a perder el nivel que habrías alcanzado en ese tiempo.

Migración `xpCurveVersion = 3`: al abrir la app, el XP guardado se reescala
(`SettingsStore.rescaleXp(from: versiónAnterior)`) manteniendo el nivel y
convirtiendo el progreso interno. v1→v2 además bajaba el nivel al 35 %.
Marcador: `hunter_xp_curve_version`.

Liquidación del castigo: marcador `hunter_penalty_settled_date`. La primera vez
solo se liquida el día anterior (no hay línea base); a partir de ahí se cobra
cada día pendiente, con un tope de 90 días de brecha.

Si tocas estas funciones, el test correspondiente en `test/` es el contrato.

---

## 1.1 Cuentas y datos por usuario

| Pieza | Dónde | Qué hace |
| --- | --- | --- |
| `SupabaseConfig` | `core/config/supabase_config.dart` | URL + anon key (fichero local o `--dart-define`) |
| `AuthRepository` | `features/auth/data/auth_repository.dart` | GoTrue: `signIn`, `signUp`, `signOut`, `restore` |
| `AuthController` | `features/auth/presentation/providers/auth_provider.dart` | `AsyncNotifier<AuthUser?>` + `offline` |
| `LoginScreen` | `features/auth/presentation/screens/login_screen.dart` | Acceso/registro, mensaje de config ausente |
| Puerta del router | `app/router.dart` | sin sesión todo va a `/login` |
| Base por usuario | `core/db/connection/native_connection.dart` | `solo_leveling_<userId>.sqlite` |
| Ajustes por usuario | `core/storage/settings_store.dart` | claves `sl_<userId>::…` |

- `appDatabaseProvider` y `settingsStoreProvider` dependen de `authProvider`: al
  cambiar de cuenta se reconstruyen y apuntan al otro archivo/otro espacio de
  claves.
- El progreso anterior a las cuentas (claves `hunter_*` y `solo_leveling.sqlite`)
  lo **reclama el primer usuario que entra**; el archivo original se copia, no se
  borra. El marcador es `sl_legacy_claimed`.
- `restore()` devuelve la sesión cacheada si no hay red o el token se rechaza
  (`AuthResult.offline`); en la cabecera aparece el icono `cloud_off`. Solo
  `signOut` borra la sesión local.

## 2. Stack

- Flutter 3.x / Dart `^3.13.5`
- **Supabase Auth** vía `gotrue` 2.27 (`package:gotrue/gotrue.dart`), sin
  `supabase_flutter` porque no hay base de datos en la nube ni storage
- **Riverpod 3** — sin Riverpod generator, todo `Provider` / `StreamProvider` /
  `AsyncNotifier` a mano.
- **Drift 2.35** / SQLite (`sqlite3_flutter_libs`). En web usa
  `sqlite3.wasm` + `WasmDatabase` (el `.wasm` está commiteado en `web/`).
- **go_router 18** con `StatefulShellRoute.indexedStack` (3 ramas, bottom nav).
- `SharedPreferences` para el estado del jugador.
- `flutter_animate` 4.5 para entradas.
- Fuentes bundled: Orbitron (display), Rajdhani (body). Declaradas en
  `pubspec.yaml`, referenciadas siempre por `AppTypography`.

---

## 3. Mapa del repo

```
lib/
  main.dart                       ProviderScope → SoloLevelingApp
  src/
    app/
      app.dart                    MaterialApp.router, tema
      router.dart                 GoRouter + ramas del shell
      shell/app_shell.dart        Scaffold + _SystemHeader + NavigationBar + AppRoutes
      theme/                      app_colors.dart · app_typography.dart · app_theme.dart
    core/
      config/                      supabase_config.dart + supabase_config.local.dart
      db/app_database.dart        AppDatabase(userId) · @DriftDatabase(Goals, Missions, MissionCompletions, MissionSubtasks)
                                  schemaVersion 2 · onUpgrade crea mission_subtasks
      db/app_database.g.dart      GENERADO — nunca editar a mano
      db/connection/              connection.dart (export condicional)
                                    native_connection.dart  (dart:io, path_provider)
                                    web_connection.dart    (sqlite3.wasm)
                                    stub_connection.dart   (lanza UnsupportedError)
      storage/settings_store.dart  SharedPreferences con prefijo de usuario: name, totalXp, streak, lastCompletion, seed, liquidación, versión de curva
      providers/core_providers.dart  appDatabaseProvider · settingsStoreProvider · todayProvider
      widgets/system_widgets.dart SystemPanel · SystemLabel · SectionHeader · StatTile · XpBar · EmptyState
      constants/ · utils/         (vacíos, reservados)
    features/
      auth/
        domain/auth_user.dart     id + email del usuario
        data/auth_repository.dart GoTrue + sesión en SharedPreferences
        presentation/providers/   AuthController (login, registro, logout, restore)
        presentation/screens/     login_screen.dart
      missions/
        domain/interview_catalog.dart     4 metas × 7 preguntas + buildStack/normalizeXp
        domain/daily_stack.dart           SubtaskSpec.targetAt (escalado por nivel)
        domain/mission_difficulty.dart   MissionDifficulty (D/C/B/A/S + baseXp + color)
        data/missions_table.dart         Missions, MissionCompletions
        data/mission_subtasks_table.dart MissionSubtasks (FK → Missions, CASCADE)
        data/stack_tables.dart            StackTemplates, StackSubtasks, UserPreferences
        data/mission_repository.dart      stack fijo, subtareas, gating, limpieza
        presentation/providers/missions_provider.dart
        presentation/screens/              missions_screen.dart · interview_screen.dart
        presentation/widgets/mission_card.dart
      player/
        domain/player_stats.dart          PlayerStats + HunterRank + curva de nivel + racha
        data/                             (vacío: el estado vive en SharedPreferences)
        presentation/providers/player_provider.dart  PlayerController AsyncNotifier
        presentation/widgets/player_status_panel.dart
      goals/
        data/goals_table.dart · data/goal_repository.dart
        presentation/providers/goals_provider.dart
        presentation/screens/goals_screen.dart
      dashboard/
        presentation/screens/dashboard_screen.dart   (+ ErrorState local)
test/
  missions/mission_repository_test.dart   AppDatabase.forTesting(NativeDatabase.memory())
  missions/interview_catalog_test.dart     catálogo, combinaciones, XP 420, escalado
  missions/interview_flow_test.dart        persistencia del stack y reconstrucción del día
  player/player_stats_test.dart           curva, rangos, racha, deuda
  player/player_status_panel_test.dart     panel normal y en deuda
  auth/auth_repository_test.dart           GoTrue con MockClient: login, registro, restore, offline
  core/settings_store_test.dart           migración de XP (SharedPreferences mock)
  features/                               (vacío)
docs/design-system.md
AGENTS.md                                 convenciones para agentes (léelo también)
.opencode/                               agentes: architect · implementer · designer · reviewer + MCPs
```

### Capas y dependencias permitidas

```
presentation/  →  domain/  ·  data/  ·  core/
data/          →  domain/  ·  core/db/app_database.dart
domain/        →  nada (lógica pura, testeable sin Flutter salvo colores)
```

- Una feature **nunca** importa `presentation/` de otra feature.
- Los widgets leen estado por providers; jamás abren la base de datos.
- `dart:io` solo dentro de `core/db/connection/native_connection.dart`.
- Sin librerías nuevas de estado, sin red.

---

## 4. Flujo de datos (ejemplo: completar una misión)

```
MissionCard.onComplete
  └─ registerMissionProgressProvider (MissionProgressAction.complete)
       ├─ MissionRepository.registerProgress(id, amount: target)
       │    ├─ UPDATE missions.progress (clamp a target)
       │    ├─ si finished y no había completion previa
       │    │    INSERT mission_completions (id, missionId, completedAt, xpEarned)
       │    └─ devuelve MissionCompletionOutcome(xpEarned, missionCompleted)
       └─ playerProvider.notifier.rewardMission(xpEarned)
            ├─ suma XP, recalcula racha (streakAfterCompletion)
            ├─ escribe PlayerStats en SharedPreferences
            └─ devuelve RewardResult(xpEarned, leveledUp, newLevel)
  └─ SnackBar con "+XP XP" o "¡SUBISTE DE NIVEL!"
```

Las listas se actualizan solas: todo lee de `Stream` de Drift
(`watchDaily`, `watchCompletionsOn`, `watchActive`, `watchAll`).

**Generación diaria**: `ensureDailyMissionsProvider` (FutureProvider) compara
`settingsStore.dailyMissionsSeedDate` con `todayProvider`; si es otro día llama a
`generateDailyMissions` y guarda la seed. Lo disparan `DashboardScreen` y
`MissionsScreen` con `ref.watch`.

---

## 5. Datos

`schemaVersion = 1`. Tablas:

- `goals`: id, title, description, xpReward(500), deadline, isArchived, createdAt, completedAt
- `missions`: id, title, description, goalId→goals(id) `SET NULL`, difficulty(intEnum),
  xpReward, progress, target, isDaily, dueDate, isActive, sortOrder, createdAt
- `mission_completions`: id, missionId, completedAt, xpEarned, levelUp (⚠ `levelUp`
  existe en la tabla pero **nadie lo escribe**)
- `mission_subtasks` (v2): id, missionId→missions(id) `CASCADE`, title, target,
  progress, sortOrder, createdAt
- `stack_templates` (v3): id, goal, slot, title, description, difficulty, xpReward,
  target, stackVersion — el stack fijo del usuario
- `stack_subtasks` (v3): id, templateId→stack_templates(id) `CASCADE`, title,
  base, perLevel, maxLevel, sortOrder — las series que escalan con el nivel
- `user_preferences` (v3): una fila por usuario con `goal`, `answers`,
  `source` (`interview` · `default` · `migrated`) y `stackVersion`

El castigo no añade tablas: los completions ya guardan `completedAt` y `xpEarned`,
que es lo que necesita `penaltyForDay` para saber qué se hizo cada día.

`beforeOpen` ejecuta `PRAGMA foreign_keys = ON`.
Migración 1→2: `m.createTable(missionSubtasks)`. No se toca ninguna fila previa.

Después de tocar cualquier tabla:
`dart run build_runner build --delete-conflicting-outputs`.
Cambio de schema → subir `schemaVersion` + `MigrationStrategy` que preserve filas.
Nunca dropear tablas: los datos son del usuario.

---

## 6. Comandos

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # tras cambiar tablas Drift
flutter analyze                                          # debe quedar limpio
flutter test
flutter run                                              # dispositivo conectado
flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
flutter build apk --debug
flutter install
flutter build web                                        # ver nota de web
```

### Web (solo para inspección con playwright)

Drift en web necesita **dos** ficheros en `web/`, ambos commiteados:

- `sqlite3.wasm` — binario de sqlite3 3.7.1
  (release `sqlite3-3.7.1` de `simolus3/sqlite3.dart`).
- `drift_worker.dart.js` + su fuente `drift_worker.dart` — worker de drift.
  Se recompila con
  `dart compile js -O4 -o web/drift_worker.dart.js web/drift_worker.dart`.
  Los `.deps` y `.js.map` son basura de build, ignorados por `.gitignore`.

`web_connection.dart` usa `WasmDatabase.open(databaseName, sqlite3Uri,
driftWorkerUri)`. El worker requiere **cross-origin isolation**: servir con
`Cross-Origin-Opener-Policy: same-origin` y
`Cross-Origin-Embedder-Policy: credentialless`. Sin esas cabeceras el navegador
no puede abrir la base (`no such vfs` o consultas que nunca resuelven).
`flutter run -d web-server` / `flutter run -d chrome` ya las envían.

Tests de repositorio: `AppDatabase.forTesting(NativeDatabase.memory())` + `tearDown(db.close)`.

---

## 7. Convenciones (resumen; `AGENTS.md` es la fuente)

- Sin comentarios en el código salvo petición explícita.
- Sin colores fuera de `AppColors`, sin estilos fuera de `AppTypography`.
- Toda UI en **español**, frases cortas e imperativas ("Entrena 30 minutos").
- `analysis_options.yaml` exige trailing commas, imports ordenados, `final` en
  locals, tipos de retorno declarados.
- Test unitario obligatorio para: matemática de XP/dinero, rachas, generación
  diaria, y cualquier repositorio nuevo.
- Widgets `ConsumerWidget`/`AsyncValue.when` para estados de carga/error/vacío.

---

## 8. Estado actual y hacia dónde ir

### Deshacer y castigo

- ↺ por subtarea, ↺ por misión (y toque en la tarjeta completada): devuelven el
  XP de lo deshecho.
- `Reiniciar` en la cabecera: borra el día completo y devuelve su XP.
- Al abrir la app en un día nuevo, `dailySettlementProvider` cobra el castigo de
  cada día pendiente. El panel muestra `DEUDA n XP` en rojo mientras el total sea
  negativo (nivel 1, barra a 0).

### La entrevista

- Al crear una cuenta, `userPreferences` no existe → el router manda a
  `/entrevista` hasta que termine.
- 1 pantalla de meta + 7 preguntas de esa meta. Cada opción aporta una misión;
  una pregunta es de ajuste y modifica la anterior (por eso 7 preguntas y no 6:
  con la de ajuste son 6 misiones + la de agua).
- `Guardar y empezar` escribe `stack_templates`/`stack_subtasks` y reconstruye el
  día en curso si no coincide. `Prefiero el stack de ejemplo` deja el de
  físico por defecto (`source: default`) y no vuelve a preguntar.
- Botón de ajustes (icono `tune`) en la cabecera → repite la entrevista con tus
  respuestas preseleccionadas.
- Un usuario que ya tenía misiones **no ve la entrevista**: su stack actual se
  adopta como plantilla (`source: migrated`).

### Interacción de las subtareas

En la tarjeta de *Hacer ejercicio*: tocar la fila completa la subtarea;
el botón `+` suma `subtaskStep` (10 reps) sin completarla. La barra de la
primaria avanza una casilla por subtarea terminada.

Botón ↺ en cada subtarea terminada y en cada tarjeta completada (también se
deshace tocando la tarjeta). SnackBar `Deshecho · -XP XP` con lo devuelto.

`Reiniciar` (cabecera de *Misiones*) deshace el día completo con confirmación:
borra los completions de hoy, pone a 0 misiones y subtareas, y descuenta el XP
de esas misiones. La racha solo baja a 0 si empezó hoy; si ya venía de días
anteriores se conserva (no hay historial para reconstruirlo).

**Lo que ya funciona (MVP)**: panel con status del cazador + 3 stats + próximas
misiones; misiones diarias generadas con seed estable; completar misión con XP,
racha y subida de nivel; metas con alta por diálogo; bottom nav con 3 ramas
persistentes; web compilando con wasm.

### Deuda conocida (candidatas naturales)

| # | Tema | Dónde tocar |
| --- | --- | --- |
| 1 | **Cobro de XP de metas**: `GoalRepository.complete` archiva la meta pero nunca llama a `rewardMission` | `player_provider.dart` + nuevo `GoalCompletionAction` |
| 2 | **Progreso parcial**: hoy un tap completa la misión entera; `target > 1` no se puede incrementar a medias | `MissionCard` + `MissionProgressAction.advance` ya existe |
| 3 | **Renombrar cazador**: `PlayerController.rename` no tiene UI | `player/` → nueva pantalla (la carpeta `presentation/screens/` está vacía) |
| 4 | **Misiones custom / reactivate**: `create`, `delete`, `reactivate` sin exponer en la UI; `activeMissionsProvider` y `allGoalsProvider` sin uso | `missions_screen.dart`, `goals_screen.dart` |
| 5 | **`levelUp` en `mission_completions`** siempre false → o se rellena al insertar la completion, o se elimina | `mission_repository.dart:_settleProgress` |
| 6 | **Historial / estadísticas**: no hay pantalla de XP por día, ni calendário de racha (hay datos en `mission_completions`) | nueva feature `statistics/` o `history/` |
| 7 | **Objetivos de racha, Achievement/ranks unlocks** | nueva feature |
| 8 | `MissionDifficulty.label` duplica `rank`; `intl` declarado y sin usar | limpiar |
| 9 | Tests solo para missions y player; `goals` y `core` sin cubrir | `test/goals/`, `test/core/` |
| 10 | El set diario depende de que la app se abra ese día (sin generación diferida al volver) | `ensureDailyMissionsProvider` ya regenera al abrir, pero conviene decidir semántica de "día perdido" |

### Cómo arrancar un cambio

1. Lee `AGENTS.md` y la sección 1 de este README (invariantes).
2. Nueva feature = carpeta `lib/src/features/<f>/{domain,data,presentation}` +
   `test/<f>/`. Si necesita UI nueva, añade su rama/ruta en
   `app/shell/app_shell.dart:AppRoutes`.
3. Datos nuevos = tabla Drift + repositorio + provider + test.
4. Al final, `flutter analyze` + `flutter test` limpios.
5. Los subagentes de `.opencode/agent/` ya existen: `architect` (plan),
   `implementer` (feature completa), `designer` (UI), `reviewer` (bugs/data loss).

---

## 9. Ordem de un agente nuevo (5 minutos)

1. `AGENTS.md` → reglas no negociables.
2. `lib/src/app/shell/app_shell.dart` → cómo son las 3 pantallas.
3. `lib/src/core/db/app_database.dart` + `missions_table.dart` → qué se guarda.
4. `mission_repository.dart` → el corazón del juego.
5. `player_stats.dart` → niveles, rangos, racha.
6. `docs/design-system.md` → cómo se ve todo antes de escribir un widget.
7. `mission_repository_test.dart` y `player_stats_test.dart` → qué comportamiento está congelado.