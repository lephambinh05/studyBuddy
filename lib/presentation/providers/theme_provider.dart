import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studybuddy/core/theme/app_theme.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light);

  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  void setTheme(ThemeMode mode) {
    state = mode;
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

final themeDataProvider = Provider<ThemeData>((ref) {
  final themeMode = ref.watch(themeProvider);
  
  switch (themeMode) {
    case ThemeMode.light:
      return ThemeData.light().copyWith(
        primaryColor: AppThemes.primaryColor,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.light(
          primary: AppThemes.primaryColor,
          secondary: AppThemes.secondaryColor,
          surface: Colors.white,
          background: Colors.grey[50]!,
        ),
      );
    case ThemeMode.dark:
      return ThemeData.dark().copyWith(
        primaryColor: AppThemes.primaryColor,
        scaffoldBackgroundColor: Colors.grey[900],
        colorScheme: ColorScheme.dark(
          primary: AppThemes.primaryColor,
          secondary: AppThemes.secondaryColor,
          surface: Colors.grey[800]!,
          background: Colors.grey[900]!,
        ),
      );
    case ThemeMode.system:
      return ThemeData.light().copyWith(
        primaryColor: AppThemes.primaryColor,
        scaffoldBackgroundColor: Colors.white,
      );
  }
}); 