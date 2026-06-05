import 'package:file_picker/file_picker.dart' show FilePicker;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart'
    show useMemoized, useState, useTextEditingController;
import 'package:hooks_riverpod/hooks_riverpod.dart'
    show HookConsumerWidget, WidgetRef;
import 'package:path/path.dart' as p;
import 'package:tts_mod_vault/src/state/provider.dart'
    show directoriesProvider, downloadProvider;
import 'package:tts_mod_vault/src/utils.dart' show showSnackBar;
import 'package:tts_mod_vault/src/mods/components/download_results_dialog.dart'
    show showDownloadResultsDialog;
import 'package:tts_mod_vault/src/ui/ui.dart'
    show AppDialog, AppButton, AppTextField, AppButtonVariant;

class DownloadModsDialog extends HookConsumerWidget {
  const DownloadModsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadState = ref.watch(downloadProvider);
    final progress = downloadState.progress;
    final statusMessage = downloadState.statusMessage;

    // Depend only on progress and not boolean in order to not have download progress bar in selected mod view
    final isDownloading = useMemoized(() => progress > 0, [progress]);
    final textController = useTextEditingController();
    final targetDirectory =
        useState(p.normalize(ref.read(directoriesProvider).workshopDir));
    final downloadAssets = useState(true);

    return AppDialog(
      title: 'Download Workshop Mods',
      width: 700,
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          AppTextField(
            controller: textController,
            hintText: 'Mod ID(s) or Workshop URLs, comma-separated',
          ),
          Row(
            children: [
              Checkbox(
                visualDensity: VisualDensity.compact,
                value: downloadAssets.value,
                onChanged: isDownloading
                    ? null
                    : (v) => downloadAssets.value = v ?? true,
                checkColor: Colors.black,
                activeColor: Colors.white,
              ),
              const SizedBox(width: 4),
              const Text('Download all assets after downloading mod'),
            ],
          ),
          Text(
            'Save to: ${targetDirectory.value}',
            style: TextStyle(fontSize: 16),
          ),
          if (isDownloading)
            Column(
              spacing: 4,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (statusMessage != null)
                  Text(statusMessage,
                      style: const TextStyle(fontSize: 13)),
                Stack(
                  children: [
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 24,
                      backgroundColor: Colors.grey.shade300,
                      color: Colors.green,
                      borderRadius: BorderRadius.all(Radius.circular(32)),
                    ),
                    Center(
                      child: Text(
                        '${(progress * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
      actions: [
        AppButton(
          label: 'Select folder',
          onPressed: isDownloading
              ? null
              : () async {
                  String? dir;
                  final initialDirectory = p.normalize(
                      ref.read(directoriesProvider).workshopDir);

                  try {
                    dir = await FilePicker.platform.getDirectoryPath(
                      lockParentWindow: true,
                      initialDirectory: initialDirectory,
                    );
                  } catch (e) {
                    debugPrint("File picker error $e");
                    if (context.mounted) {
                      showSnackBar(
                          context, "Failed to open file picker");
                      Navigator.pop(context);
                    }
                    return;
                  }

                  if (dir == null) return;

                  targetDirectory.value = p.normalize(dir);
                },
          icon: Icon(Icons.folder),
        ),
        const Spacer(),
        AppButton(
          label: 'Cancel',
          onPressed: isDownloading
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          variant: AppButtonVariant.secondary,
        ),
        AppButton(
          label: 'Download',
          onPressed: isDownloading
              ? null
              : () async {
                  final input = textController.text;
                  if (input.isEmpty) return;

                  // Accept Workshop URLs or raw IDs, comma-separated
                  final modIds = input
                      .split(',')
                      .map((s) => _extractModId(s.trim()))
                      .where((id) => id.isNotEmpty)
                      .toList();

                  if (modIds.isEmpty) return;

                  final resultMessage = await ref
                      .read(downloadProvider.notifier)
                      .downloadModsByIds(
                        modIds: modIds,
                        targetDirectory: targetDirectory.value,
                        downloadAssets: downloadAssets.value,
                      );

                  if (context.mounted) {
                    Navigator.of(context).pop();
                    if (resultMessage.isNotEmpty) {
                      showDownloadResultsDialog(
                          context, resultMessage);
                    }
                  }
                },
          icon: Icon(Icons.download),
          variant: AppButtonVariant.primary,
        ),
      ],
    );
  }
}

/// Extracts a Steam Workshop mod ID from either a raw ID string or a
/// Workshop URL such as:
///   https://steamcommunity.com/sharedfiles/filedetails/?id=953770080
String _extractModId(String input) {
  final uri = Uri.tryParse(input);
  if (uri != null && uri.queryParameters.containsKey('id')) {
    return uri.queryParameters['id']!;
  }
  return input;
}
