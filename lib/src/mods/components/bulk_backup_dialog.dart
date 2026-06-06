import 'package:file_picker/file_picker.dart' show FilePicker;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart' show useState;
import 'package:hooks_riverpod/hooks_riverpod.dart'
    show HookConsumerWidget, WidgetRef;
import 'package:tts_mod_vault/src/state/bulk_actions/bulk_actions_state.dart'
    show BulkBackupBehaviorEnum, PostBackupDeletionEnum;
import 'package:tts_mod_vault/src/state/provider.dart'
    show appThemeDataProvider, directoriesProvider, settingsProvider;
import 'package:tts_mod_vault/src/ui/ui.dart'
    show AppDialog, AppButton, AppButtonVariant;

class BulkBackupDialog extends HookConsumerWidget {
  final String title;
  final BulkBackupBehaviorEnum initialBehavior;
  final Function(
    BulkBackupBehaviorEnum behavior,
    String folder,
    PostBackupDeletionEnum postBackupDeletion,
  ) onConfirm;

  const BulkBackupDialog({
    super.key,
    required this.title,
    required this.initialBehavior,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backupsDir = ref.watch(directoriesProvider).backupsDir;
    final showBackupState = ref.watch(settingsProvider).showBackupState;
    final t = ref.watch(appThemeDataProvider);
    final selectedBehavior = useState(initialBehavior);
    final selectedFolder = useState(ref.read(directoriesProvider).backupsDir);
    final selectedPostBackupDeletion = useState(PostBackupDeletionEnum.none);

    return AppDialog(
      width: 500,
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
                  child: Text('If backup already exists:'),
                ),
                DropdownButton<BulkBackupBehaviorEnum>(
                  value: selectedBehavior.value,
                  dropdownColor: t.surface,
                  style: TextStyle(color: t.textPrimary),
                  underline: Container(
                    height: 2,
                    color: t.border,
                  ),
                  focusColor: Colors.transparent,
                  selectedItemBuilder: (BuildContext context) {
                    return BulkBackupBehaviorEnum.values.map<Widget>((item) {
                      return Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          item.label,
                          style: TextStyle(color: t.textPrimary),
                        ),
                      );
                    }).toList();
                  },
                  items: BulkBackupBehaviorEnum.values.map((behavior) {
                    return DropdownMenuItem<BulkBackupBehaviorEnum>(
                      value: behavior,
                      child: Text(
                        behavior.label,
                        style: TextStyle(color: t.textPrimary),
                      ),
                    );
                  }).toList(),
                  onChanged: (BulkBackupBehaviorEnum? newValue) {
                    if (newValue != null) {
                      selectedBehavior.value = newValue;
                    }
                  },
                ),
              ],
            ),
            Row(
              spacing: 8,
              children: [
                const Expanded(
                  child: Text('After backup:'),
                ),
                DropdownButton<PostBackupDeletionEnum>(
                  value: selectedPostBackupDeletion.value,
                  dropdownColor: t.surface,
                  style: TextStyle(color: t.textPrimary),
                  underline: Container(
                    height: 2,
                    color: t.border,
                  ),
                  focusColor: Colors.transparent,
                  selectedItemBuilder: (BuildContext context) {
                    return PostBackupDeletionEnum.values.map<Widget>((item) {
                      return Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          item.label,
                          style: TextStyle(color: t.textPrimary),
                        ),
                      );
                    }).toList();
                  },
                  items: PostBackupDeletionEnum.values.map((deletion) {
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
                      selectedPostBackupDeletion.value = newValue;
                    }
                  },
                ),
              ],
            ),
            if (backupsDir.isEmpty && showBackupState)
              Row(
                spacing: 8,
                children: [
                  Icon(Icons.warning_amber_rounded),
                  Text(
                      "Set a backup folder in Settings to show backup state after a restart or data refresh\nOr disable Backup State feature in Settings to hide this warning"),
                ],
              ),
            Text('Save new backups to: ${selectedFolder.value}'),
          ],
        ),
      actions: [
        AppButton(
          label: 'Select folder',
          onPressed: () async {
            String? folder = await FilePicker.platform.getDirectoryPath(
              lockParentWindow: true,
              initialDirectory: backupsDir.isEmpty ? null : backupsDir,
            );
            if (folder != null) {
              selectedFolder.value = folder;
            }
          },
          icon: Icon(Icons.folder),
        ),
        const Spacer(),
        AppButton(
          label: 'Cancel',
          onPressed: () => Navigator.pop(context),
          variant: AppButtonVariant.secondary,
        ),
        AppButton(
          label: 'Confirm',
          onPressed: selectedFolder.value.isEmpty
              ? null
              : () {
                  onConfirm.call(
                    selectedBehavior.value,
                    selectedFolder.value,
                    selectedPostBackupDeletion.value,
                  );
                  Navigator.pop(context);
                },
          variant: AppButtonVariant.primary,
        ),
      ],
    );
  }
}
