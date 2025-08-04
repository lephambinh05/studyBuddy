import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Enum cho các lựa chọn chủ đề
enum AppThemeMode {
  light("Sáng"),
  dark("Tối"),
  system("Hệ thống");

  const AppThemeMode(this.displayName);
  final String displayName;
}

const String _themeModeKey = 'app_theme_mode';

// State Notifier cho cài đặt
class SettingsNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences _prefs;

  SettingsNotifier(this._prefs) : super(_loadThemeMode(_prefs));

  static ThemeMode _loadThemeMode(SharedPreferences prefs) {
    final themeString = prefs.getString(_themeModeKey);
    return AppThemeMode.values
        .firstWhere((e) => e.name == themeString, orElse: () => AppThemeMode.system)
        .toMaterialThemeMode();
  }

  Future<void> setThemeMode(AppThemeMode themeMode) async {
    if (themeMode.toMaterialThemeMode() != state) {
      await _prefs.setString(_themeModeKey, themeMode.name);
      state = themeMode.toMaterialThemeMode();
    }
  }

  // Getter để lấy AppThemeMode hiện tại (hữu ích cho UI)
  AppThemeMode get currentAppThemeMode {
    final themeString = _prefs.getString(_themeModeKey);
    return AppThemeMode.values
        .firstWhere((e) => e.name == themeString, orElse: () => AppThemeMode.system);
  }
}

// Provider cho SharedPreferences (sẽ được override ở main.dart)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences provider was not overridden');
});

// Provider cho SettingsNotifier
final settingsProvider = StateNotifierProvider<SettingsNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsNotifier(prefs);
});

// Helper extension để chuyển đổi
extension AppThemeModeExtension on AppThemeMode {
  ThemeMode toMaterialThemeMode() {
    switch (this) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
      default:
        return ThemeMode.system;
    }
  }
} 