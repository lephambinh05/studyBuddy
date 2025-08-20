import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studybuddy/core/services/firebase_service.dart';
import 'package:studybuddy/core/services/notification_service.dart';
import 'package:studybuddy/core/theme/app_theme.dart';
import 'package:studybuddy/presentation/providers/auth_provider.dart';
import 'package:studybuddy/presentation/providers/task_provider.dart';
import 'package:studybuddy/presentation/providers/subject_provider.dart';
import 'package:studybuddy/presentation/providers/theme_provider.dart';
import 'package:studybuddy/presentation/providers/settings_provider.dart';
import 'package:studybuddy/presentation/screens/auth/login_screen.dart';
import 'package:studybuddy/presentation/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  print('✅ SharedPreferences initialized');

  try {
    // Initialize Firebase
    await FirebaseService.initializeFirebase();
    print('✅ Firebase initialized');

    // Initialize Notification Service
    await NotificationService.initialize();
    print('✅ NotificationService initialized');
  } catch (e, stackTrace) {
    print('❌ Error during initialization: $e');
    print('❌ Stack trace: $stackTrace');
    // Continue anyway to prevent crash
  }
  
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    try {
      final authState = ref.watch(authNotifierProvider);
      final themeMode = ref.watch(settingsProvider);
      
      // Create theme data based on settings provider
      final themeData = _getThemeData(themeMode);

      return MaterialApp(
        title: 'StudyBuddy',
        theme: themeData,
        themeMode: themeMode,
        debugShowCheckedModeBanner: false,
        locale: const Locale('en'),
        supportedLocales: const [Locale('en')],
        home: authState.status == AuthStatus.authenticated
          ? const MainScreen()
          : const LoginScreen(),
      );
    } catch (e, stackTrace) {
      print('❌ Error in MyApp build: $e');
      print('❌ Stack trace: $stackTrace');
      
      // Return a simple error screen if there's an error
      return MaterialApp(
        title: 'StudyBuddy',
        theme: AppThemes.lightTheme,
        debugShowCheckedModeBanner: false,
        locale: const Locale('en'),
        supportedLocales: const [Locale('en')],
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'An error occurred',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please restart the application',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Restart the app
                    main();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
  
  ThemeData _getThemeData(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return AppThemes.lightTheme;
      case ThemeMode.dark:
        return AppThemes.darkTheme;
      case ThemeMode.system:
        // Sử dụng light theme làm mặc định cho system mode
        return AppThemes.lightTheme;
    }
  }
}
