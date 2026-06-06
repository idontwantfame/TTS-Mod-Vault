import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart' show Hive, HiveX;
import 'package:hooks_riverpod/hooks_riverpod.dart' show ProviderScope;
import 'package:package_info_plus/package_info_plus.dart' show PackageInfo;
import 'package:window_manager/window_manager.dart'
    show WindowOptions, windowManager;
import 'src/app.dart' show App;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await Hive.initFlutter('TTS Mod Vault');

  final packageInfo = await PackageInfo.fromPlatform();

  WindowOptions windowOptions = WindowOptions(
    minimumSize: const Size(854, 480),
    title: 'TTS Mod Vault ${packageInfo.version}',
    center: true,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(ProviderScope(child: App()));
}
