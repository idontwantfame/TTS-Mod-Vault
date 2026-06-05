# TTS Mod Vault

![Downloads](https://img.shields.io/github/downloads/idontwantfame/TTS-Mod-Vault/total?color=red&label=Total+downloads&style=for-the-badge)
![Latest Downloads](https://img.shields.io/github/downloads/idontwantfame/TTS-Mod-Vault/latest/total?color=blue&label=Latest+release+downloads&style=for-the-badge)
![Version](https://img.shields.io/github/v/release/idontwantfame/TTS-Mod-Vault?label=Latest+release&style=for-the-badge)

A cross-platform mod backup and download tool for Tabletop Simulator on Windows, Linux, and macOS. Download assets, create backups, manage URLs, and keep your mods, saves, and saved objects safe.

> **Fork notice:** This is a fork of [markomijic/TTS-Mod-Vault](https://github.com/markomijic/TTS-Mod-Vault) by [@markomijic](https://github.com/markomijic). Full credit for the original application goes to the original author. This fork adds UI improvements, performance fixes, and additional features on top of the upstream work.

## Alternative to TTS Mod Backup

TTS Mod Vault is an actively maintained alternative to [TTS Mod Backup](https://www.nexusmods.com/tabletopsimulator/mods/263), which is no longer updated. TTS Mod Vault imports .ttsmod files created by either tool, runs on all major platforms (not just Windows), and includes additional features like images viewing, backups tab and more.

## Download

- [GitHub Releases](https://github.com/idontwantfame/TTS-Mod-Vault/releases)

## What's new in this fork

- **Reworked UI** — top navigation bar, collapsible mod info panel, resizable log console, new dark theme system with multiple palettes
- **Download Workshop mod by URL** — paste a full Steam Workshop URL to download the mod and all its assets in one step
- **Force re-download all assets** — re-fetch every asset regardless of local cache state
- **HTTP / SOCKS5 proxy support** — route all downloads through a proxy configured in Settings → Network
- **Improved download performance** — image processing and BSON conversion run off the main thread; downloads no longer block the UI
- **Comprehensive logging** — per-level filter chips, batch progress milestones, structured log lines with severity prefix
- **UI tooltips** — every interactive element has a descriptive hover tooltip
- **CI/CD pipeline** — GitHub Actions builds Linux, Windows and macOS; pushing a `v*.*.*` tag publishes a release with all platform binaries

## Features

### Backup, Download & Update

- **Download** – Download all assets to the local cache used by Tabletop Simulator
- **Backup** – Create backups in the .ttsmod file format
- **Backups tab** – Browse and manage all your backup files
- **Import Backups** – Import .ttsmod files created by TTS Mod Vault or TTS Mod Backup
- **JSON Import** – Import mod JSON files directly
- **Backup state** – See which mods have a backup file and whether it is out of date or up to date
- **Download Workshop Mods by ID or URL** – Download with a single ID, multiple IDs, or a full Workshop URL
- **Mod updates from Steam Workshop** – Check for and apply mod updates

### Bulk Actions

- Download, backup, update mods, delete assets, update URLs
- **Multi-select** – Select multiple mods for bulk actions

### URL Management

- **Automatic URL handling** – Handles files using old URL format (`http://cloud-3.steamusercontent.com/` → `https://steamusercontent-a.akamaihd.net/`)
- **Replace URL** – Replace an asset URL with a new one
- **Update URLs** – Replace prefixes or entire URLs, either for a single item or as a bulk action
- **Update URL presets** – Save and reuse URL replacement presets in Settings
- **Check for shared asset URLs** – Detect assets shared across mods
- **Check for invalid asset URLs** – Find broken or invalid asset links

### Sort, Filter & Browse

- Sort by A-Z, newest, missing assets, or recently updated
- Filter by folders, backup state, asset status, and asset type
- Filter mods by backup asset count mismatch
- **Search assets** – Search through assets of a selected mod
- **View Images** – View all downloaded images of a specific mod in one place
- **Open Files** – Open Audio, Images, and PDF files directly

### Mod & Asset Management

- **Mod and asset file deletion** – Delete mod and asset files directly from the app
- **Per-mod audio asset handling** – Configure audio handling on a per-mod basis

### Cache & Cleanup

- Remove unused cached files that aren't part of your installed mods, saves, or saved objects
- **Mod and Backup information caching** – Faster loading times with cached mod and backup data

### Settings & Configuration

- Separately set paths for your Mods folder and Saves folder
- Custom Asset URL font size
- Exclude audio, subfolders, and domains
- HTTP / SOCKS5 proxy with test connection button

## Installation

### Windows

Download the latest `.zip` from [GitHub Releases](https://github.com/idontwantfame/TTS-Mod-Vault/releases), extract it, and run the `.exe` file.

### Linux

Download the latest `.zip` from [GitHub Releases](https://github.com/idontwantfame/TTS-Mod-Vault/releases), extract it, and run the executable.

### macOS (Apple Silicon)

Download the latest `.dmg` from [GitHub Releases](https://github.com/idontwantfame/TTS-Mod-Vault/releases), open it, and drag the application to your Applications folder.

## Building from Source

Created using Flutter. To build the app, follow the official Flutter documentation: https://docs.flutter.dev/get-started/install

## Credits

Original application by [@markomijic](https://github.com/markomijic) — [markomijic/TTS-Mod-Vault](https://github.com/markomijic/TTS-Mod-Vault)
