import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart'
    show ConsumerWidget, WidgetRef;
import 'package:tts_mod_vault/src/mods/components/components.dart'
    show DownloadModsDialog, ImportJsonDialog;
import 'package:tts_mod_vault/src/state/provider.dart'
    show
        AppPage,
        actionInProgressProvider,
        appThemeDataProvider,
        bulkActionsProvider,
        cleanupProvider,
        directoriesProvider,
        importBackupProvider,
        loaderProvider,
        loggingProvider,
        selectedPageProvider,
        settingsProvider;
import 'package:tts_mod_vault/src/settings/settings_dialog.dart'
    show SettingsDialog;
import 'package:tts_mod_vault/src/help_dialog.dart' show showHelpDialog;
import 'package:tts_mod_vault/src/ui/ui.dart';
import 'package:tts_mod_vault/src/utils.dart'
    show showConfirmDialog, showConfirmDialogWithCheckbox, showSnackBar;

class TopNavBar extends ConsumerWidget {
  const TopNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appThemeDataProvider);
    final selectedPage = ref.watch(selectedPageProvider);
    final actionInProgress = ref.watch(actionInProgressProvider);
    final backupsDir = ref.watch(directoriesProvider).backupsDir;

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(bottom: BorderSide(color: t.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Text(
            'TTS Mod Vault',
            style: TextStyle(
              color: t.accent,
              fontWeight: FontWeight.w700,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 20),
          _PageTab(
            label: 'Mods',
            active: selectedPage == AppPage.mods,
            onTap: () =>
                ref.read(selectedPageProvider.notifier).state = AppPage.mods,
          ),
          const SizedBox(width: 4),
          if (backupsDir.isNotEmpty)
            _PageTab(
              label: 'Backups',
              active: selectedPage == AppPage.backups,
              onTap: () =>
                  ref.read(selectedPageProvider.notifier).state =
                      AppPage.backups,
            ),
          const Spacer(),
          _NavIconAction(
            icon: Icons.refresh,
            tooltip: TooltipStrings.navRefresh,
            disabled: actionInProgress,
            onPressed: () => showConfirmDialogWithCheckbox(
              context,
              title: 'Refresh all data?',
              onConfirm: (clearCache) async =>
                  ref.read(loaderProvider).refreshAppData(clearCache),
              checkboxLabel: 'Clear Vault cache',
              checkboxInfoMessage:
                  'Reloads everything from files instead of cache. Takes longer.',
            ),
          ),
          _NavIconAction(
            icon: Icons.delete_sweep,
            tooltip: TooltipStrings.navCleanup,
            disabled: actionInProgress,
            onPressed: () async {
              final cleanupNotifier = ref.read(cleanupProvider.notifier);
              await cleanupNotifier.startCleanup((count) {
                if (count > 0) {
                  final types = ref.read(settingsProvider).showSavedObjects
                      ? 'mods, saves and saved objects'
                      : 'mods and saves';
                  showConfirmDialog(
                    context,
                    '$count asset files found that are not used by any of your $types.\n\nAre you sure you want to delete them?',
                    () async => cleanupNotifier.executeDelete(),
                    () => cleanupNotifier.resetState(),
                  );
                } else {
                  showSnackBar(context, 'No files found to delete');
                }
              });
            },
          ),
          _NavIconAction(
            icon: Icons.unarchive,
            tooltip: TooltipStrings.navImportBackup,
            disabled: actionInProgress,
            onPressed: () async =>
                ref.read(bulkActionsProvider.notifier).importBackups(),
          ),
          _NavIconAction(
            icon: Icons.upload_file,
            tooltip: TooltipStrings.navImportJson,
            disabled: actionInProgress,
            onPressed: () => showDialog(
              context: context,
              builder: (ctx) => ImportJsonDialog(
                onConfirm: (jsonFilePath, destination, modType, pngFilePath) =>
                    ref.read(importBackupProvider.notifier).importJson(
                        jsonFilePath, destination, modType, pngFilePath),
              ),
            ),
          ),
          _NavIconAction(
            icon: Icons.download,
            tooltip: TooltipStrings.navDownload,
            disabled: actionInProgress,
            onPressed: () => showDialog(
              context: context,
              builder: (ctx) => const DownloadModsDialog(),
            ),
          ),
          _NavIconAction(
            icon: Icons.help_outline_rounded,
            tooltip: TooltipStrings.navHelp,
            onPressed: () => showHelpDialog(context),
          ),
          _NavIconAction(
            icon: Icons.settings,
            tooltip: TooltipStrings.navSettings,
            onPressed: () => showDialog(
              context: context,
              builder: (ctx) => const SettingsDialog(),
            ),
          ),
          _NavIconAction(
            icon: Icons.terminal,
            tooltip: TooltipStrings.navToggleLog,
            onPressed: () =>
                ref.read(loggingProvider.notifier).toggleVisibility(),
          ),
        ],
      ),
    );
  }
}

class _PageTab extends ConsumerWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _PageTab(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appThemeDataProvider);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: active ? t.accentMuted : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: active ? t.borderHighlight : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? t.accent : t.textSecondary,
            fontSize: 12,
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _NavIconAction extends ConsumerWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool disabled;

  const _NavIconAction({
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appThemeDataProvider);
    return AppTooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, size: 18),
        color: disabled ? t.textMuted : t.textSecondary,
        onPressed: disabled ? null : onPressed,
        padding: const EdgeInsets.all(6),
        constraints: const BoxConstraints(),
        splashRadius: 18,
      ),
    );
  }
}
