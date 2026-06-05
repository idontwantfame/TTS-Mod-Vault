import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show TextInputFormatter;
import 'package:hooks_riverpod/hooks_riverpod.dart' show ConsumerWidget, WidgetRef;
import 'package:tts_mod_vault/src/state/provider.dart' show appThemeDataProvider;

export 'package:flutter/services.dart' show TextInputFormatter;

class AppTextField extends ConsumerWidget {
  final TextEditingController controller;
  final String? hintText;
  final String? labelText;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final bool obscureText;

  const AppTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.labelText,
    this.focusNode,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appThemeDataProvider);

    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      obscureText: obscureText,
      cursorColor: t.accent,
      style: TextStyle(color: t.textPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        hintStyle: TextStyle(color: t.textMuted),
        labelStyle: TextStyle(color: t.textSecondary),
        fillColor: t.surfaceElevated,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: t.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: t.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: t.accent, width: 1.5),
        ),
      ),
    );
  }
}
