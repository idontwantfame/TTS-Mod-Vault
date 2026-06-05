import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart'
    show AsyncValueX, ConsumerWidget, HookConsumerWidget, WidgetRef;
import 'package:tts_mod_vault/src/mods/components/components.dart'
    show
        DownloadModsDialog,
        ErrorMessage,
        ImportJsonDialog,
        MessageProgressIndicator,
        Search,
        SelectedModView,
        ModsView,
        BulkActionsProgressBar,
        SortButton,
        BulkActionsMenu;
import 'package:tts_mod_vault/src/ui/ui.dart';
import 'package:tts_mod_vault/src/mods/components/filter_button.dart'
    show FilterButton;
import 'package:tts_mod_vault/src/mods/components/slim_tab.dart' show SlimTab;
import 'package:tts_mod_vault/src/logging/logging_console.dart'
    show LoggingConsole;
import 'package:tts_mod_vault/src/state/mods/mod_model.dart' show ModTypeEnum;
import 'package:tts_mod_vault/src/state/provider.dart'
    show
        actionInProgressProvider,
        appThemeDataProvider,
        bulkActionsProvider,
        cleanupProvider,
        detailPanelExpandedProvider,
        filteredModsProvider,
        importBackupProvider,
        loaderProvider,
        loadingMessageProvider,
        loggingProvider,
        modsProvider,
        modsSearchQueryProvider,
        selectedModTypeProvider,
        settingsProvider;
import 'package:tts_mod_vault/src/utils.dart'
    show showConfirmDialog, showConfirmDialogWithCheckbox, showSnackBar;

class ModsPage extends HookConsumerWidget {
  const ModsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loadingMessage = ref.watch(loadingMessageProvider);
    final mods = ref.watch(modsProvider);

    return mods.when(
      data: (data) {
        return Row(
          children: [
            Expanded(child: ModsColumn()),
            // Detail panel owns its own expanded-state watch
            _DetailPanelArea(),
          ],
        );
      },
      error: (e, st) => Center(
        child: Padding(
          padding: const EdgeInsets.only(right: 40),
          child: ErrorMessage(e: e),
        ),
      ),
      loading: () => Center(
        child: Padding(
          padding: const EdgeInsets.only(right: 40),
          child: MessageProgressIndicator(message: loadingMessage),
        ),
      ),
    );
  }
}

class ModsColumn extends ConsumerWidget {
  const ModsColumn({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appThemeDataProvider);
    final type = ref.watch(selectedModTypeProvider);
    final filtered = ref.watch(filteredModsProvider);
    final modsState = ref.watch(modsProvider).valueOrNull;
    final actionInProgress = ref.watch(actionInProgressProvider);
    final total = modsState == null
        ? 0
        : switch (type) {
            ModTypeEnum.mod => modsState.mods.length,
            ModTypeEnum.save => modsState.saves.length,
            ModTypeEnum.savedObject => modsState.savedObjects.length,
          };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Toolbar ──────────────────────────────────────────
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: t.border)),
          ),
          child: Row(
            spacing: 4,
            children: [
              // Sort & Filter — left-aligned
              _ToolbarBtn(icon: Icons.sort, tooltip: TooltipStrings.toolbarSort,
                  child: SortButton()),
              _ToolbarBtn(icon: Icons.filter_list,
                  tooltip: TooltipStrings.toolbarFilter,
                  child: FilterButton()),
              _Divider(),
              // Data actions
              _ActionBtn(
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
                      'Reloads everything from files instead of cache.',
                ),
              ),
              _ActionBtn(
                icon: Icons.delete_sweep,
                tooltip: TooltipStrings.navCleanup,
                tier: AppTooltipTier.complex,
                disabled: actionInProgress,
                onPressed: () async {
                  final cleanupNotifier = ref.read(cleanupProvider.notifier);
                  await cleanupNotifier.startCleanup((count) {
                    if (count > 0) {
                      final types =
                          ref.read(settingsProvider).showSavedObjects
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
              _ActionBtn(
                icon: Icons.unarchive,
                tooltip: TooltipStrings.navImportBackup,
                disabled: actionInProgress,
                onPressed: () =>
                    ref.read(bulkActionsProvider.notifier).importBackups(),
              ),
              _ActionBtn(
                icon: Icons.upload_file,
                tooltip: TooltipStrings.navImportJson,
                disabled: actionInProgress,
                onPressed: () => showDialog(
                  context: context,
                  builder: (ctx) => ImportJsonDialog(
                    onConfirm: (path, dest, modType, png) => ref
                        .read(importBackupProvider.notifier)
                        .importJson(path, dest, modType, png),
                  ),
                ),
              ),
              _ActionBtn(
                icon: Icons.download,
                tooltip: TooltipStrings.navDownload,
                disabled: actionInProgress,
                onPressed: () => showDialog(
                  context: context,
                  builder: (ctx) => const DownloadModsDialog(),
                ),
              ),
              _Divider(),
              // Bulk actions
              AppTooltip(
                message: TooltipStrings.toolbarBulk,
                child: BulkActionsMenu(),
              ),
              _Divider(),
              // Count display
              if (total > 0)
                Text(
                  filtered.length == total
                      ? '$total'
                      : '${filtered.length} / $total',
                  style: TextStyle(
                    fontSize: 12,
                    color: filtered.length == total
                        ? t.textMuted
                        : t.textPrimary,
                  ),
                ),
              // Activity log toggle
              _ActionBtn(
                icon: Icons.terminal,
                tooltip: TooltipStrings.navToggleLog,
                onPressed: () =>
                    ref.read(loggingProvider.notifier).toggleVisibility(),
              ),
              // Keyboard shortcut info
              AppTooltip(
                message: """• Left-click a ${type.label} to see assets
• Right-click for additional actions
• ${Platform.isMacOS ? '⌘' : 'Ctrl'}+click to multi-select""",
                tier: AppTooltipTier.complex,
                child: Icon(Icons.info_outline, size: 16, color: t.textMuted),
              ),
              // Search — floated right
              const Spacer(),
              SizedBox(
                width: 220,
                child: Search(searchQueryProvider: modsSearchQueryProvider),
              ),
            ],
          ),
        ),
        // ── Content ──────────────────────────────────────────
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8, right: 4),
            child: ModsView(),
          ),
        ),
        const LoggingConsole(),
        BulkActionsProgressBar(),
      ],
    );
  }
}

/// Small vertical divider for toolbar sections
class _Divider extends ConsumerWidget {
  const _Divider();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appThemeDataProvider);
    return Container(
      width: 1,
      height: 20,
      color: t.border,
      margin: const EdgeInsets.symmetric(horizontal: 2),
    );
  }
}

/// Wrapper that gives sort/filter buttons a consistent toolbar look
class _ToolbarBtn extends ConsumerWidget {
  final IconData icon;
  final String tooltip;
  final Widget child;

  const _ToolbarBtn(
      {required this.icon, required this.tooltip, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppTooltip(message: tooltip, child: child);
  }
}

/// Styled icon action button for the toolbar
class _ActionBtn extends ConsumerWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool disabled;
  final AppTooltipTier tier;

  const _ActionBtn({
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.disabled = false,
    this.tier = AppTooltipTier.standard,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appThemeDataProvider);
    final active = onPressed != null && !disabled;
    return AppTooltip(
      message: tooltip,
      tier: tier,
      child: GestureDetector(
        onTap: active ? onPressed : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Icon(
            icon,
            size: 17,
            color: active ? t.textSecondary : t.textMuted,
          ),
        ),
      ),
    );
  }
}

/// Owns its own watch of detailPanelExpandedProvider and renders either
/// the detail panel (with collapse handle) or the slim tab.
class _DetailPanelArea extends ConsumerWidget {
  const _DetailPanelArea();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expanded = ref.watch(detailPanelExpandedProvider);
    final t = ref.watch(appThemeDataProvider);

    if (!expanded) return const SlimTab();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Collapse handle
        AppTooltip(
          message: 'Collapse panel',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () =>
                ref.read(detailPanelExpandedProvider.notifier).set(false),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                width: 14,
                color: t.border.withValues(alpha: 0.4),
                alignment: Alignment.center,
                child:
                    Icon(Icons.chevron_right, size: 13, color: t.textMuted),
              ),
            ),
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width / 3,
          child: const SelectedModView(),
        ),
      ],
    );
  }
}
