import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart'
    show HookConsumerWidget, WidgetRef;
import 'package:tts_mod_vault/src/state/provider.dart'
    show actionInProgressProvider, appThemeDataProvider, backupSortAndFilterProvider;
import 'package:tts_mod_vault/src/state/sort_and_filter/backup_sort_and_filter_state.dart'
    show BackupSortOptionEnum;

class BackupSortButton extends HookConsumerWidget {
  const BackupSortButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionInProgress = ref.watch(actionInProgressProvider);
    final backupSortAndFilterState = ref.watch(backupSortAndFilterProvider);
    final backupSortAndFilterNotifier =
        ref.read(backupSortAndFilterProvider.notifier);
    final t = ref.watch(appThemeDataProvider);

    return MenuAnchor(
      style: MenuStyle(
        backgroundColor: WidgetStateProperty.all(t.surface),
      ),
      builder: (context, controller, child) {
        return ElevatedButton.icon(
          onPressed: () {
            if (actionInProgress) return;

            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(t.surfaceElevated),
            foregroundColor: WidgetStateProperty.all(t.textPrimary),
          ),
          icon: const Icon(
            Icons.sort,
            size: 20,
          ),
          label: Text(
            backupSortAndFilterState.sortOption.label,
            textAlign: TextAlign.center,
          ),
        );
      },
      menuChildren: [
        ...BackupSortOptionEnum.values.map(
          (sortOption) {
            final isSelected =
                backupSortAndFilterState.sortOption == sortOption;

            return MenuItemButton(
              closeOnActivate: true,
              style: MenuItemButton.styleFrom(
                backgroundColor: t.surface,
                foregroundColor: t.textPrimary,
                iconColor: t.textSecondary,
              ),
              child: Row(
                spacing: 8,
                children: [
                  Icon(isSelected ? Icons.check : null),
                  Expanded(
                    child: Text(
                      sortOption.label,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              onPressed: () =>
                  backupSortAndFilterNotifier.setSortOption(sortOption),
            );
          },
        ),
      ],
    );
  }
}
