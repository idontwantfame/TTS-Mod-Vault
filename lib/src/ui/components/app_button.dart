import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart' show ConsumerWidget, WidgetRef;
import 'package:tts_mod_vault/src/state/provider.dart' show appThemeDataProvider;

enum AppButtonVariant { primary, secondary, ghost, danger }

class AppButton extends ConsumerWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final Widget? icon;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.secondary,
    this.icon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appThemeDataProvider);

    final (bg, fg, borderColor) = switch (variant) {
      AppButtonVariant.primary => (t.accent, t.accentText, t.accent),
      AppButtonVariant.secondary => (t.surfaceElevated, t.textPrimary, t.border),
      AppButtonVariant.ghost => (Colors.transparent, t.textSecondary, t.border),
      AppButtonVariant.danger => (
          t.statusError.withValues(alpha: 0.2),
          t.statusError,
          t.statusError
        ),
    };

    final style = ElevatedButton.styleFrom(
      backgroundColor: bg,
      foregroundColor: fg,
      side: BorderSide(color: borderColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    );

    if (icon != null) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        style: style,
        icon: icon!,
        label: Text(label),
      );
    }
    return ElevatedButton(
      onPressed: onPressed,
      style: style,
      child: Text(label),
    );
  }
}
