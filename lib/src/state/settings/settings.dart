import 'dart:convert' show json;

import 'package:flutter/material.dart' show debugPrint;
import 'package:hooks_riverpod/hooks_riverpod.dart' show Ref, StateNotifier;
import 'package:tts_mod_vault/src/state/provider.dart'
    show downloadProvider, logProvider, storageProvider;
import 'package:tts_mod_vault/src/state/settings/settings_state.dart'
    show SettingsState;

class SettingsNotifier extends StateNotifier<SettingsState> {
  final Ref ref;

  SettingsNotifier(this.ref) : super(SettingsState.defaultState());

  Future<void> initializeSettings() async {
    final settingsJson = ref.read(storageProvider).getSettings();

    SettingsState newState = SettingsState.defaultState();

    if (settingsJson != null) {
      try {
        newState = SettingsState.fromJson(settingsJson);
        debugPrint('Loaded settings from json');
      } catch (e) {
        debugPrint('Failed to load settings from json: $e');
        ref.read(logProvider.notifier).addWarning(
            'Failed to load saved settings, using defaults: $e');
        newState = SettingsState.defaultState();
      }
    }

    debugPrint('initializeSettings - ${json.encode(newState.toJson())}');
    saveSettings(newState);
  }

  Future<void> saveSettings(SettingsState newState) async {
    final proxyChanged = state.proxyUrl != newState.proxyUrl;
    state = newState;
    await ref.read(storageProvider).saveSettings(newState);

    // Re-apply proxy to the Dio client whenever it changes
    if (proxyChanged) {
      ref.read(downloadProvider.notifier).updateProxySettings();
    }
  }

  Future<void> resetToDefaultSettings() async {
    ref.read(logProvider.notifier).addInfo('Settings reset to defaults');
    await saveSettings(SettingsState.defaultState());
  }
}
