import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studybuddy/presentation/providers/auth_provider.dart';
import 'package:studybuddy/presentation/widgets/auth/auth_form_field.dart';
import 'package:studybuddy/presentation/widgets/common/loading_indicator.dart';
import 'package:studybuddy/core/constants/app_constants.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        await ref
            .read(authNotifierProvider.notifier)
            .registerWithEmail(
              _emailController.text.trim(),
              _passwordController.text.trim(),
              _nameController.text.trim(),
            );

        // Sau khi đăng ký thành công, AuthProvider sẽ cập nhật trạng thái
        // và Splash Screen sẽ điều hướng đến HomeScreen

      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đăng ký thất bại: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe trạng thái từ AuthProvider
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        // Hiển thị lỗi
        if (ModalRoute.of(context)?.isCurrent ?? false) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
        if (mounted) {
          setState(() => _isLoading = false);
        }
      } else if (next.status == AuthStatus.authenticated) {
        // Đăng ký thành công - chuyển trang và hiển thị thông báo
        if (ModalRoute.of(context)?.isCurrent ?? false) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đăng ký thành công!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          // Chuyển đến dashboard
          context.go(AppConstants.dashboardRoute);
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Đăng Ký"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Logo
                const FlutterLogo(size: 80),
                const SizedBox(height: 32),
                Text(
                  "Tạo tài khoản mới",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Tham gia cùng StudyBuddy để quản lý việc học hiệu quả",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: 32),
                
                                 // Họ và tên
                 AuthFormField(
                   controller: _nameController,
                   labelText: "Họ và tên",
                   keyboardType: TextInputType.name,
                   prefixIcon: Icons.person,
                   validator: (value) {
                     if (value == null || value.isEmpty) {
                       return "Please enter full name";
                     }
                     if (value.length < 2) {
                       return "Họ và tên phải có ít nhất 2 ký tự";
                     }
                     return null;
                   },
                 ),
                const SizedBox(height: 16),
                
                                 // Email
                 AuthFormField(
                   controller: _emailController,
                   labelText: "Email",
                   keyboardType: TextInputType.emailAddress,
                   prefixIcon: Icons.email,
                   validator: (value) {
                     if (value == null || value.isEmpty) {
                       return "Please enter your email";
                     }
                     if (!RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                       return "Email không hợp lệ";
                     }
                     return null;
                   },
                 ),
                const SizedBox(height: 16),
                
                                 // Mật khẩu
                 AuthFormField(
                   controller: _passwordController,
                   labelText: "Mật khẩu",
                   obscureText: _obscurePassword,
                   prefixIcon: Icons.lock,
                   suffixIcon: IconButton(
                     icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                     onPressed: () {
                       setState(() {
                         _obscurePassword = !_obscurePassword;
                       });
                     },
                   ),
                   validator: (value) {
                     if (value == null || value.isEmpty) {
                       return "Please enter password";
                     }
                     if (value.length < 6) {
                       return "Password must be at least 6 characters";
                     }
                     if (!RegExp(r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)").hasMatch(value)) {
                       return "Password must contain uppercase, lowercase and numbers";
                     }
                     return null;
                   },
                 ),
                const SizedBox(height: 16),
                
                                 // Confirm password
                 AuthFormField(
                   controller: _confirmPasswordController,
                   labelText: "Confirm Password",
                   obscureText: _obscureConfirmPassword,
                   prefixIcon: Icons.lock_outline,
                   suffixIcon: IconButton(
                     icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                     onPressed: () {
                       setState(() {
                         _obscureConfirmPassword = !_obscureConfirmPassword;
                       });
                     },
                   ),
                   validator: (value) {
                     if (value == null || value.isEmpty) {
                       return "Please confirm password";
                     }
                     if (value != _passwordController.text) {
                       return "Passwords do not match";
                     }
                     return null;
                   },
                 ),
                const SizedBox(height: 24),
                
                // Register button
                _isLoading
                    ? const LoadingIndicator()
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: _register,
                  child: const Text("REGISTER"),
                ),
                const SizedBox(height: 20),
                
                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text("Already have an account?"),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => context.go(AppConstants.loginRoute),
                      child: const Text("Login now"),
                    ),
                  ],
                ),
                
                // Terms of service
                const SizedBox(height: 16),
                Text(
                  "By registering, you agree to the Terms of Service and Privacy Policy",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                
                // TODO: Thêm các tùy chọn đăng ký khác (Google, Apple, ...)
                // const SizedBox(height: 20),
                // Text("Hoặc đăng ký với", textAlign: TextAlign.center),
                // const SizedBox(height: 10),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     // IconButton(icon: Icon(FontAwesomeIcons.google), onPressed: () { /* TODO */ }),
                //     // IconButton(icon: Icon(FontAwesomeIcons.apple), onPressed: () { /* TODO */ }),
                //   ],
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
