import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart'
    show HookConsumerWidget, WidgetRef;
import 'package:tts_mod_vault/src/backups/backups_page.dart' show BackupsPage;
import 'package:tts_mod_vault/src/mods/components/top_nav_bar.dart'
    show TopNavBar;
import 'package:tts_mod_vault/src/mods/mods_page.dart' show ModsPage;
import 'package:tts_mod_vault/src/state/provider.dart'
    show AppPage, selectedPageProvider;
import 'package:tts_mod_vault/src/mods/hooks/hooks.dart'
    show useCleanupSnackbar, useBackupSnackbar;

class Vault extends HookConsumerWidget {
  const Vault({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPage = ref.watch(selectedPageProvider);

    useCleanupSnackbar(context, ref);
    useBackupSnackbar(context, ref);

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            const TopNavBar(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: selectedPage == AppPage.mods
                    ? const ModsPage(key: ValueKey(AppPage.mods))
                    : const BackupsPage(key: ValueKey(AppPage.backups)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
