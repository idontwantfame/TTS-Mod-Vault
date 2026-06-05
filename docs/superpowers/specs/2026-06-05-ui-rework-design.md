# UI Rework Design — TTS Mod Vault

**Date:** 2026-06-05  
**Branch:** `feature/rework-ui`  
**Approach:** Layout-first (Phase 1), then component library (Phase 2)

---

## Goals

- Replace dated hover-expand sidebar with a standard top navigation bar
- Make the right detail panel collapsible (slim tab)
- Make the log panel resizable via drag handle with snap presets
- Introduce three switchable colour themes (Settings)
- Build a shared component library so all screens and dialogs share a consistent visual language
- Add rich tooltips across every interactive element
- Modernise every dialog to match the new design language

---

## Phase 1 — Layout Restructure

### 1.1 Top Navigation Bar

**Replaces:** `Sidebar` widget + `Vault` Stack overlay

The `Vault` root widget becomes a `Column`:

```
Column
├── TopNavBar (fixed height ~40px)
└── Expanded → content area (ModsPage or BackupsPage)
```

**`TopNavBar` layout:**

```
Row
├── App logo / name  (font-weight 700, accent colour)
├── SizedBox(width: 16)
├── PageTab("Mods")    ← ToggleButton-style chip
├── PageTab("Backups") ← ToggleButton-style chip
├── Spacer
├── IconAction(Icons.refresh,       tooltip: "Refresh mod data")
├── IconAction(Icons.delete_sweep,  tooltip: "Cleanup orphaned asset files …")
├── IconAction(Icons.unarchive,     tooltip: "Import backup (.ttsmod)")
├── IconAction(Icons.upload_file,   tooltip: "Import mod from JSON")
├── IconAction(Icons.download,      tooltip: "Download Workshop mod by URL or ID")
├── IconAction(Icons.help_outline,  tooltip: "Help & about")
├── IconAction(Icons.settings,      tooltip: "Open Settings")
└── IconAction(Icons.terminal,      tooltip: "Toggle activity log")  ← replaces sidebar Debug Console button
```

`PageTab` uses `selectedPageProvider` (existing). Active tab: accent background + dark text. Inactive: transparent + muted text.

`IconAction` is a small `IconButton` that wraps `AppTooltip` (Tier 1). Disabled state follows `actionInProgressProvider`.

The `Sidebar` widget and all references to it are removed. `selectedPageProvider`, `loggingProvider`, and other sidebar-driven providers remain unchanged.

### 1.2 Right Detail Panel — Collapsible Slim Tab

**File:** `lib/src/mods/components/selected_mod_view.dart` (and `vault.dart` layout)

A new `detailPanelExpandedProvider` (`StateNotifierProvider<bool>`, default `true`, persisted to Hive) controls visibility.

**Expanded state:** Current 1-flex `SelectedModView` — no change to content.

**Collapsed state:** A `28px`-wide `SlimTab` widget on the right edge:
- Rotated text label `"DETAILS ›"`  
- Background: `surface` colour, left border: `border` colour  
- `Tooltip`: `"Click to show mod details"`

**Expand triggers:**
- Clicking `SlimTab`
- Clicking any mod in the list (auto-expands if collapsed)
- Clicking "re-check" or any action that needs the panel

**Collapse trigger:**
- Clicking the `SlimTab` when expanded (acts as a toggle)
- User clicks the `SlimTab` regardless of selection state — it is always a manual toggle only

Layout when collapsed:

```
Row
├── Expanded(flex: 1) → ModsColumn  ← full width
└── SlimTab (28px)
```

Layout when expanded:

```
Row
├── Expanded(flex: 2) → ModsColumn
└── Expanded(flex: 1) → SelectedModView
```

Transition: `AnimatedContainer` on the right panel width, duration `200ms`, curve `Curves.easeInOut`.

### 1.3 Log Panel — Resizable with Snap Presets

**File:** `lib/src/logging/logging_console.dart`

Replace the fixed `height: 280` with a `logPanelHeightProvider` (`StateNotifierProvider<double>`, default `280.0`, persisted to Hive).

**Constraints:** min `80px`, max `600px`.  
**Snap presets:** S = `120`, M = `280`, L = `450`. Snap zone: ±`30px` of each preset while dragging.

**Drag handle:** A `GestureDetector` strip (`height: 8px`) sits above the log panel header:
- Cursor: `SystemMouseCursors.resizeRow`
- Visual: centred 40px × 3px rounded pill in `accent` colour at 60% opacity
- `onVerticalDragUpdate`: compute new height from drag delta (negative delta = larger panel since dragging up), clamp, snap, update provider
- `onVerticalDragEnd`: persist height to Hive

**Double-click handle:** resets height to `280` (M preset).

The S/M/L preset buttons appear inside the log panel header (right side), replacing the current close button's row. Active preset: accent background. The existing close (X) and clear (delete_sweep) buttons remain.

---

## Phase 2 — Component Library & Dialogs

### 2.1 File Structure

```
lib/src/ui/
├── theme/
│   ├── app_theme.dart          ← AppThemeData class + 3 palette definitions
│   ├── app_theme_provider.dart ← AppThemeNotifier + appThemeProvider
│   └── app_theme_id.dart       ← enum AppThemeId { blueSlate, blackTeal, purpleDark }
├── components/
│   ├── app_button.dart
│   ├── app_card.dart
│   ├── app_dialog.dart
│   ├── app_text_field.dart
│   ├── app_badge.dart
│   └── app_tooltip.dart
├── tooltip_strings.dart        ← all tooltip text as constants
└── ui.dart                     ← barrel export
```

### 2.2 `AppThemeData`

```dart
class AppThemeData {
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color border;
  final Color borderHighlight;
  final Color accent;
  final Color accentMuted;
  final Color accentText;       // text ON accent background
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color statusOk;
  final Color statusWarn;
  final Color statusError;
  final Color statusInfo;

  ThemeData toMaterialTheme(); // generates Flutter ThemeData
}
```

**Palettes:**

| Token | Blue Slate | Black Teal | Purple Dark |
|---|---|---|---|
| background | `#0f1117` | `#0d0d0d` | `#141218` |
| surface | `#111827` | `#111111` | `#100e18` |
| surfaceElevated | `#1a2030` | `#161616` | `#1a1625` |
| border | `#1e2533` | `#1a1a1a` | `#2a2535` |
| borderHighlight | `#2d4a7a` | `#2dd4bf` (40% opacity) | `#4a3575` |
| accent | `#60a5fa` | `#2dd4bf` | `#a78bfa` |
| accentMuted | `#1e3a5f` | `#1a3030` | `#2d1f4a` |
| textPrimary | `#e2e8f0` | `#e5e5e5` | `#e2e0e8` |
| textSecondary | `#94a3b8` | `#888888` | `#9b98a8` |
| textMuted | `#475569` | `#444444` | `#4b4060` |
| statusOk | `#22c55e` | `#22c55e` | `#22c55e` |
| statusWarn | `#f59e0b` | `#f59e0b` | `#f59e0b` |
| statusError | `#ef4444` | `#ef4444` | `#ef4444` |
| statusInfo | `#60a5fa` | `#2dd4bf` | `#a78bfa` |

`AppThemeNotifier` extends `StateNotifier<AppThemeId>`, persists to Hive key `"appThemeId"`. `appThemeProvider` exposes both the ID notifier and a `appThemeDataProvider` derived provider that maps ID → `AppThemeData`.

### 2.3 Components

**`AppButton`**

```dart
enum AppButtonVariant { primary, secondary, ghost, danger }
```

- `primary`: accent background, `accentText` foreground, border-radius 6
- `secondary`: `surfaceElevated` background, `textPrimary` foreground, `border` border
- `ghost`: transparent, `textSecondary` foreground, `border` border on hover
- `danger`: `statusError` background at 20% opacity, `statusError` text, `statusError` border

Replaces all `ElevatedButton`, `TextButton`, `OutlinedButton` usages across dialogs and action panels.

**`AppCard`**

Container with `surface` background, `border` border, `border-radius: 6`. Props: `selected` (highlights border to `borderHighlight` and tints background to `accentMuted`), `onTap`, `padding`.

Used for: mod list rows, dialog option sections, settings sections.

**`AppDialog`**

Wraps content with `BackdropFilter(blur 2×2)` + `Dialog` using `background` colour, `border` border, `border-radius: 8`. Provides consistent padding and title styling. Replaces the `BackdropFilter` + `AlertDialog` pattern repeated across all 12 dialogs.

**`AppTextField`**

Themed `TextField`: `surfaceElevated` fill, `border` outline, `accent` focused border, `textPrimary` text, `textMuted` hint. Replaces all raw `TextField` usages.

**`AppBadge`**

```dart
enum AppBadgeVariant { ok, warn, error, info, neutral }
```

Small rounded pill. Background: status colour at 15% opacity. Border: status colour at 40% opacity. Text: status colour. Size: `font-size: 10, padding: 2×6`.

Replaces all inline `Container`+`Text` status indicators in mod list, URL check results, download results.

**`AppTooltip`**

Wraps Flutter `Tooltip`:
- `preferBelow: false`
- `waitDuration: Duration(milliseconds: 500)`
- `showDuration: Duration(seconds: 3)` (Tier 1/2), `Duration(seconds: 5)` (Tier 3)
- Styled with `surface` background, `border` border, `textSecondary` text, `border-radius: 4`

Replaces `CustomTooltip` entirely (can be a thin wrapper or full replacement).

### 2.4 Mod List Item Rebuild

`ModsListItem` rebuilt as `AppCard` row:

```
AppCard (selected state driven by multiModsProvider)
└── Row
    ├── ModThumbnail (32×32)  ← mod.imageFilePath PNG if exists, themed placeholder Icon(Icons.extension) if not
    ├── SizedBox(8)
    ├── Column (flex: 1)
    │   ├── Text(mod.saveName, style: textPrimary, weight: 500)
    │   └── Text("${mod.assetCount} assets · ${relativeDate}", style: textMuted, size: 11)
    ├── SizedBox(8)
    └── AppBadge(variant based on mod state)
```

Badge logic:
- All assets present + backed up → `ok` "✓ backed up"
- All assets present → `ok` "✓ all assets"  
- Some missing → `error` "N missing"
- Update available → `warn` "↑ update"
- No assets → `neutral` "no assets"

**Display modes** (driven by `modListStyleProvider`):
- `richRows` — the above (default)
- `gridCards` — `ModsGridCard` rebuilt with 80px cover art area + name + badge
- `compact` — `AppCard` at 28px height: status dot + name + count only

### 2.5 Dialog Updates

All 12 dialogs updated to use `AppDialog` + `AppButton` + `AppTextField` + `AppCard`. Logic unchanged. Visual changes only:

- `SettingsDialog` — sections become `AppCard` containers, inputs become `AppTextField`, buttons become `AppButton`
- `SingleModBackupDialog` — same treatment
- `DownloadModsDialog` — same treatment  
- `BulkBackupDialog`, `BulkDeleteDialog`, `ImportJsonDialog` — same treatment
- `UrlCheckResultsDialog`, `BulkUpdateResultsDialog`, `DownloadResultsDialog` — results use `AppBadge`
- `ReplaceUrlDialog`, `UpdateUrlsDialog` — inputs become `AppTextField`
- `RenameOldBackupsDialog` — same treatment

---

## Settings Additions

**Interface section** gains three new controls:

| Setting | Widget | Default | Hive key |
|---|---|---|---|
| Theme | `ThemeSelector` (3 coloured circles) | `purpleDark` | `appThemeId` |
| Mod list style | Segmented 3-option | `richRows` | `modListStyle` |
| Mod list density | Segmented 3-option | `default` | `modListDensity` |

`modListDensity` controls row height and internal spacing only (does not change which fields are shown):
- `compact` — 32px row height, 6px vertical padding
- `default` — 44px row height, 10px vertical padding (spec default)
- `comfortable` — 56px row height, 14px vertical padding

`useModsListView` existing setting is **replaced** by `modListStyle` (`richRows` maps to old list-off, `gridCards` maps to old list-on). Migration: on first load, if old `useModsListView = true`, set `modListStyle = gridCards`.

---

## Tooltip Coverage

**`TooltipStrings` constant class** — all strings centralised.

**Tier 1 — Icon-only buttons** (500ms delay, 3s show):
Every `IconAction` in `TopNavBar`, every icon-only button in toolbar (Sort, Filter, Search toggle, Bulk Actions chevron), log panel icon buttons.

**Tier 2 — Labelled controls** (500ms delay, 3s show):
Filter chips (describe what the filter does), `AppBadge` in mod list (describe asset state + suggested action), mod count display ("N of M mods shown — filters active"), `BulkActionsMenu` items.

**Tier 3 — Complex features** (750ms delay, 5s show):
Cleanup sidebar button, "Re-download all assets" menu item, "Check all URLs" bulk action, "Force re-download" option, shared asset indicators, backup status icons, the proxy URL field.

---

## Settings Persistence

New Hive keys:
- `appThemeId` — `String` (enum name)
- `modListStyle` — `String`
- `modListDensity` — `String`  
- `logPanelHeight` — `double`
- `detailPanelExpanded` — `bool`

All stored via existing `StorageNotifier` pattern (or direct Hive box access matching existing style).

---

## What Is NOT in Scope

- Backups page visual rework (same component library applies but no layout changes)
- Images viewer page
- Splash/loading screen
- Any functional changes — this is visual only
- Animations beyond the panel transition (200ms easeInOut)
