import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart'
    show ConsumerWidget, WidgetRef;
import 'package:tts_mod_vault/src/state/provider.dart' show appThemeDataProvider;
import 'package:package_info_plus/package_info_plus.dart' show PackageInfo;
import 'package:tts_mod_vault/src/changelog.dart' show showChangelogDialog;
import 'package:tts_mod_vault/src/utils.dart'
    show
        checkForUpdatesOnGitHub,
        showDownloadLatestVersionDialog,
        showSnackBar,
        openUrl,
        steamDiscussionUrl;

class HelpMenu extends ConsumerWidget {
  const HelpMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          leadingIcon: Icon(Icons.update, color: t.textPrimary),
          child:
              Text('Check for updates', style: TextStyle(color: t.textPrimary)),
          onPressed: () async {
            final newTagVersion = await checkForUpdatesOnGitHub();

            if (newTagVersion.isNotEmpty) {
              final packageInfo = await PackageInfo.fromPlatform();
              final currentVersion = packageInfo.version;

              if (!context.mounted) return;

              await showDownloadLatestVersionDialog(
                  context, currentVersion, newTagVersion);
            } else {
              if (context.mounted) {
                showSnackBar(context, 'No new updates found');
              }
            }
          },
        ),
        MenuItemButton(
          style: MenuItemButton.styleFrom(
            backgroundColor: t.surface,
            foregroundColor: t.textPrimary,
          ),
          onPressed: () => showChangelogDialog(context),
          leadingIcon: Icon(Icons.article, color: t.textPrimary),
          child: Text('Changelog', style: TextStyle(color: t.textPrimary)),
        ),
        MenuItemButton(
          style: MenuItemButton.styleFrom(
            backgroundColor: t.surface,
            foregroundColor: t.textPrimary,
          ),
          leadingIcon: Icon(Icons.help_outline, color: t.textPrimary),
          child: Text('Help & Feedback', style: TextStyle(color: t.textPrimary)),
          onPressed: () async {
            final result = await openUrl(steamDiscussionUrl);
            if (!result && context.mounted) {
              showSnackBar(context, "Failed to open: $steamDiscussionUrl");
            }
          },
        ),
      ],
      builder: (
        BuildContext context,
        MenuController controller,
        Widget? child,
      ) {
        return ElevatedButton.icon(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          label: Text('Help'),
          icon: Icon(Icons.help_outline),
        );
      },
    );
  }
}
