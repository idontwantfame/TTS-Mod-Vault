import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart' show useState;
import 'package:hooks_riverpod/hooks_riverpod.dart'
    show HookConsumerWidget, WidgetRef;
import 'package:tts_mod_vault/src/state/bulk_actions/bulk_actions_state.dart'
    show PostBackupDeletionEnum;
import 'package:tts_mod_vault/src/state/provider.dart' show appThemeDataProvider;
import 'package:tts_mod_vault/src/ui/ui.dart'
    show AppDialog, AppButton, AppButtonVariant;

class BulkDeleteDialog extends HookConsumerWidget {
  final String title;
  final Function(PostBackupDeletionEnum deletionOption) onConfirm;

  const BulkDeleteDialog({
    super.key,
    required this.title,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appThemeDataProvider);
    final selectedDeletion =
        useState(PostBackupDeletionEnum.deleteNonSharedAssets);

    final options = PostBackupDeletionEnum.values
        .where((e) => e != PostBackupDeletionEnum.none)
        .toList();

    return AppDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Text(
            title,
            style:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
            Row(
              spacing: 8,
              children: [
                const Expanded(
                  child: Text('Shared assets:'),
                ),
                DropdownButton<PostBackupDeletionEnum>(
                  value: selectedDeletion.value,
                  dropdownColor: t.surface,
                  style: TextStyle(color: t.textPrimary),
                  underline: Container(
                    height: 2,
                    color: t.border,
                  ),
                  focusColor: Colors.transparent,
                  selectedItemBuilder: (BuildContext context) {
                    return options.map<Widget>((item) {
                      return Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          item.label,
                          style: TextStyle(color: t.textPrimary),
                        ),
                      );
                    }).toList();
                  },
                  items: options.map((deletion) {
                    return DropdownMenuItem<PostBackupDeletionEnum>(
                      value: deletion,
                      child: Text(
                        deletion.label,
                        style: TextStyle(color: t.textPrimary),
                      ),
                    );
                  }).toList(),
                  onChanged: (PostBackupDeletionEnum? newValue) {
                    if (newValue != null) {
                      selectedDeletion.value = newValue;
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      actions: [
        const Spacer(),
        AppButton(
          label: 'Cancel',
          onPressed: () => Navigator.pop(context),
          variant: AppButtonVariant.secondary,
        ),
        AppButton(
          label: 'Confirm',
          onPressed: () {
            onConfirm.call(selectedDeletion.value);
            Navigator.pop(context);
          },
          variant: AppButtonVariant.primary,
        ),
      ],
    );
  }
}
