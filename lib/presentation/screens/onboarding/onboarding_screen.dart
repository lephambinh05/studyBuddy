import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studybuddy/data/sources/local/shared_prefs_service.dart';
import 'package:studybuddy/presentation/screens/auth/login_screen.dart'; // Hoặc HomeScreen nếu không cần login sau onboarding

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Ví dụ về nội dung các trang onboarding
  final List<Widget> _onboardingPages = [
    const OnboardingPageContent(
      title: "Chào mừng đến StudyBuddy!",
      description: "Người bạn đồng hành học tập thông minh của bạn. Hãy cùng nhau chinh phục mọi mục tiêu!",
      imagePath: "assets/images/onboarding_1.png", // TODO: Thay thế bằng hình ảnh của bạn
    ),
    const OnboardingPageContent(
      title: "Lập kế hoạch dễ dàng",
      description: "Tạo và quản lý các kế hoạch học tập, theo dõi tiến độ và không bao giờ bỏ lỡ deadline.",
      imagePath: "assets/images/onboarding_2.png", // TODO: Thay thế bằng hình ảnh của bạn
    ),
    const OnboardingPageContent(
      title: "Nhiệm vụ thông minh",
      description: "Phân chia mục tiêu lớn thành các nhiệm vụ nhỏ, ưu tiên và hoàn thành chúng một cách hiệu quả.",
      imagePath: "assets/images/onboarding_3.png", // TODO: Thay thế bằng hình ảnh của bạn
    ),
  ];

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _completeOnboarding() async {
    final prefsService = ref.read(sharedPrefsServiceProvider);
    await prefsService?.setHasSeenOnboarding(true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()), // Hoặc HomeScreen
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingPages.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  return _onboardingPages[index];
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Nút Skip
                  _currentPage != _onboardingPages.length - 1
                      ? TextButton(
                    onPressed: _completeOnboarding,
                    child: const Text("BỎ QUA"),
                  )
                      : const SizedBox(width: 70), // Để giữ vị trí cân bằng

                  // Dấu chấm chỉ số trang
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingPages.length,
                          (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        height: 8.0,
                        width: _currentPage == index ? 24.0 : 8.0,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                    ),
                  ),

                  // Nút Next/Done
                  _currentPage == _onboardingPages.length - 1
                      ? ElevatedButton(
                    onPressed: _completeOnboarding,
                    child: const Text("BẮT ĐẦU"),
                  )
                      : ElevatedButton(
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Text("TIẾP"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class OnboardingPageContent extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath; // Đường dẫn đến ảnh trong assets

  const OnboardingPageContent({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Widget thay thế nếu ảnh không load được
                return const Icon(Icons.image_not_supported, size: 100, color: Colors.grey);
              },
            ),
          ),
          const SizedBox(height: 40.0),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16.0),
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
