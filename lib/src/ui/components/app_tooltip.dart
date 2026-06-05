import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart' show ConsumerWidget, WidgetRef;
import 'package:tts_mod_vault/src/state/provider.dart' show appThemeDataProvider;

enum AppTooltipTier { standard, complex }

class AppTooltip extends ConsumerWidget {
  final String message;
  final Widget child;
  final AppTooltipTier tier;

  const AppTooltip({
    super.key,
    required this.message,
    required this.child,
    this.tier = AppTooltipTier.standard,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appThemeDataProvider);

    return Tooltip(
      message: message,
      preferBelow: false,
      waitDuration: Duration(milliseconds: tier == AppTooltipTier.complex ? 750 : 500),
      showDuration: Duration(seconds: tier == AppTooltipTier.complex ? 5 : 3),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border.all(color: t.border),
        borderRadius: BorderRadius.circular(4),
      ),
      textStyle: TextStyle(color: t.textSecondary, fontSize: 12),
      child: child,
    );
  }
}
