import 'package:flutter/material.dart'
    show
        Border,
        BorderRadius,
        BoxDecoration,
        BuildContext,
        InlineSpan,
        StatelessWidget,
        TextStyle,
        Theme,
        Tooltip,
        Widget;
import 'package:hooks_riverpod/hooks_riverpod.dart' show ProviderScope;
import 'package:tts_mod_vault/src/state/provider.dart' show appThemeDataProvider;

class CustomTooltip extends StatelessWidget {
  final String? message;
  final TextStyle? messageTextStyle;
  final InlineSpan? richMessage;
  final Widget? child;
  final Duration? waitDuration;

  const CustomTooltip({
    super.key,
    this.message,
    this.messageTextStyle,
    this.richMessage,
    this.child,
    this.waitDuration,
  });

  @override
  Widget build(BuildContext context) {
    final t = ProviderScope.containerOf(context).read(appThemeDataProvider);
    return Tooltip(
      waitDuration: waitDuration,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border.all(color: t.border, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: richMessage == null
          ? (messageTextStyle ?? TextStyle(fontSize: 16))
          : null,
      message: message,
      richMessage: richMessage,
      child: child,
    );
  }
}
