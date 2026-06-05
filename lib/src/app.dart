import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart' show ConsumerWidget, WidgetRef;
import 'package:tts_mod_vault/src/mods/images_viewer_page.dart' show ImagesViewerPage;
import 'package:tts_mod_vault/src/splash/splash_page.dart' show SplashPage;
import 'package:tts_mod_vault/src/mods/vault.dart' show Vault;
import 'package:tts_mod_vault/src/state/provider.dart'
    show appThemeDataProvider, appThemePersistProvider, uiPrefPersistProvider;

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(appThemeDataProvider);
    ref.watch(appThemePersistProvider);
    ref.watch(uiPrefPersistProvider);

    return MaterialApp(
      title: 'TTS Mod Vault',
      darkTheme: themeData.toMaterialTheme(),
      themeMode: ThemeMode.dark,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/vault': (context) => const Vault(),
        '/images-viewer': (context) => const ImagesViewerPage(),
      },
    );
  }
}
