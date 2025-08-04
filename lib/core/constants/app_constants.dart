class AppConstants {
  // Route Names (sử dụng với GoRouter)
  static const String splashRoute = '/splash';
  static const String onboardingRoute = '/onboarding';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String forgotPasswordRoute = '/forgot-password';
  static const String dashboardRoute = '/dashboard';
  static const String tasksRoute = 'tasks'; // Route con của dashboard
  static const String calendarRoute = 'calendar'; // Route con của dashboard
  static const String profileRoute = 'profile'; // Route con của dashboard
  static const String settingsRoute = '/settings';
  // Thêm các tên route khác ở đây

  // Keys cho SharedPreferences hoặc Hive (ví dụ)
  static const String keyUserToken = 'user_token';
  static const String keyThemeMode = 'theme_mode';
  static const String keyHasSeenOnboarding = 'has_seen_onboarding';

  // Collection names trong Firestore (ví dụ)
  static const String usersCollection = 'users';
  static const String tasksCollection = 'tasks';
  static const String studyPlansCollection = 'study_plans';

  // Thời gian timeout (ví dụ)
  static const Duration defaultTimeout = Duration(seconds: 30);

// Các hằng số khác
// ...
}