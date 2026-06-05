import 'dart:io' show Directory;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart' show useEffect, useState;
import 'package:hooks_riverpod/hooks_riverpod.dart'
    show HookConsumerWidget, WidgetRef;
import 'package:package_info_plus/package_info_plus.dart' show PackageInfo;
import 'package:tts_mod_vault/src/state/analytics/analytics_service.dart'
    show AnalyticsService;
import 'package:tts_mod_vault/src/mods/components/components.dart'
    show ErrorMessage, MessageProgressIndicator;
import 'package:tts_mod_vault/src/splash/components/select_directories_widget.dart'
    show SelectDirectoriesWidget;
import 'package:tts_mod_vault/src/state/provider.dart'
    show
        appThemeProvider,
        detailPanelExpandedProvider,
        directoriesProvider,
        loaderProvider,
        loadingMessageProvider,
        logPanelHeightProvider,
        modListDensityProvider,
        modListStyleProvider,
        ModListDensity,
        ModListStyle,
        modsProvider,
        settingsProvider,
        storageProvider,
        backupCacheProvider;
import 'package:tts_mod_vault/src/state/storage/storage.dart' show Storage;
import 'package:tts_mod_vault/src/ui/theme/app_theme_id.dart' show AppThemeId;
import 'package:tts_mod_vault/src/utils.dart'
    show checkForUpdatesOnGitHub, showDownloadLatestVersionDialog;
import 'package:window_manager/window_manager.dart' show windowManager;

class SplashPage extends HookConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final directoriesNotifier = ref.watch(directoriesProvider.notifier);
    final loadingMessage = ref.watch(loadingMessageProvider);
    final loaderNotifier = ref.watch(loaderProvider);
    final modsError = ref.watch(modsProvider).error;

    final initialModsDirExists = useState(false);
    final initialSavesDirExists = useState(false);
    final showSelectDirectories = useState(false);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // Small delay as a workaround for Windows Release issue
        await Future.delayed(Duration(milliseconds: 100), () async {
          if (await windowManager.isMaximizable() &&
              !await windowManager.isMaximized()) {
            await windowManager.maximize();
          }
        });

        // Initialize storage, TTS Data Directory and Settings
        await ref.read(storageProvider).initializeStorage();
        await ref.read(backupCacheProvider).initialize();
        await ref.read(settingsProvider.notifier).initializeSettings();
        _applyUiPrefs(ref);
        directoriesNotifier.initializeDirectories();

        final packageInfo = await PackageInfo.fromPlatform();
        AnalyticsService.initAndPing(appVersion: packageInfo.version);

        // Check for updates on start
        if (ref.read(settingsProvider).checkForUpdatesOnStart) {
          final newTagVersion = await checkForUpdatesOnGitHub();

          if (newTagVersion.isNotEmpty) {
            final currentVersion = packageInfo.version;

            if (context.mounted) {
              await showDownloadLatestVersionDialog(
                  context, currentVersion, newTagVersion);
            }
          }
        }

        final modsDir = ref.read(directoriesProvider).modsDir;
        final savesDir = ref.read(directoriesProvider).savesDir;

        final modsDirExists = await Directory(modsDir).exists();
        final savesDirExists = await Directory(savesDir).exists();

        if (modsDirExists && savesDirExists) {
          await loaderNotifier.loadApp(
            () => Navigator.of(context).pushReplacementNamed('/vault'),
          );
        } else {
          initialModsDirExists.value = modsDirExists;
          initialSavesDirExists.value = savesDirExists;
          showSelectDirectories.value = true;
        }
      });
      return null;
    }, []);

    return SafeArea(
      child: Scaffold(
        body: Center(
          child: modsError != null
              ? ErrorMessage(e: modsError)
              : !showSelectDirectories.value
                  ? MessageProgressIndicator(message: loadingMessage)
                  : SelectDirectoriesWidget(
                      initialModsDirExists: initialModsDirExists.value,
                      initialSavesDirExists: initialSavesDirExists.value,
                    ),
        ),
      ),
    );
  }
}


/// Re-applies saved UI preferences after storage has been initialized.
/// Providers start with defaults before storage is ready; this syncs them.
void _applyUiPrefs(WidgetRef ref) {
  final s = ref.read(storageProvider);

  final theme = s.getUiPref(Storage.appThemeIdKey);
  if (theme != null) {
    ref.read(appThemeProvider.notifier).setTheme(
      AppThemeId.values.firstWhere((e) => e.name == theme,
          orElse: () => AppThemeId.purpleDark),
    );
  }

  final height = s.getUiPref(Storage.logPanelHeightKey);
  if (height != null) {
    ref.read(logPanelHeightProvider.notifier).set(
        double.tryParse(height) ?? 280.0);
  }

  final expanded = s.getUiPref(Storage.detailPanelExpandedKey);
  if (expanded != null) {
    ref.read(detailPanelExpandedProvider.notifier).set(expanded == 'true');
  }

  final style = s.getUiPref(Storage.modListStyleKey);
  if (style != null) {
    ref.read(modListStyleProvider.notifier).set(
      ModListStyle.values.firstWhere((e) => e.name == style,
          orElse: () => ModListStyle.richRows),
    );
  }

  final density = s.getUiPref(Storage.modListDensityKey);
  if (density != null) {
    ref.read(modListDensityProvider.notifier).set(
      ModListDensity.values.firstWhere((e) => e.name == density,
          orElse: () => ModListDensity.defaultDensity),
    );
  }
}
