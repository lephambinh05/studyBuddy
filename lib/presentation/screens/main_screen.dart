import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studybuddy/core/theme/app_theme.dart';
import 'package:studybuddy/presentation/providers/auth_provider.dart';
import 'package:studybuddy/presentation/providers/study_target_provider.dart';
import 'package:studybuddy/presentation/providers/task_provider.dart';
import 'package:studybuddy/presentation/providers/subject_provider.dart';
import 'package:studybuddy/presentation/providers/theme_provider.dart';
import 'package:studybuddy/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:studybuddy/presentation/screens/tasks/tasks_screen.dart';
import 'package:studybuddy/presentation/screens/calendar/calendar_screen.dart';
import 'package:studybuddy/presentation/screens/profile/profile_screen.dart';
import 'package:studybuddy/presentation/screens/demo/crud_demo_screen.dart';
import 'package:studybuddy/presentation/widgets/task/task_form_dialog.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const DashboardScreen(),
    const TasksScreen(),
    const CalendarScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(theme),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget? _buildFloatingActionButton() {
    if (_currentIndex != 0) return null;
    
    return FloatingActionButton.extended(
      heroTag: 'main_fab',
      onPressed: () {
        _showAddTaskDialog(context);
      },
      backgroundColor: AppThemes.primaryColor,
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text('Add Task', style: TextStyle(color: Colors.white)),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => TaskFormDialog(
        onSave: (task) async {
          try {
            await ref.read(taskProvider.notifier).addTask(task);
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Added task "${task.title}"'),
                  backgroundColor: AppThemes.primaryColor,
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cannot add task. Please try again later.'),
                  backgroundColor: AppThemes.errorColor,
                ),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _showLogoutDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await ref.read(authNotifierProvider.notifier).signOut();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Logout successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error logging out: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomNavigationBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.bottomNavigationBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                icon: Icons.dashboard,
                label: 'Home',
                index: 0,
                isSelected: _currentIndex == 0,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.assignment,
                label: 'Tasks',
                index: 1,
                isSelected: _currentIndex == 1,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.calendar_today,
                label: 'Calendar',
                index: 2,
                isSelected: _currentIndex == 2,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.person,
                  label: 'Profile',
                index: 3,
                isSelected: _currentIndex == 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        _animationController.reset();
        _animationController.forward();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppThemes.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                size: 24,
                color: isSelected 
                    ? AppThemes.primaryColor
                    : theme.bottomNavigationBarTheme.unselectedItemColor,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected 
                    ? AppThemes.primaryColor
                    : theme.bottomNavigationBarTheme.unselectedItemColor,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

// Provider for managing the main screen state
final mainScreenProvider = StateProvider<int>((ref) => 0); 