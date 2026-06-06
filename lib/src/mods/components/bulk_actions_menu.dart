import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart' show useMemoized;
import 'package:hooks_riverpod/hooks_riverpod.dart'
    show HookConsumerWidget, WidgetRef;
import 'package:tts_mod_vault/src/ui/ui.dart'
    show AppTooltip, AppTooltipTier, TooltipStrings;

import 'package:tts_mod_vault/src/state/mods/mod_model.dart' show ModTypeEnum;
import 'package:tts_mod_vault/src/state/provider.dart'
    show
        actionInProgressProvider,
        modsSearchQueryProvider,
        selectedModTypeProvider,
        sortAndFilterProvider;
import 'package:tts_mod_vault/src/mods/components/components.dart'
    show BulkBackupDialog, BulkDeleteDialog, showUpdateUrlsDialog;
import 'package:tts_mod_vault/src/utils.dart'
    show showConfirmDialogWithCheckbox;
import 'package:tts_mod_vault/src/state/bulk_actions/bulk_actions_state.dart'
    show BulkBackupBehaviorEnum;
import 'package:tts_mod_vault/src/state/provider.dart'
    show actionInProgressProvider, appThemeDataProvider, bulkActionsProvider,
        filteredModsProvider;

class BulkActionsMenu extends HookConsumerWidget {
  const BulkActionsMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionInProgress = ref.watch(actionInProgressProvider);
    final selectedModType = ref.watch(selectedModTypeProvider);
    final sortAndFilterState = ref.watch(sortAndFilterProvider);
    final searchQuery = ref.watch(modsSearchQueryProvider);

    final selectedFolders = useMemoized(() {
      Set<String> selectedFolders = switch (selectedModType) {
        ModTypeEnum.mod => sortAndFilterState.filteredModsFolders,
        ModTypeEnum.save => sortAndFilterState.filteredSavesFolders,
        ModTypeEnum.savedObject =>
          sortAndFilterState.filteredSavedObjectsFolders,
      };

      return selectedFolders;
    }, [selectedModType, sortAndFilterState]);

    final bulkActionLimited = useMemoized(() {
      return selectedFolders.isNotEmpty ||
          sortAndFilterState.filteredBackupStatuses.isNotEmpty ||
          sortAndFilterState.filteredAssets.isNotEmpty ||
          searchQuery.isNotEmpty;
    }, [selectedFolders, sortAndFilterState, searchQuery]);

    return AppTooltip(
      message: bulkActionLimited
          ? 'Bulk actions will apply only to the current selection because of search and/or filters'
          : '',
      child: Badge(
        label: Text('!'),
        backgroundColor: Colors.grey[600],
        textColor: Colors.white,
        smallSize: 12,
        isLabelVisible: bulkActionLimited && !actionInProgress,
        child: _BulkActionsDropDownButton(),
      ),
    );
  }
}

class _BulkActionsDropDownButton extends HookConsumerWidget {
  const _BulkActionsDropDownButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionInProgress = ref.watch(actionInProgressProvider);
    final selectedModType = ref.watch(selectedModTypeProvider);
    final t = ref.watch(appThemeDataProvider);

    return MenuAnchor(
      style: MenuStyle(
        backgroundColor: WidgetStateProperty.all(t.surface),
      ),
      menuChildren: <Widget>[
        MenuItemButton(
          style: MenuItemButton.styleFrom(
            backgroundColor: t.surface,
            foregroundColor: t.textPrimary,
          ),
          leadingIcon: Icon(Icons.download, color: t.textPrimary),
          child: AppTooltip(
            message: 'Download all missing assets for every mod in the current view',
            child: Text('Download all', style: TextStyle(color: t.textPrimary))),
          onPressed: () {
            if (actionInProgress) return;

            ref
                .read(bulkActionsProvider.notifier)
                .downloadAllMods(ref.read(filteredModsProvider));
          },
        ),
        MenuItemButton(
          style: MenuItemButton.styleFrom(
            backgroundColor: t.surface,
            foregroundColor: t.textPrimary,
          ),
          leadingIcon: Icon(Icons.archive, color: t.textPrimary),
          child: AppTooltip(
            message: 'Create a backup archive for every mod in the current view',
            child: Text('Backup all', style: TextStyle(color: t.textPrimary))),
          onPressed: () {
            if (actionInProgress) return;

            showDialog(
              context: context,
              builder: (context) => BulkBackupDialog(
                title: 'Backup all',
                initialBehavior: BulkBackupBehaviorEnum.replaceIfOutOfDate,
                onConfirm:
                    (behavior, folder, postBackupDeletion, setAsDefault) {
                  ref.read(bulkActionsProvider.notifier).backupAllMods(
                        ref.read(filteredModsProvider),
                        behavior,
                        folder,
                        postBackupDeletion,
                        setAsDefault,
                      );
                },
              ),
            );
          },
        ),
        MenuItemButton(
          style: MenuItemButton.styleFrom(
            backgroundColor: t.surface,
            foregroundColor: t.textPrimary,
          ),
          leadingIcon: Icon(Icons.download, color: t.textPrimary),
          trailingIcon: Icon(Icons.archive, color: t.textPrimary),
          child: AppTooltip(
            message: 'Download missing assets then create backup archives',
            child: Text('Download & backup all',
              style: TextStyle(color: t.textPrimary))),
          onPressed: () {
            if (actionInProgress) return;

            showDialog(
              context: context,
              builder: (context) => BulkBackupDialog(
                title: 'Download & backup all',
                initialBehavior: BulkBackupBehaviorEnum.replaceIfOutOfDate,
                onConfirm:
                    (behavior, folder, postBackupDeletion, setAsDefault) {
                  ref
                      .read(bulkActionsProvider.notifier)
                      .downloadAndBackupAllMods(
                        ref.read(filteredModsProvider),
                        behavior,
                        folder,
                        postBackupDeletion,
                        setAsDefault,
                      );
                },
              ),
            );
          },
        ),
        if (selectedModType == ModTypeEnum.mod)
          MenuItemButton(
            style: MenuItemButton.styleFrom(
              backgroundColor: t.surface,
              foregroundColor: t.textPrimary,
            ),
            leadingIcon: Icon(Icons.update, color: t.textPrimary),
            child: AppTooltip(
            message: 'Check Steam Workshop for newer versions and re-download',
            child: Text('Update all mods', style: TextStyle(color: t.textPrimary))),
            onPressed: () {
              if (actionInProgress) return;

              showConfirmDialogWithCheckbox(
                context,
                title: 'Update all mods',
                message:
                    'Check for updates and download newer versions from Steam Workshop',
                checkboxLabel: 'Force update',
                checkboxInfoMessage:
                    'Re-download all mods even if already up to date',
                showWarning: true,
                warningText:
                    "This feature has been tested with various mods, however it's recommended to let\nTabletop Simulator handle updates for subscribed mods to avoid unexpected issues.",
                onConfirm: (forceUpdate) {
                  ref.read(bulkActionsProvider.notifier).updateModsAll(
                        ref.read(filteredModsProvider),
                        forceUpdate,
                        context,
                      );
                },
              );
            },
          ),
        MenuItemButton(
          style: MenuItemButton.styleFrom(
            backgroundColor: t.surface,
            foregroundColor: t.textPrimary,
          ),
          leadingIcon: Icon(Icons.delete, color: t.textPrimary),
          child: AppTooltip(
            message: 'Delete all downloaded asset files (mod JSON files are kept)',
            child: Text('Delete all assets', style: TextStyle(color: t.textPrimary))),
          onPressed: () {
            if (actionInProgress) return;

            showDialog(
              context: context,
              builder: (context) => BulkDeleteDialog(
                title: 'Delete all assets',
                onConfirm: (deletionOption) {
                  ref.read(bulkActionsProvider.notifier).deleteAssetsAllMods(
                        ref.read(filteredModsProvider),
                        deletionOption,
                      );
                },
              ),
            );
          },
        ),
        AppTooltip(
          message: TooltipStrings.bulkCheckUrls,
          tier: AppTooltipTier.complex,
          child: MenuItemButton(
            style: MenuItemButton.styleFrom(
              backgroundColor: t.surface,
              foregroundColor: t.textPrimary,
            ),
            leadingIcon: Icon(Icons.link, color: t.textPrimary),
            child: Text('Check all URLs', style: TextStyle(color: t.textPrimary)),
            onPressed: () {
              if (actionInProgress) return;
              ref
                  .read(bulkActionsProvider.notifier)
                  .checkUrlsAllMods(ref.read(filteredModsProvider));
            },
          ),
        ),
        MenuItemButton(
          style: MenuItemButton.styleFrom(
            backgroundColor: t.surface,
            foregroundColor: t.textPrimary,
          ),
          leadingIcon: Icon(Icons.edit, color: t.textPrimary),
          child: AppTooltip(
            message: 'Find and replace a URL prefix in asset links across every mod',
            child: Text('Update all URLs', style: TextStyle(color: t.textPrimary))),
          onPressed: () {
            if (actionInProgress) return;

            showUpdateUrlsDialog(
              context,
              ref,
              onConfirm: (oldUrlPrefix, newUrlPrefix, renameFile) {
                ref.read(bulkActionsProvider.notifier).updateUrlPrefixesAllMods(
                      ref.read(filteredModsProvider),
                      oldUrlPrefix.split('|'),
                      newUrlPrefix,
                      renameFile,
                    );
              },
            );
          },
        ),
      ],
      builder: (
        BuildContext context,
        MenuController controller,
        Widget? child,
      ) {
        return ElevatedButton.icon(
          onPressed: actionInProgress
              ? null
              : () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
          label: Text('Bulk actions'),
          icon: Icon(
            Icons.arrow_drop_down,
            size: 26,
          ),
        );
      },
    );
  }
}
