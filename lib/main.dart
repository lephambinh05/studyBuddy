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
import 'package:studybuddy/presentation/screens/auth/login_screen.dart';
import 'package:studybuddy/presentation/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize SharedPreferences
    await SharedPreferences.getInstance();
    print('✅ SharedPreferences initialized');

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
    const ProviderScope(
      child: MyApp(),
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
      final themeMode = ref.watch(themeProvider);
      final themeData = ref.watch(themeDataProvider);

      return MaterialApp(
        title: 'StudyBuddy',
        theme: themeData,
        themeMode: themeMode,
        debugShowCheckedModeBanner: false,
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
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Có lỗi xảy ra',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Vui lòng khởi động lại ứng dụng',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Restart the app
                    main();
                  },
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
