import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart'
    show ConsumerWidget, WidgetRef;
import 'package:tts_mod_vault/src/mods/components/components.dart'
    show DownloadModsDialog;
import 'package:tts_mod_vault/src/state/provider.dart'
    show
        actionInProgressProvider,
        appThemeDataProvider,
        cleanupProvider,
        loaderProvider,
        settingsProvider;
import 'package:tts_mod_vault/src/utils.dart'
    show showConfirmDialog, showSnackBar;

class ToolsMenu extends ConsumerWidget {
  const ToolsMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionInProgress = ref.watch(actionInProgressProvider);
    final cleanupNotifier = ref.watch(cleanupProvider.notifier);
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
          onPressed: () async {
            await cleanupNotifier.startCleanup(
              (count) {
                if (count > 0) {
                  final itemTypes = ref.read(settingsProvider).showSavedObjects
                      ? "mods, saves and saved objects"
                      : "mods and saves";

                  showConfirmDialog(
                    context,
                    '$count files found that are not used by any of your $itemTypes.\nAre you sure you want to delete them?',
                    () async {
                      await cleanupNotifier.executeDelete();
                    },
                    () {
                      cleanupNotifier.resetState();
                    },
                  );
                } else {
                  showSnackBar(context, 'No files found to delete');
                }
              },
            );
          },
          leadingIcon: Icon(Icons.delete_sweep, color: t.textPrimary),
          child: Text(
            'Clean up unused files',
            style: TextStyle(color: t.textPrimary),
          ),
        ),
        MenuItemButton(
          style: MenuItemButton.styleFrom(
            backgroundColor: t.surface,
            foregroundColor: t.textPrimary,
          ),
          onPressed: () {
            showConfirmDialog(
              context,
              'This will clear the Vault\'s cache and reload mod information from your files.\n\nYour downloaded asset files will not be affected.\n\nContinue?',
              () async => await ref.read(loaderProvider).refreshAppData(true),
            );
          },
          leadingIcon: Icon(
            Icons.refresh,
            color: t.textPrimary,
          ),
          child: Text(
            'Clear Vault cache',
            style: TextStyle(color: t.textPrimary),
          ),
        ),
        MenuItemButton(
          style: MenuItemButton.styleFrom(
            backgroundColor: t.surface,
            foregroundColor: t.textPrimary,
          ),
          onPressed: () => showDialog(
            context: context,
            builder: (context) => DownloadModsDialog(),
          ),
          leadingIcon: Icon(
            Icons.download,
            color: t.textPrimary,
          ),
          child: Text('Download Workshop Mods',
              style: TextStyle(
                color: t.textPrimary,
              )),
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
          label: Text('Tools'),
          icon: Icon(Icons.build),
        );
      },
    );
  }
}
