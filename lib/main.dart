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
  
  // Initialize SharedPreferences
  await SharedPreferences.getInstance();
  
  // Initialize Firebase
  await FirebaseService.initializeFirebase();
  
  // Initialize Notification Service
  await NotificationService.initialize();
  
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
  }
}
