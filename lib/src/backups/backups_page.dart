import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart'
    show ConsumerWidget, WidgetRef;
import 'package:tts_mod_vault/src/backups/components/backups_view.dart'
    show BackupsView;
import 'package:tts_mod_vault/src/backups/components/components.dart'
    show BackupSortButton, BackupFilterButton;
import 'package:tts_mod_vault/src/mods/components/components.dart'
    show BulkActionsProgressBar, Search;
import 'package:tts_mod_vault/src/state/provider.dart'
    show appThemeDataProvider, backupsSearchQueryProvider, filteredBackupsProvider;
import 'package:tts_mod_vault/src/ui/ui.dart' show AppTooltip;

class BackupsPage extends ConsumerWidget {
  const BackupsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appThemeDataProvider);
    final total = ref.watch(filteredBackupsProvider).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: t.border)),
          ),
          child: Row(
            spacing: 4,
            children: [
              AppTooltip(
                message: 'Sort backups',
                child: BackupSortButton(),
              ),
              AppTooltip(
                message: 'Filter backups',
                child: BackupFilterButton(),
              ),
              if (total > 0)
                Text(
                  '$total',
                  style: TextStyle(fontSize: 12, color: t.textMuted),
                ),
              const Spacer(),
              SizedBox(
                width: 220,
                child: Search(searchQueryProvider: backupsSearchQueryProvider),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: BackupsView(),
          ),
        ),
        BulkActionsProgressBar(),
      ],
    );
  }
}
