import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studybuddy/core/constants/app_constants.dart';

class SharedPrefsService {
  final SharedPreferences _prefs;

  SharedPrefsService(this._prefs);

  // --- Onboarding ---
  Future<void> setHasSeenOnboarding(bool value) async {
    await _prefs.setBool(AppConstants.keyHasSeenOnboarding, value);
  }

  bool getHasSeenOnboarding() {
    return _prefs.getBool(AppConstants.keyHasSeenOnboarding) ?? false;
  }

  // --- Theme Mode ---
  Future<void> setThemeMode(String themeModeName) async {
    await _prefs.setString(AppConstants.keyThemeMode, themeModeName);
  }

  String getThemeMode() {
    return _prefs.getString(AppConstants.keyThemeMode) ?? 'system';
  }

  // --- Clear all data (for logout) ---
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}

// Riverpod provider
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

final sharedPrefsServiceProvider = Provider<SharedPrefsService?>((ref) {
  final prefsAsyncValue = ref.watch(sharedPreferencesProvider);
  return prefsAsyncValue.when(
    data: (prefs) => SharedPrefsService(prefs),
    loading: () => null, // Hoặc trả về một instance mặc định/dummy nếu cần
    error: (err, stack) {
      print("Error initializing SharedPreferences: $err");
      // Có thể log lỗi này bằng ErrorHandlerService
      return null; // Hoặc ném lỗi nếu SharedPrefs là bắt buộc
    },
  );
});
