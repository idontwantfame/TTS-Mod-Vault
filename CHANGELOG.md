# Changelog

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
