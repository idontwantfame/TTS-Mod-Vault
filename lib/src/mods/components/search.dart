import 'dart:async' show Timer;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart'
    show useEffect, useFocusNode, useRef, useState, useTextEditingController;
import 'package:hooks_riverpod/hooks_riverpod.dart'
    show HookConsumerWidget, StateProvider, WidgetRef;
import 'package:tts_mod_vault/src/state/provider.dart'
    show actionInProgressProvider, appThemeDataProvider, selectedModTypeProvider;
import 'package:tts_mod_vault/src/ui/ui.dart' show AppTooltip, TooltipStrings;

class Search extends HookConsumerWidget {
  final StateProvider<String> searchQueryProvider;

  const Search({super.key, required this.searchQueryProvider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedModType = ref.watch(selectedModTypeProvider);
    final t = ref.watch(appThemeDataProvider);
    final controller = useTextEditingController();
    final focusNode = useFocusNode();
    final debounceTimer = useRef<Timer?>(null);
    final isExpanded = useState(false);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.clear();
        isExpanded.value = false;
      });
      return null;
    }, [selectedModType]);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final query = ref.read(searchQueryProvider);
        controller.text = query;
        if (query.isNotEmpty) isExpanded.value = true;
      });
      return null;
    }, []);

    useEffect(() {
      return () {
        debounceTimer.value?.cancel();
      };
    }, []);

    useEffect(() {
      void onFocusChange() {
        if (!focusNode.hasFocus && controller.text.isEmpty) {
          isExpanded.value = false;
        }
      }

      focusNode.addListener(onFocusChange);
      return () => focusNode.removeListener(onFocusChange);
    }, []);

    void onSearchChanged(String value) {
      if (ref.read(actionInProgressProvider)) return;

      debounceTimer.value?.cancel();

      debounceTimer.value = Timer(const Duration(milliseconds: 500), () {
        ref.read(searchQueryProvider.notifier).state = value;
      });
    }

    return isExpanded.value
        ? SizedBox(
            width: 300,
            height: 32,
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: true,
              onChanged: onSearchChanged,
              cursorColor: t.accent,
              style: TextStyle(color: t.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                prefixIcon: Icon(Icons.search, color: t.textMuted, size: 18),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear, color: t.textMuted, size: 16),
                  onPressed: () {
                    controller.clear();
                    debounceTimer.value?.cancel();
                    ref.read(searchQueryProvider.notifier).state = '';
                    isExpanded.value = false;
                  },
                ),
                hintText: 'Search…',
                hintStyle: TextStyle(color: t.textMuted, fontSize: 13),
                filled: true,
                fillColor: t.surfaceElevated,
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
            ),
          )
        : AppTooltip(
            message: TooltipStrings.toolbarSearch,
            child: GestureDetector(
              onTap: () {
                isExpanded.value = true;
                focusNode.requestFocus();
              },
              child: Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  color: t.surfaceElevated,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: t.border),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.search, size: 16, color: t.textSecondary),
              ),
            ),
          );
  }
}
