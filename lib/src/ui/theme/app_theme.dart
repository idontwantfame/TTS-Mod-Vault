import 'package:flutter/material.dart';
import 'app_theme_id.dart';

class AppThemeData {
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color border;
  final Color borderHighlight;
  final Color accent;
  final Color accentMuted;
  final Color accentText;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color statusOk;
  final Color statusWarn;
  final Color statusError;
  final Color statusInfo;

  const AppThemeData({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.border,
    required this.borderHighlight,
    required this.accent,
    required this.accentMuted,
    required this.accentText,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.statusOk,
    required this.statusWarn,
    required this.statusError,
    required this.statusInfo,
  });

  // Purple Dark palette
  static const AppThemeData purpleDark = AppThemeData(
    background: Color(0xFF141218),
    surface: Color(0xFF100e18),
    surfaceElevated: Color(0xFF1a1625),
    border: Color(0xFF2a2535),
    borderHighlight: Color(0xFF4a3575),
    accent: Color(0xFFa78bfa),
    accentMuted: Color(0xFF2d1f4a),
    accentText: Color(0xFF0d0b14),
    textPrimary: Color(0xFFe2e0e8),
    textSecondary: Color(0xFF9b98a8),
    textMuted: Color(0xFF4b4060),
    statusOk: Color(0xFF22c55e),
    statusWarn: Color(0xFFf59e0b),
    statusError: Color(0xFFef4444),
    statusInfo: Color(0xFFa78bfa),
  );

  // Blue Slate palette
  static const AppThemeData blueSlate = AppThemeData(
    background: Color(0xFF0f1117),
    surface: Color(0xFF111827),
    surfaceElevated: Color(0xFF1a2030),
    border: Color(0xFF1e2533),
    borderHighlight: Color(0xFF2d4a7a),
    accent: Color(0xFF60a5fa),
    accentMuted: Color(0xFF1e3a5f),
    accentText: Color(0xFF050d1a),
    textPrimary: Color(0xFFe2e8f0),
    textSecondary: Color(0xFF94a3b8),
    textMuted: Color(0xFF475569),
    statusOk: Color(0xFF22c55e),
    statusWarn: Color(0xFFf59e0b),
    statusError: Color(0xFFef4444),
    statusInfo: Color(0xFF60a5fa),
  );

  // Black Teal palette
  static const AppThemeData blackTeal = AppThemeData(
    background: Color(0xFF0d0d0d),
    surface: Color(0xFF111111),
    surfaceElevated: Color(0xFF161616),
    border: Color(0xFF1a1a1a),
    borderHighlight: Color(0xFF2dd4bf),
    accent: Color(0xFF2dd4bf),
    accentMuted: Color(0xFF1a3030),
    accentText: Color(0xFF030d0d),
    textPrimary: Color(0xFFe5e5e5),
    textSecondary: Color(0xFF888888),
    textMuted: Color(0xFF444444),
    statusOk: Color(0xFF22c55e),
    statusWarn: Color(0xFFf59e0b),
    statusError: Color(0xFFef4444),
    statusInfo: Color(0xFF2dd4bf),
  );

  static AppThemeData forId(AppThemeId id) => switch (id) {
        AppThemeId.purpleDark => purpleDark,
        AppThemeId.blueSlate => blueSlate,
        AppThemeId.blackTeal => blackTeal,
      };

  ThemeData toMaterialTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: accent,
      colorScheme: ColorScheme.dark(
        primary: accent,
        surface: surface,
        error: statusError,
        onPrimary: accentText,
        onSurface: textPrimary,
        onError: textPrimary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: accentText,
          disabledBackgroundColor: accentMuted,
          disabledForegroundColor: textMuted,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: BorderSide(color: borderHighlight),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: accent),
        ),
        hintStyle: TextStyle(color: textMuted),
        labelStyle: TextStyle(color: textSecondary),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: surface,
        selectedIconTheme: IconThemeData(color: accent),
        unselectedIconTheme: IconThemeData(color: textMuted),
        selectedLabelTextStyle: TextStyle(color: accent),
        unselectedLabelTextStyle: TextStyle(color: textMuted),
        indicatorColor: accentMuted,
      ),
      dividerColor: border,
      cardColor: surfaceElevated,
      iconTheme: IconThemeData(color: textSecondary),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: textPrimary),
        bodyMedium: TextStyle(color: textPrimary),
        bodySmall: TextStyle(color: textSecondary),
        labelLarge: TextStyle(color: textPrimary),
        labelMedium: TextStyle(color: textSecondary),
        labelSmall: TextStyle(color: textMuted),
      ),
    );
  }
}
