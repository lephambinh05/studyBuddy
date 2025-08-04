import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studybuddy/presentation/providers/auth_provider.dart';
import 'package:studybuddy/core/constants/app_constants.dart';
import 'package:studybuddy/data/sources/local/shared_prefs_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatusAndNavigate();
  }

  Future<void> _checkAuthStatusAndNavigate() async {
    // Đợi một chút để logo hiển thị hoặc cho các services khởi tạo
    await Future.delayed(const Duration(seconds: 2));

    // Kiểm tra trạng thái Onboarding trước
    final prefsService = ref.read(sharedPrefsServiceProvider);
    final hasSeenOnboarding = prefsService?.getHasSeenOnboarding() ?? false;

    if (!mounted) return;

    if (!hasSeenOnboarding && prefsService != null) {
      // Sử dụng GoRouter thay vì Navigator
      context.go(AppConstants.onboardingRoute);
      return;
    }

    // Sau đó kiểm tra trạng thái Auth
    final authState = ref.read(authNotifierProvider);

    if (!mounted) return;

    if (authState.status == AuthStatus.authenticated) {
      // Sử dụng GoRouter thay vì Navigator
      context.go(AppConstants.dashboardRoute);
    } else if (authState.status == AuthStatus.unauthenticated || authState.status == AuthStatus.error) {
      // Sử dụng GoRouter thay vì Navigator
      context.go(AppConstants.loginRoute);
    } else {
      // Trường hợp AuthStatus.unknown hoặc AuthStatus.authenticating
      // Sử dụng listener để phản ứng khi trạng thái thay đổi
      final authSubscription = ref.listenManual(authNotifierProvider, (previous, next) {
        if (!mounted) return;
        if (next.status == AuthStatus.authenticated) {
          context.go(AppConstants.dashboardRoute);
        } else if (next.status == AuthStatus.unauthenticated || next.status == AuthStatus.error) {
          context.go(AppConstants.loginRoute);
        }
      });
      
      // Fallback sau 5 giây nếu trạng thái vẫn chưa xác định
      Future.delayed(const Duration(seconds: 5), () {
        if (!mounted) return;
        final currentStatus = ref.read(authNotifierProvider).status;
        if (currentStatus == AuthStatus.unknown || currentStatus == AuthStatus.authenticating) {
          print("Splashscreen timeout, navigating to LoginScreen.");
          context.go(AppConstants.loginRoute);
        }
        authSubscription.close();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TODO: Thay thế bằng logo của bạn
            FlutterLogo(size: 100),
            SizedBox(height: 20),
            Text("StudyBuddy", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
