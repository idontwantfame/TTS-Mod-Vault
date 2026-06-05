import 'dart:io' show File;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart' show ConsumerWidget, WidgetRef;
import 'package:tts_mod_vault/src/state/provider.dart' show appThemeDataProvider;

class ModThumbnail extends ConsumerWidget {
  final String? imagePath;
  final double size;

  const ModThumbnail({super.key, this.imagePath, this.size = 32});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appThemeDataProvider);
    final hasImage = imagePath != null && File(imagePath!).existsSync();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: t.surfaceElevated,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: t.border),
      ),
      clipBehavior: Clip.hardEdge,
      child: hasImage
          ? Image.file(File(imagePath!), fit: BoxFit.cover)
          : Icon(Icons.extension, size: size * 0.55, color: t.textMuted),
    );
  }
}
