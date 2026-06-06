import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart' show ConsumerWidget, WidgetRef;
import 'package:tts_mod_vault/src/state/provider.dart' show appThemeDataProvider;

class MessageProgressIndicator extends ConsumerWidget {
  final bool showCircularIndicator;
  final String message;

  const MessageProgressIndicator({
    super.key,
    this.showCircularIndicator = true,
    required this.message,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appThemeDataProvider);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 8,
      children: [
        if (showCircularIndicator)
          CircularProgressIndicator(
            color: t.accent,
            constraints: BoxConstraints(minHeight: 50, minWidth: 50),
            strokeWidth: 6,
          ),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
