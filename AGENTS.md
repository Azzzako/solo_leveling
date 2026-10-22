# Solo Leveling

Personal Flutter app, built and installed by the owner on their own phone.
Supabase is used **only for identity** (email + password via GoTrue); no game
data ever leaves the device: each account gets its own SQLite file
(`solo_leveling_<userId>.sqlite`) and its own `SharedPreferences` keys
(`sl_<userId>::…`). With a cached session the app works fully offline. Setup in
`docs/supabase.md`; config via `supabase_config.local.dart` or
`--dart-define=SUPABASE_URL=… --dart-define=SUPABASE_ANON_KEY=…`.

## Accounts

- `authProvider` is the gate: no session → `/login`; every DB/settings provider
  depends on it, so switching account swaps the whole data set.
- Legacy data (pre-accounts `hunter_*` prefs and `solo_leveling.sqlite`) is
  claimed by the **first** account that signs in, once (`sl_legacy_claimed`);
  the old SQLite file is copied, never deleted.
- `AuthRepository.restore()` returns the cached session when there is no network
  or the token is rejected (`AuthResult.offline`); only `signOut` clears it.
- Auth tests use `MockClient` from `package:http/testing.dart` (no real network).

## Product

- **Misiones diarias**: a **fixed** set of 7 missions per user, no randomness.
  The stack is data (`stack_templates` / `stack_subtasks`), built by the first-run
  interview: one goal question (physical · productivity · focus · relationships)
  plus 7 questions of that goal (`features/missions/domain/interview_catalog.dart`).
  Every option contributes one mission; one question per goal is an adjustment
  (`InterviewOption.scalePrevious`) that tunes the previous mission. `buildStack`
  always returns 7 unique missions worth exactly `dailyStackXp`. Same day = same
  stack; if the day's rows do not match the templates they are rebuilt.
- **Subtasks**: exercise has 4 (pushups, abs, squats, pullups) and "comer sano"
  has 3 (breakfast, lunch, dinner); a parent mission (target = subtask count)
  only completes when all of them are done. Exercise reps scale with level:
  `base + perLevel × (level - 1)`, frozen at 30.
- **XP / nivel / rango**: XP per mission is **flat** (no `baseXp × target`),
  420 XP/day for the whole stack, whatever the goal. Levels follow
  `xpToNext(n) = 325 + (n - 1) * 122`; ranks `E → D → C → B → A → S → SS → SSS`
  by level (`<4, <8, <14, <22, <32, <45, <60, else`). Changing the curve means
  bumping `SettingsStore.xpCurveVersion` and extending `rescaleXp`.
- **Castigo por no cumplir**: `dailySettlementProvider` charges, for every
  unsettled past day, the XP of the missions left undone (`penaltyForDay`) via
  `PlayerController.revokeXp`. XP can go **negative** (level 1, `inDebt` true,
  debt shown in red). Marker: `hunter_penalty_settled_date`; gap capped at 90
  days. Touching the streak on settlement is off (`resetStreak: false`): a day
  with no completion already breaks it.
- **Racha (streak)**: consecutive days with at least one completed mission.
  Several missions the same day do not raise it.
- **Deshacer**: `MissionRepository.resetSubtask` (one series, recomputes the
  parent, undoes the mission and refunds its XP if that was the last one) and
  `MissionRepository.resetMission` (one quest with all its subtasks). The ↺
  button and a tap on a completed card both trigger it.
- **Reiniciar el día**: `MissionRepository.resetDay` clears today's completions,
  zeroes today's missions and subtasks and refunds that day's XP through
  `PlayerController.revokeXp`. Streak only drops to 0 if it started today.
- **Metas**: long-term goals with a deadline and their own XP reward.

## Stack

Flutter 3.47 / Dart 3.13 · Riverpod 3 · go_router (`StatefulShellRoute`) ·
Drift (SQLite) · SharedPreferences (player settings) · flutter_animate ·
bundled fonts (Orbitron display, Rajdhani body).

## Layout

```
lib/
  main.dart
  src/
    app/            app.dart, router.dart, shell/, theme/ (colors, typography, theme)
    core/           db/ (AppDatabase + connection/ platform split), storage/,
                    widgets/ (shared HUD widgets), providers/, utils/
    features/<f>/
      domain/       pure logic: enums, value objects, rules
      data/         drift tables + repositories
      presentation/ screens/, widgets/, providers/
test/<feature>/     unit tests mirroring lib features
docs/design-system.md
```

Rules:
- Drift row classes (`Goal`, `Mission`, `MissionCompletion`, `MissionSubtask`)
  are generated in
  `core/db/app_database.g.dart`. Import `core/db/app_database.dart` to use them,
  never the `*_table.dart` files.
- Anything platform-specific lives in `core/db/connection/` behind the
  conditional export. `dart:io` is only allowed there (plus native-only builds).
- No feature imports another feature's `presentation/`. Cross-feature reads go
  through that feature's providers or repositories.
- No new state-management library and no `dart:io` outside
  `core/db/connection/`. Network access is allowed **only** from
  `features/auth/` (Supabase Auth). No telemetry, no analytics, no sync.

## Conventions

- Style: `flutter analyze` must stay clean. `analysis_options.yaml` already
  enforces trailing commas, sorted directives and final locals.
- Money/XP math, streaks, the fixed daily stack and its level scaling always get
  a unit test in `test/<feature>/`. Repository tests use
  `AppDatabase.forTesting(NativeDatabase.memory())`.
- No comments in code unless asked. No new colors outside `AppColors`, no new
  text styles outside `AppTypography`.
- Widgets read state via providers; they never import a database directly.

## Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # after drift table changes
flutter analyze
flutter test
flutter run                                        # connected device
flutter build apk --debug                          # build/app/outputs/flutter-apk/app-debug.apk
flutter install                                    # install on the connected phone
flutter build web                                  # web/sqlite3.wasm + drift_worker.dart.js required, commit both
dart compile js -O4 -o web/drift_worker.dart.js web/drift_worker.dart   # only if drift/sqlite3 change
```

## Data safety

The app owns the user's progress; it lives in the device SQLite database. Any
schema change must bump `schemaVersion` and provide a migration that preserves
existing rows. Never drop or recreate tables casually.

## Agents (project scoped, `.opencode/`)

- `architect` — plans features, decides placement and migrations.
- `implementer` — implements a feature end to end (data, providers, UI, tests).
- `designer` — UI, theme, motion, system-window aesthetic.
- `reviewer` — reviews diffs for bugs, data-loss risks and convention drift.

They use Anthropic Claude models. If a model id is unavailable in your
opencode setup, run `opencode auth login` and check `opencode models` for the
right `anthropic/...` id.

MCPs configured in `.opencode/opencode.json`: `context7` (up-to-date Flutter /
Riverpod / Drift docs) and `playwright` (inspect the `flutter run -d web-server`
build in a real browser). Restart opencode after changing them.