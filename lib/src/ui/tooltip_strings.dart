abstract class TooltipStrings {
  // Top nav — Tier 1
  static const navRefresh = 'Refresh mod data';
  static const navCleanup = 'Cleanup orphaned asset files\n'
      'Scans asset folders and removes files no longer used by any mod. '
      'Shows count before deleting — irreversible.';
  static const navImportBackup = 'Import backup (.ttsmod)';
  static const navImportJson = 'Import mod from JSON file';
  static const navDownload = 'Download Workshop mod by URL or ID';
  static const navHelp = 'Help & about';
  static const navSettings = 'Open Settings';
  static const navToggleLog = 'Toggle activity log';

  // Toolbar — Tier 1
  static const toolbarSort = 'Sort mods';
  static const toolbarFilter = 'Filter mods';
  static const toolbarSearch = 'Search mods';
  static const toolbarBulk = 'Bulk actions';

  // Mod list badges — Tier 2
  static const badgeAllAssets = 'All assets present on disk';
  static const badgeBacked = 'All assets present and backed up';
  static const badgeMissing =
      'Some asset files are missing.\nClick Download in the details panel to fetch them.';
  static const badgeUpdate = 'A newer version is available on the Workshop';
  static const badgeNoAssets = 'This mod has no downloadable assets';

  // Complex features — Tier 3
  static const cleanupButton = 'Find and delete asset files no longer '
      'referenced by any loaded mod.\nShows the count before deleting. '
      'Cannot be undone.';
  static const redownloadAll = 'Re-fetch every asset file for this mod, '
      'overwriting existing files.\nUseful when a download was corrupted.';
  static const bulkCheckUrls = 'Check all asset URLs in the current list '
      'for dead links.\nRuns in sequence — can take a while for large collections.';
  static const forceRedownload = 'Force re-download all assets even if '
      'they already exist on disk.';
  static const proxyUrl = 'Route all downloads through a proxy server.\n'
      'Formats: http://host:port  or  socks5://host:port';
  static const sharedAsset =
      'This asset is shared with other mods. Deleting it may affect them.';
}
