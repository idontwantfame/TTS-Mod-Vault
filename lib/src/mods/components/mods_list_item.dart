import 'package:flutter/gestures.dart'
    show PointerDeviceKind, kPrimaryButton, kSecondaryButton;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HardwareKeyboard;
import 'package:flutter_hooks/flutter_hooks.dart' show useMemoized;
import 'package:hooks_riverpod/hooks_riverpod.dart'
    show HookConsumerWidget, WidgetRef;
import 'package:tts_mod_vault/src/mods/components/mod_thumbnail.dart'
    show ModThumbnail;
import 'package:tts_mod_vault/src/state/backup/backup_status_enum.dart'
    show ExistingBackupStatusEnum;
import 'package:tts_mod_vault/src/state/mods/mod_model.dart'
    show Mod;
import 'package:tts_mod_vault/src/state/provider.dart'
    show
        actionInProgressProvider,
        appThemeDataProvider,
        detailPanelExpandedProvider,
        modListDensityProvider,
        ModListDensity,
        modsProvider,
        multiModsProvider;
import 'package:tts_mod_vault/src/ui/ui.dart'
    show AppBadge, AppBadgeVariant, AppCard, AppTooltip, TooltipStrings;
import 'package:tts_mod_vault/src/utils.dart' show showModContextMenu;

class ModsListItem extends HookConsumerWidget {
  final Mod mod;

  const ModsListItem({super.key, required this.mod});

  double _densityPadding(WidgetRef ref) {
    final density = ref.watch(modListDensityProvider);
    return switch (density) {
      ModListDensity.compact => 6.0,
      ModListDensity.defaultDensity => 10.0,
      ModListDensity.comfortable => 14.0,
    };
  }

  Widget _modBadge(Mod mod) {
    if (mod.missingAssetCount > 0) {
      return AppBadge(
        label: '${mod.missingAssetCount} missing',
        variant: AppBadgeVariant.error,
      );
    }
    if (mod.backupStatus == ExistingBackupStatusEnum.upToDate) {
      return const AppBadge(label: '✓ backed up', variant: AppBadgeVariant.ok);
    }
    if (mod.assetCount > 0) {
      return const AppBadge(
          label: '✓ all assets', variant: AppBadgeVariant.ok);
    }
    return const AppBadge(label: 'no assets', variant: AppBadgeVariant.neutral);
  }

  String _relativeDate(int? msEpoch) {
    if (msEpoch == null) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(msEpoch);
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return 'today';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appThemeDataProvider);
    final multiSelectMods = ref.watch(multiModsProvider);

    final isSelected = useMemoized(() {
      return multiSelectMods.contains(mod.jsonFilePath);
    }, [multiSelectMods, mod]);

    return Listener(
      onPointerDown: (event) {
        if (ref.read(actionInProgressProvider)) {
          return;
        }

        final isCtrlPressed = event.kind == PointerDeviceKind.mouse &&
            (event.buttons == kPrimaryButton) &&
            (HardwareKeyboard.instance.isControlPressed ||
                HardwareKeyboard.instance.isMetaPressed);

        if (event.buttons == kSecondaryButton) {
          // Right-click
          ref.read(modsProvider.notifier).setSelectedMod(mod);
          showModContextMenu(context, ref, event.position, mod);
        } else if (event.buttons == kPrimaryButton) {
          // Left-click
          if (isCtrlPressed) {
            // Ctrl+Click: Toggle multi-selection
            final currentSelected = ref.read(multiModsProvider);
            final newSelected = Set<String>.from(currentSelected);

            if (newSelected.contains(mod.jsonFilePath)) {
              newSelected.remove(mod.jsonFilePath);
            } else {
              newSelected.add(mod.jsonFilePath);
            }

            ref.read(multiModsProvider.notifier).state = newSelected;
          } else {
            // Normal left-click: Single selection
            ref.read(modsProvider.notifier).setSelectedMod(mod);
            ref.read(detailPanelExpandedProvider.notifier).set(true);
          }
        }
      },
      child: AppCard(
        selected: isSelected,
        padding: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: _densityPadding(ref),
        ),
        child: Row(
          children: [
            ModThumbnail(imagePath: mod.imageFilePath, size: 32),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    mod.saveName,
                    style: TextStyle(
                      color: t.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${mod.assetCount} assets · ${_relativeDate(mod.lastModifiedTimestamp)}',
                    style: TextStyle(color: t.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AppTooltip(
              message: mod.missingAssetCount > 0
                  ? TooltipStrings.badgeMissing
                  : mod.backupStatus == ExistingBackupStatusEnum.upToDate
                      ? TooltipStrings.badgeBacked
                      : mod.assetCount > 0
                          ? TooltipStrings.badgeAllAssets
                          : TooltipStrings.badgeNoAssets,
              child: _modBadge(mod),
            ),
          ],
        ),
      ),
    );
  }
}
