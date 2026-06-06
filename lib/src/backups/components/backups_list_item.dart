import 'dart:io' show File;

import 'package:flutter/gestures.dart' show kPrimaryButton, kSecondaryButton;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart' show useMemoized, useState;
import 'package:hooks_riverpod/hooks_riverpod.dart'
    show HookConsumerWidget, WidgetRef;
import 'package:path/path.dart' as p;

import 'package:tts_mod_vault/src/ui/ui.dart' show AppCard, AppTooltip;
import 'package:tts_mod_vault/src/state/provider.dart' show appThemeDataProvider;
import 'package:tts_mod_vault/src/state/backup/models/existing_backup_model.dart'
    show ExistingBackup;
import 'package:tts_mod_vault/src/utils.dart'
    show formatTimestamp, showBackupContextMenu;

class BackupsListItem extends HookConsumerWidget {
  final ExistingBackup backup;

  const BackupsListItem({super.key, required this.backup});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appThemeDataProvider);

    final matchingModImagePath = useMemoized(() {
      if (backup.matchingModFilepath == null) return null;
      final jsonPath = backup.matchingModFilepath!;
      if (!jsonPath.toLowerCase().endsWith('.json')) return null;
      return '${jsonPath.substring(0, jsonPath.length - 5)}.png';
    }, [backup.matchingModFilepath]);

    final imageExists = useMemoized(
      () => matchingModImagePath != null
          ? File(matchingModImagePath).existsSync()
          : false,
      [matchingModImagePath],
    );

    final hasMatchingMod = backup.matchingModFilepath != null;

    final backupFilename = useMemoized(
      () => p.basenameWithoutExtension(backup.filename),
      [backup],
    );

    final isHovered = useState(false);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => isHovered.value = true,
      onExit: (_) => isHovered.value = false,
      child: Listener(
        onPointerDown: (event) {
          if (event.buttons == kSecondaryButton ||
              event.buttons == kPrimaryButton) {
            showBackupContextMenu(
              context, ref, event.position, backup, hasMatchingMod,
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: AppCard(
            selected: isHovered.value,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: imageExists
                      ? Image.file(
                          File(matchingModImagePath!),
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 40,
                          height: 40,
                          color: t.surfaceElevated,
                          child: Icon(
                            Icons.folder_zip_outlined,
                            size: 24,
                            color: t.textMuted,
                          ),
                        ),
                ),
                const SizedBox(width: 10),
                // Name + meta
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        backupFilename,
                        style: TextStyle(
                          color: t.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${backup.totalAssetCount} assets · ${backup.fileSizeMB} · ${formatTimestamp(backup.lastModifiedTimestamp.toString())}',
                        style: TextStyle(color: t.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Import status badge
                AppTooltip(
                  message:
                      '${hasMatchingMod ? "Matching mod found" : "No matching mod"}\n${backup.fileSizeMB}\n${backup.totalAssetCount} asset files\n${formatTimestamp(backup.lastModifiedTimestamp.toString())}',
                  child: Icon(
                    hasMatchingMod ? Icons.link : Icons.link_off,
                    size: 16,
                    color: hasMatchingMod ? Colors.green : t.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
