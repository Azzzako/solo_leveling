# Design system

Aesthetic: Solo Leveling system window. Near-black void, holographic blue panels
with a soft glow, gold for rewards, red for danger. HUD typography, thin borders,
no rounded-toy surfaces.

## Tokens

Source of truth: `lib/src/app/theme/app_colors.dart` and
`lib/src/app/theme/app_typography.dart`. Never hardcode a color or a font in a
widget.

| Token | Value | Use |
| --- | --- | --- |
| `voidBackground` | `#05070D` | app background, bar tracks |
| `surface` | `#0B101C` | nav bar, inputs |
| `panel` | `#0E1A2B` | cards, sheets, dialogs |
| `panelBorder` | `#1E3A5F` | every border |
| `systemBlue` | `#2E9BFF` | primary actions, labels |
| `systemGlow` | `#00C2FF` | accent glow, XP, highlights |
| `gold` | `#FFC24B` | rewards, streaks, level-ups |
| `danger` | `#FF4D6D` | boss missions, destructive |
| `success` | `#35E08A` | completed, easy missions |
| `textPrimary` / `textSecondary` / `textMuted` | `#EAF2FF` / `#8FA6C4` / `#5A6E88` | text hierarchy |

Difficulties map to colors in `MissionDifficulty.color`:
`trivial` muted, `easy` green, `medium` blue, `hard` purple, `boss` gold.

## Type

- Orbitron: titles, labels, numbers, rank badges (`screenTitle`, `panelTitle`,
  `systemLabel`, `levelNumber`, `metricValue`). Always uppercase, letter-spacing
  1.5-2.5.
- Rajdhani: body, captions, list content (`body`, `bodyStrong`, `caption`).

## Surfaces

Use `SystemPanel` for anything card-like. Options: `glow` for the single most
important panel of a screen (player status), `borderColor` to tint by rank or
difficulty. Borders are 1 px; radius 14. Never use raw `Card`.

Shared widgets in `lib/src/core/widgets/system_widgets.dart`:
`SystemPanel`, `SystemLabel`, `SectionHeader`, `StatTile`, `XpBar`, `EmptyState`.

## Motion

- Entrances: `flutter_animate`, 200-400 ms, fade + small slide (0.05).
- One animation per card, list children fade in.
- No motion on values the user must read instantly (XP bar fills immediately).

## Layout

- Mobile first: 360-430 dp wide.
- Screen padding `EdgeInsets.fromLTRB(16, 8, 16, 96)` (bottom clears the nav
  bar).
- Lists: `ListView` with `SectionHeader` per group; every list needs a loading
  state and an `EmptyState`.
- Touch targets >= 48 dp.

## Feedback

- Any action: SnackBar, `AppTypography.bodyStrong`.
- Level up: gold accent + `bolt` icon.
- Missions: tap the card to complete. Completed cards get a line-through, dimmed
  rank badge and a `verified` icon.

## Content in Spanish

UI strings are Spanish, short, imperative ("Entrena 30 minutos", "Bebe 2 litros
de agua"). Missions are phrased as commands, not descriptions.