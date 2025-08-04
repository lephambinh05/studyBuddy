import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studybuddy/core/theme/app_theme.dart';
import 'package:studybuddy/presentation/widgets/common/gradient_card.dart';
import 'package:studybuddy/presentation/widgets/common/empty_state.dart';
import 'package:studybuddy/presentation/providers/task_provider.dart';
import 'package:studybuddy/presentation/providers/event_provider.dart';
import 'package:studybuddy/presentation/providers/user_provider.dart';
import 'package:studybuddy/presentation/widgets/task/task_form_dialog.dart';
import 'package:studybuddy/presentation/screens/tasks/tasks_screen.dart';
import 'package:studybuddy/presentation/screens/calendar/calendar_screen.dart';
import 'package:studybuddy/presentation/screens/settings/settings_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
    
    // Load data khi screen được khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(taskProvider.notifier).loadTasks();
      ref.read(eventProvider.notifier).loadEvents();
      ref.read(userProvider.notifier).loadCurrentUser();
    });
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
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: theme.scaffoldBackgroundColor,
              flexibleSpace: FlexibleSpaceBar(
                title: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'StudyBuddy',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppThemes.primaryColor,
                    ),
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: AppThemes.primaryGradient,
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    // TODO: Navigate to notifications
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.person_outline),
                  onPressed: () {
                    // TODO: Navigate to profile
                  },
                ),
              ],
            ),
            
            // Content
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Welcome Section
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildWelcomeSection(theme),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Quick Stats
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildQuickStats(theme),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Today's Tasks
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildTodayTasks(theme),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Study Progress
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildStudyProgress(theme),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Quick Actions
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildQuickActions(theme),
                    ),
                  ),
                  
                  const SizedBox(height: 100), // Bottom padding for FAB
                ]),
              ),
            ),
          ],
        ),
      ),
             floatingActionButton: FloatingActionButton.extended(
         heroTag: 'dashboard_fab',
         onPressed: () => _showAddTaskDialog(context),
         icon: const Icon(Icons.add),
         label: const Text('Thêm bài tập'),
         backgroundColor: AppThemes.primaryColor,
       ),
    );
  }

  Widget _buildWelcomeSection(ThemeData theme) {
    final taskState = ref.watch(taskProvider);
    final now = DateTime.now();
    final hour = now.hour;
    String greeting;
    
    if (hour < 12) {
      greeting = 'Chào buổi sáng';
    } else if (hour < 17) {
      greeting = 'Chào buổi chiều';
    } else {
      greeting = 'Chào buổi tối';
    }
    
    return GradientCard(
      gradient: AppThemes.primaryGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: const Icon(
                  Icons.school,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Hãy bắt đầu học tập ngay hôm nay!',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context: context,
                  icon: Icons.assignment,
                  value: taskState.statistics['totalTasks']?.toString() ?? '0',
                  label: 'Bài tập',
                  color: Colors.white,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context: context,
                  icon: Icons.check_circle,
                  value: taskState.statistics['completedTasks']?.toString() ?? '0',
                  label: 'Hoàn thành',
                  color: Colors.white,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context: context,
                  icon: Icons.schedule,
                  value: taskState.statistics['pendingTasks']?.toString() ?? '0',
                  label: 'Còn lại',
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(ThemeData theme) {
    final taskState = ref.watch(taskProvider);
    final userState = ref.watch(userProvider);
    final statistics = taskState.statistics;
    
    // Tính toán completion rate
    final completionRate = statistics['completionRate'] ?? 0.0;
    final completionPercentage = (completionRate * 100).round();
    
    // Sử dụng consecutive days từ UserProvider
    final consecutiveDays = userState.consecutiveDays;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thống kê nhanh',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GlassCard(
                child: _buildStatItem(
                  context: context,
                  icon: Icons.trending_up,
                  value: '${completionPercentage}%',
                  label: 'Tiến độ',
                  color: AppThemes.accentColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GlassCard(
                child: _buildStatItem(
                  context: context,
                  icon: Icons.local_fire_department,
                  value: '$consecutiveDays',
                  label: 'Ngày liên tiếp',
                  color: AppThemes.warningColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTodayTasks(ThemeData theme) {
    final taskState = ref.watch(taskProvider);
    final todayTasks = taskState.tasks.where((task) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));
      return task.deadline.isAfter(today) && task.deadline.isBefore(tomorrow);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Bài tập hôm nay',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to all tasks
              },
              child: const Text('Xem tất cả'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (taskState.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (todayTasks.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
                         child: EmptyState(
               title: 'Không có bài tập hôm nay',
               message: 'Bạn không có bài tập nào cần làm hôm nay. Hãy thêm bài tập mới!',
               icon: Icons.assignment_outlined,
               onActionPressed: () => _showAddTaskDialog(context),
               actionText: 'Thêm bài tập',
             ),
          )
        else
          ...todayTasks.take(3).map((task) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildTaskItem(
              context: context,
              title: task.title,
              subject: task.subject,
              time: _formatTime(task.deadline),
              isCompleted: task.isCompleted,
              priority: task.priority,
            ),
          )),
      ],
    );
  }

  Widget _buildStudyProgress(ThemeData theme) {
    final taskState = ref.watch(taskProvider);
    final completionRate = taskState.statistics['completionRate'] ?? 0.0;
    final totalTasks = taskState.statistics['totalTasks'] ?? 0;
    
    if (totalTasks == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tiến độ học tập',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
                         child: EmptyState(
               title: 'Chưa có dữ liệu tiến độ',
               message: 'Bạn chưa có bài tập nào để tính tiến độ. Hãy thêm bài tập để bắt đầu!',
               icon: Icons.trending_up_outlined,
               onActionPressed: () => _showAddTaskDialog(context),
               actionText: 'Thêm bài tập',
             ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tiến độ học tập',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GlassCard(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tổng thể',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${(completionRate * 100).toInt()}%',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppThemes.accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: completionRate,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(AppThemes.accentColor),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      context: context,
                      icon: Icons.assignment,
                      value: totalTasks.toString(),
                      label: 'Tổng bài tập',
                      color: AppThemes.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatItem(
                      context: context,
                      icon: Icons.check_circle,
                      value: (taskState.statistics['completedTasks'] ?? 0).toString(),
                      label: 'Đã hoàn thành',
                      color: AppThemes.accentColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatItem(
                      context: context,
                      icon: Icons.schedule,
                      value: (taskState.statistics['pendingTasks'] ?? 0).toString(),
                      label: 'Còn lại',
                      color: AppThemes.warningColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thao tác nhanh',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                             child: _buildActionButton(
                 context: context,
                 icon: Icons.add_task,
                 label: 'Thêm bài tập',
                 color: AppThemes.primaryColor,
                 onTap: () => _showAddTaskDialog(context),
               ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                context: context,
                icon: Icons.calendar_today,
                label: 'Lịch học',
                color: AppThemes.secondaryColor,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CalendarScreen()));
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context: context,
                icon: Icons.analytics,
                label: 'Thống kê',
                color: AppThemes.accentColor,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const TasksScreen()));
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                context: context,
                icon: Icons.settings,
                label: 'Cài đặt',
                color: AppThemes.warningColor,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: color,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskItem({
    required BuildContext context,
    required String title,
    required String subject,
    required String time,
    required bool isCompleted,
    required int priority,
  }) {
    final theme = Theme.of(context);
    
    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getPriorityColor(priority),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted ? Colors.grey.shade600 : null,
                  ),
                ),
                Text(
                  subject,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppThemes.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectProgress({
    required BuildContext context,
    required String subject,
    required double progress,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          subject,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
        const SizedBox(height: 4),
        Text(
          '${(progress * 100).toInt()}%',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return AppThemes.errorColor;
      case 2:
        return AppThemes.warningColor;
      case 3:
        return AppThemes.accentColor;
      default:
        return AppThemes.primaryColor;
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => TaskFormDialog(
        onSave: (task) {
          ref.read(taskProvider.notifier).addTask(task);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Bài tập đã được thêm thành công!'),
              backgroundColor: AppThemes.primaryColor,
            ),
          );
        },
      ),
    );
  }
}
