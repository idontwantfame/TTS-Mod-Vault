# Changelog

## v3.5.2

### Bug fixes

- **Proxy test button** — "Test connection" now tests the URL currently in the text field without saving it first, so you can verify a proxy before committing to it

---

## v3.5.1

### Bug fixes & polish

- **Backups tab navigation** — Mods / Saves / Saved Objects tabs now always visible; clicking any of them while on the Backups page navigates back to the correct mod type
- **Backups toolbar** — removed the redundant "Backups" label; Sort and Filter on the left, count in the middle, Search on the right — consistent with the Mods page toolbar
- **Backups list item** — completely redesigned to match Mods list style: compact 40 px thumbnail, 13 px title, 11 px muted subtitle with asset count / file size / date, import-status icon on the right
- **Backups dropdowns** — Sort and Filter menus now fully themed (was hardcoded white/black)
- **Grid card selection border** — selected card uses `accent`, hovered card uses `borderHighlight` (was hardcoded white)
- **Full theme pass across 33 files** — eliminated all remaining `Colors.white`, `Colors.black`, and `Colors.grey` hardcoded colors; every UI element now uses `AppThemeData` tokens
- **Dead code removed** — deleted `sidebar.dart` and `log_panel.dart` (replaced by TopNavBar and LoggingConsole in v3.5.0)

---

## v3.5.0

### UI rework

- **New theme system** — three dark palettes (Purple Dark, Blue Slate, Black Teal) switchable in Settings → Interface
- **Top navigation bar** — replaces the sidebar; Mods / Saves / Saved Objects / Backups tabs at the top
- **Collapsible mod info panel** — click any mod to open the detail panel on the right; click it again to close it
- **Resizable log console** — drag the top edge to any height; S / M / L preset buttons for quick snapping
- **Comprehensive tooltips** — every button, tab, menu item, and icon has a descriptive hover tooltip (300 ms delay)
- **Consistent dark theming** — all dropdowns, settings dialogs, filter menus, checkboxes, text fields, and context menus now use the active theme palette

### Performance

- **Image processing off-thread** — thumbnail decode / crop-resize / encode runs in a background isolate; eliminated the 0.5–2 s UI freeze per mod download
- **BSON → JSON conversion off-thread** — Workshop mod conversion no longer blocks the main thread
- **Downloads non-blocking** — active downloads no longer lock the mod list; scroll, select, and browse freely while assets download
- **Batched asset state updates** — N separate map copies reduced to one per completed batch
- **Throttled progress updates** — capped at one UI update per 100 ms during single-file downloads

### Other

- **Changelog rendered from file** — the in-app changelog dialog reads and renders `CHANGELOG.md` directly; no more hardcoded release notes
- **Update check points to this fork** — version checks and release links use `idontwantfame/TTS-Mod-Vault`
- **README updated** — fork attribution, updated download links, "What's new" section

---

## v3.0.1

### Critical fix

- **Cleanup deleted all asset files** — the case-sensitivity fix in v3.0.0 (issue #47) lowercased `getFileNameFromURL`, so the reference set was lowercase. But `processDirectoryInIsolate` compared un-lowercased disk filenames against that set, so every file failed the match and was flagged as orphaned regardless of whether it was actually referenced. A single `.toLowerCase()` call (matching what `_getDirectoryFileNamesAndPaths` already does) fixes the comparison.
- **Cleanup now falls back to JSON extraction** — if a mod's URL list is not yet in TMV's cache (e.g. assets downloaded directly by TTS before TMV was set up), the cleanup now reads URLs fresh from the mod's JSON file instead of silently treating all its assets as unreferenced.

### Download reliability

- **Retry with exponential backoff** — transient 5xx and connection errors are retried up to 3 times (1 s → 2 s → 4 s). 4xx client errors (dead URLs) fail immediately without burning retries.
- **Asset directories auto-created** — the Images/Models/etc. folders are created if missing before the first write, preventing silent failures on fresh installs.
- **Post-download UI refresh** — after downloading Workshop mod assets the app rescans the asset directories and rebuilds the mod state, so assets turn green immediately without a restart.
- **Workshop asset download fixed** — resolved a race condition where `existingAssetListsProvider` was stale at download time, causing all assets to be silently skipped.

### Logging

- **Full HTTP request/response logging in debug mode** — method, URL, all headers, and request body (truncated at 200 chars). Response includes status and all response headers.
- **Debug level** — new `DBG` (grey) severity level. Hidden by default; enable via the DBG chip in the console toolbar.
- **Level prefix in log text** — every line now includes `[INFO]`/`[OK]`/`[WARN]`/`[ERR]`/`[DBG]` so copy/export is self-describing.
- **Batch progress milestones** — per asset type, the log emits `Images 25% — 62/62 saved` at 25/50/75/100%.
- **Cleaner failure messages** — `Download failed (HTTP 404): url` instead of the full Dio stack trace.
- **Comprehensive event coverage** — backup create/complete/error, bulk action start/complete, mods load time and count, settings reset, proxy enable/disable, URL prefix update summary.
- **Console UX** — clear button uses `delete_sweep` icon (distinct from the X close button); severity filter chips are toggleable.

### Proxy

- **Correct PAC string generation** — `http://`, `https://`, `socks5://`, `socks4://` schemes are all handled; previously `http://host:port` was passed literally to `findProxy` causing host-lookup failures.
- **Proxy applied on save** — changing the proxy URL in Settings now re-configures the Dio client immediately without restarting the app.
- **Test connection button** — Settings → Network has a *Test connection* button that hits `steamcommunity.com` through the configured proxy and reports `OK — 200` or the error inline.
- **Proxy shown in debug logs** — every request log line includes `via http://proxy:port` when a proxy is active.

### CI/CD

- Opted into Node.js 24 for all GitHub Actions runners (`FORCE_JAVASCRIPT_ACTIONS_TO_NODE24: true`).
- Updated action pins: `actions/checkout` → v6, `actions/upload-artifact` → v7, `actions/download-artifact` → v8, `softprops/action-gh-release` → v3.

## v3.0.0

Builds on top of [v2.0.0](https://github.com/markomijic/TTS-Mod-Vault/releases/tag/v2.0.0) from the upstream project.

### New Features

- **Download from Workshop URL** — paste a full Steam Workshop URL (`steamcommunity.com/sharedfiles/filedetails/?id=...`) directly into the Download Workshop Mods dialog. Includes a *Download all assets* checkbox (default: on) that pre-fetches every asset into the TTS directories so the mod is fully ready when TTS launches.

- **Force re-download all assets** — *Re-download all assets* in the selected mod actions menu. Re-fetches every asset regardless of whether it already exists on disk, replacing corrupted or incomplete files.

- **Bulk URL check** — *Check all URLs* in the Bulk Actions menu. Runs the invalid-URL checker across every mod in the current filtered list, updates each mod's indicator live, and logs a summary on completion.

- **HTTP proxy support** — new *Proxy URL* field in Settings → Network. Routes all asset downloads through a configured HTTP or SOCKS5 proxy. Persisted across restarts.

- **Toggleable debug console** — *Debug Console* toggle in the sidebar. Opens a panel with per-level filter chips (INFO / WARN / ERROR / DEBUG / NET), text search, copy-to-clipboard, and clear.

- **Filtered mod count in toolbar** — shows `156` (muted) when unfiltered; `42 / 156` (white) when a search or filter is active.

- **Remember backup folder** — the last folder chosen in the backup dialog is saved as the default and pre-populated on next open.

- **Detect asset URLs in Lua scripts** — mods that spawn objects dynamically from Lua (common in wargaming mods) now have their asset URLs detected and tracked.

- **Linux .desktop file** — included for proper desktop environment integration (launchers, file associations).

- **CI/CD build pipeline** — GitHub Actions builds Linux, Windows and macOS on every push. Pushing a `v*.*.*` tag automatically creates a release with all three platform binaries attached.

### Bug Fixes

- **URL checker false positives** — CDNs sometimes return HTTP 200 + HTML for deleted content; the checker now treats any `text/html` response as invalid regardless of status code.

- **Case-sensitive asset filenames** — `file.PDF` and `file.pdf` were treated as different lookup keys, causing re-downloads of already-present assets. All keys are now lowercased.

- **Open URL in Browser for scheme-less URLs** — URLs without `http://`/`https://` (e.g. `0rganics.org/tts/...`) now open correctly in the browser.

- **Asset URLs without a TLD ignored** — TTS accepts `https://something` (no dot/TLD in the hostname) as a valid asset URL. These are now recognised and tracked.

- **Backup and actions menu hidden for utility mods** — mods with only Lua scripts and no downloadable assets now always show the Backup button.

- **Missing .env causes crash on fresh clone** — empty committed `.env` and a try/catch around `dotenv.load()` fix both the build warning and the startup crash.

### Getting Started

**Windows:** Extract the zip and run the `.exe`. Click *More info → Run anyway* if a security warning appears.

**Linux:** Extract the tar.gz and run the executable. Copy `linux/tts_mod_vault.desktop` to `~/.local/share/applications/` for launcher integration.

**macOS:** Extract the zip. Right-click the `.app` → *Open* to bypass Gatekeeper on first launch (app is unsigned).

---

## v2.0.0

> It is recommended to clear the cache on the first run (Refresh → Clear Vault cache)

**BREAKING CHANGE:** Saved object backup file naming has been changed to `"Filename (saved object).ttsmod"`. Backups of saved objects made with previous versions will not be detected until renamed.

### Features

- Updated UI layout with sidebar
- Backups tab
- Backup information caching for faster loading times
- Check for shared asset URLs
- Check for invalid asset URLs
- Mod and asset file deletion
- Multi-select support for bulk actions
- Searching assets of selected mod
- Sorting by missing assets and recently updated
- Filtering by asset status and type
- Filtering mods by backup asset count mismatch
- New setting for Asset URL font size
- New setting for custom Saves folder path
- New settings for excluding audio, subfolders and domains
- Per-mod audio asset handling
- JSON import support
- Update URL presets in Settings
- Mod updates from Steam Workshop

### Changes

- Updated saved object backup naming
- Clear cache moved to Refresh and renamed to Clear Vault cache
- Removed setting to show or hide URL replacement features
- Various UI updates and refinements
- General bug fixes and improvements

---

## v1.3.0

> Due to asset URL bug fixes in this version, it is recommended to clear the cache on the first run. The new URL replacement features are disabled by default and can be enabled in Settings.

### Features

- Clear cache — available under Tools
- Update URLs — lets you replace prefixes or entire URLs, either for a single item or as a bulk action

### Changes

- New Setting — Force JSON filename inclusion in backup filename for all cases
- Last selected asset URL now stays highlighted after closing the context menu
- Removed the tool for renaming old backups
- Fixed Steam CDN URLs not downloading when a trailing `/` was missing
- Fixed URLs with spaces breaking UI and cache checks
- Fixed URLs with `\r` or `\n` suffixes breaking cache checks and downloads
- Fixed *Download Workshop Mod by ID* failing to create a JSON file in cases where BsonBinary exists within JSON data

---

## v1.2.1

### Changes

- Fixed URL replacement not working with the old URL format (`http://cloud-3.steamusercontent.com/`)
- Fixed loading failures caused by backup file names containing Unicode characters
- Added support for an additional date format in mod JSON files
- Reduced memory usage when creating a backup
- Reduced loading times for backup files

---

## v1.2.0

> Backup filename format changed. v1.2.0 updates the backup file naming format to match TTS Mod Backup. Backups created with TTS Mod Vault v1.0.0–v1.1.0 must be renamed to work with the new Backup State feature. A renaming tool is available under Tools → Rename old backups.

### Features

- Backup State
- Sort & Filter
- Bulk actions: Download All, Backup All, Download & Backup All
- Download Workshop Mod by ID

### Changes

- UI updates
- New settings options
- General improvements and fixes

---

## v1.1.0

### Features

- Search
- Viewing images
- Support for Saves and Saved Objects
- Separate selection of Mods and Saves folders
- Opening audio, image and PDF files
- URL replacement tool

### Changes

- Reworked loading system for faster load times
- Replaced storage solution with faster alternative for improved performance
- General improvements and fixes

---

## v1.0.2

### Changes

- Fixed mods not appearing if they were in a folder within the Workshop folder
- Fixed issue where downloading files from Dropbox links (where files were deleted) incorrectly marked them as downloaded

---

## v1.0.1

### Changes

- Fixed asset lists not updating due to incorrect reading of last time mod was updated
- Added Download from GitHub button to "Check for updates" dialog
- Performance improvements when opening file explorer

---

## v1.0.0

### Features

- Download — Download all mod assets locally
- Backup — Create backups of your mods
- Import Backup — Restore existing `.ttsmod` file backups
- Cleanup — Remove unused cached files that aren't part of your installed mods
