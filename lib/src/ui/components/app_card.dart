import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart' show ConsumerWidget, WidgetRef;
import 'package:tts_mod_vault/src/state/provider.dart' show appThemeDataProvider;

class AppCard extends ConsumerWidget {
  final Widget child;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onSecondaryTap;
  final EdgeInsets padding;

  const AppCard({
    super.key,
    required this.child,
    this.selected = false,
    this.onTap,
    this.onSecondaryTap,
    this.padding = const EdgeInsets.all(10),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appThemeDataProvider);

    return GestureDetector(
      onTap: onTap,
      onSecondaryTap: onSecondaryTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: padding,
        decoration: BoxDecoration(
          color: selected ? t.accentMuted : t.surface,
          border: Border.all(
            color: selected ? t.borderHighlight : t.border,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: child,
      ),
    );
  }
}
