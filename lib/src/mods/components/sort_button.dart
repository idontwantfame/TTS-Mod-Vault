import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart'
    show HookConsumerWidget, WidgetRef;
import 'package:tts_mod_vault/src/state/provider.dart'
    show actionInProgressProvider, appThemeDataProvider, sortAndFilterProvider;
import 'package:tts_mod_vault/src/state/sort_and_filter/sort_and_filter_state.dart'
    show SortOptionEnum;

class SortButton extends HookConsumerWidget {
  const SortButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionInProgress = ref.watch(actionInProgressProvider);
    final sortAndFilterState = ref.watch(sortAndFilterProvider);
    final sortAndFilterNotifier = ref.read(sortAndFilterProvider.notifier);
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
          style: ElevatedButton.styleFrom(
            backgroundColor: t.surfaceElevated,
            foregroundColor: t.textPrimary,
            side: BorderSide(color: t.border),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6)),
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          ),
          icon: Icon(Icons.sort, size: 16),
          label: Text(
            sortAndFilterState.sortOption.label,
            textAlign: TextAlign.center,
          ),
        );
      },
      menuChildren: [
        ...SortOptionEnum.values.map(
          (sortOption) {
            final isSelected = sortAndFilterState.sortOption == sortOption;

            return MenuItemButton(
              closeOnActivate: true,
              style: MenuItemButton.styleFrom(
                backgroundColor: t.surface,
                foregroundColor: t.textPrimary,
                iconColor: isSelected ? t.accent : t.textMuted,
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
              onPressed: () => sortAndFilterNotifier.setSortOption(sortOption),
            );
          },
        ),
      ],
    );
  }
}
