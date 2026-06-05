import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart'
    show ConsumerWidget, WidgetRef;
import 'package:tts_mod_vault/src/state/provider.dart'
    show appThemeDataProvider, detailPanelExpandedProvider;
import 'package:tts_mod_vault/src/ui/ui.dart' show AppTooltip;

class SlimTab extends ConsumerWidget {
  const SlimTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appThemeDataProvider);

    return AppTooltip(
      message: 'Click to show mod details',
      child: GestureDetector(
        onTap: () => ref.read(detailPanelExpandedProvider.notifier).state = !ref.read(detailPanelExpandedProvider),
        child: Container(
          width: 28,
          decoration: BoxDecoration(
            color: t.surface,
            border: Border(left: BorderSide(color: t.border)),
          ),
          child: Center(
            child: RotatedBox(
              quarterTurns: 3,
              child: Text(
                'DETAILS ›',
                style: TextStyle(
                  color: t.textMuted,
                  fontSize: 10,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
