import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart' show ConsumerWidget, WidgetRef;
import 'package:tts_mod_vault/src/state/provider.dart' show appThemeDataProvider;

enum AppBadgeVariant { ok, warn, error, info, neutral }

class AppBadge extends ConsumerWidget {
  final String label;
  final AppBadgeVariant variant;

  const AppBadge({super.key, required this.label, required this.variant});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appThemeDataProvider);

    final color = switch (variant) {
      AppBadgeVariant.ok => t.statusOk,
      AppBadgeVariant.warn => t.statusWarn,
      AppBadgeVariant.error => t.statusError,
      AppBadgeVariant.info => t.statusInfo,
      AppBadgeVariant.neutral => t.textMuted,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w500),
      ),
    );
  }
}
