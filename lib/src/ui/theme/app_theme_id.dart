enum AppThemeId {
  purpleDark,
  blueSlate,
  blackTeal;

  String get label => switch (this) {
        AppThemeId.purpleDark => 'Purple Dark',
        AppThemeId.blueSlate => 'Blue Slate',
        AppThemeId.blackTeal => 'Black Teal',
      };
}
