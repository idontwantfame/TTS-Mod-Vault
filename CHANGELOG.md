# Changelog

## v3.1.0

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
