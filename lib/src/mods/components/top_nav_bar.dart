import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart'
    show AsyncValueX, ConsumerWidget, WidgetRef;
import 'package:tts_mod_vault/src/state/mods/mod_model.dart' show ModTypeEnum;
import 'package:tts_mod_vault/src/state/provider.dart'
    show
        AppPage,
        appThemeDataProvider,
        directoriesProvider,
        modsProvider,
        selectedModTypeProvider,
        selectedPageProvider,
        settingsProvider;
import 'package:tts_mod_vault/src/settings/settings_dialog.dart'
    show SettingsDialog;
import 'package:tts_mod_vault/src/help_dialog.dart' show showHelpDialog;
import 'package:tts_mod_vault/src/ui/ui.dart';

class TopNavBar extends ConsumerWidget {
  const TopNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appThemeDataProvider);
    final selectedPage = ref.watch(selectedPageProvider);
    final selectedModType = ref.watch(selectedModTypeProvider);
    final modsState = ref.watch(modsProvider).valueOrNull;
    final backupsDir = ref.watch(directoriesProvider).backupsDir;
    final showSavedObjects = ref.watch(settingsProvider).showSavedObjects;

    final modsCount = modsState?.mods.length ?? 0;
    final savesCount = modsState?.saves.length ?? 0;
    final savedObjectsCount = modsState?.savedObjects.length ?? 0;

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(bottom: BorderSide(color: t.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // App name
          Text(
            'TTS Mod Vault',
            style: TextStyle(
              color: t.accent,
              fontWeight: FontWeight.w700,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 16),
          // Type tabs (Mods / Saves / SavedObjects) — only on Mods page
          if (selectedPage == AppPage.mods) ...[
            _TypeTab(
              label: 'Mods',
              count: modsCount,
              active: selectedModType == ModTypeEnum.mod,
              onTap: () => ref.read(selectedModTypeProvider.notifier).state =
                  ModTypeEnum.mod,
            ),
            const SizedBox(width: 4),
            _TypeTab(
              label: 'Saves',
              count: savesCount,
              active: selectedModType == ModTypeEnum.save,
              onTap: () => ref.read(selectedModTypeProvider.notifier).state =
                  ModTypeEnum.save,
            ),
            if (showSavedObjects) ...[
              const SizedBox(width: 4),
              _TypeTab(
                label: 'Saved Objects',
                count: savedObjectsCount,
                active: selectedModType == ModTypeEnum.savedObject,
                onTap: () =>
                    ref.read(selectedModTypeProvider.notifier).state =
                        ModTypeEnum.savedObject,
              ),
            ],
          ],
          // Backups page tab
          if (backupsDir.isNotEmpty) ...[
            const SizedBox(width: 4),
            _TypeTab(
              label: 'Backups',
              count: null,
              active: selectedPage == AppPage.backups,
              onTap: () =>
                  ref.read(selectedPageProvider.notifier).state =
                      AppPage.backups,
            ),
          ],
          const Spacer(),
          // Settings & Help only on the right
          AppTooltip(
            message: TooltipStrings.navSettings,
            child: _NavButton(
              icon: Icons.settings,
              onPressed: () => showDialog(
                context: context,
                builder: (ctx) => const SettingsDialog(),
              ),
            ),
          ),
          const SizedBox(width: 4),
          AppTooltip(
            message: TooltipStrings.navHelp,
            child: _NavButton(
              icon: Icons.help_outline_rounded,
              onPressed: () => showHelpDialog(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeTab extends ConsumerWidget {
  final String label;
  final int? count;
  final bool active;
  final VoidCallback onTap;

  const _TypeTab({
    required this.label,
    required this.count,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appThemeDataProvider);
    final displayLabel = count != null ? '$label ($count)' : label;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: active ? t.accentMuted : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: active ? t.borderHighlight : Colors.transparent,
          ),
        ),
        child: Text(
          displayLabel,
          style: TextStyle(
            color: active ? t.accent : t.textSecondary,
            fontSize: 12,
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _NavButton extends ConsumerWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _NavButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appThemeDataProvider);
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Icon(icon, size: 18, color: t.textSecondary),
      ),
    );
  }
}
