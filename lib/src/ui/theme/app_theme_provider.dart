import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'app_theme_id.dart';

class AppThemeNotifier extends StateNotifier<AppThemeId> {
  AppThemeNotifier(super.initial);
  void setTheme(AppThemeId id) => state = id;
}
