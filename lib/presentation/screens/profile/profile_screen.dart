import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studybuddy/core/theme/app_theme.dart';
import 'package:studybuddy/presentation/widgets/common/gradient_card.dart';
import 'package:studybuddy/presentation/providers/user_provider.dart';
import 'package:studybuddy/presentation/providers/auth_provider.dart';
import 'package:studybuddy/presentation/providers/task_provider.dart';
import 'package:studybuddy/presentation/providers/subject_provider.dart';
import 'package:studybuddy/presentation/providers/study_target_provider.dart';
import 'package:studybuddy/presentation/providers/theme_provider.dart';
import 'package:studybuddy/presentation/widgets/study_target/study_target_form_dialog.dart';
import 'package:studybuddy/data/models/study_target.dart';
import 'package:studybuddy/presentation/screens/settings/sync_settings_screen.dart';
import 'package:studybuddy/presentation/screens/settings/security_settings_screen.dart';
import 'package:studybuddy/presentation/screens/settings/notification_settings_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
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
    
    // Load study targets
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(studyTargetProvider.notifier).loadStudyTargets();
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
              expandedHeight: 200,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: theme.scaffoldBackgroundColor,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: AppThemes.primaryGradient,
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildProfileHeader(theme),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () {
                    _showEditProfileDialog(context);
                  },
                ),
              ],
            ),
            
            // Content
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Statistics Section
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildStatisticsSection(theme),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Achievements Section
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildAchievementsSection(theme),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Study Goals Section (đổi lên trước)
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildStudyGoalsSection(theme),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Settings Section (đổi xuống sau)
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildSettingsSection(theme),
                    ),
                  ),
                  
                  const SizedBox(height: 100), // Bottom padding
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    final userState = ref.watch(userProvider);
    final authState = ref.watch(authNotifierProvider);
    
    // Get user data - ưu tiên appUser từ AuthState, sau đó đến userState, cuối cùng là firebaseUser
    final appUser = authState.appUser;
    final firebaseUser = authState.firebaseUser;
    final user = userState.user;
    
    final displayName = appUser?.displayName ?? 
                       user?.displayName ?? 
                       firebaseUser?.displayName ?? 
                       firebaseUser?.email?.split('@').first ?? 
                       'User';
    final email = appUser?.email ?? 
                  user?.email ?? 
                  firebaseUser?.email ?? '';
    final consecutiveDays = appUser?.consecutiveDays ?? 
                           user?.consecutiveDays ?? 0;
    final photoUrl = appUser?.photoUrl ?? 
                     user?.photoUrl ?? 
                     firebaseUser?.photoURL;
    
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Profile Picture
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white.withOpacity(0.2),
              backgroundImage: photoUrl != null 
                ? NetworkImage(photoUrl) 
                : null,
              child: photoUrl == null 
                ? const Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.white,
                  )
                : null,
            ),
          ),
          const SizedBox(height: 6),
          
          // Name and Email
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  displayName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 1),
                  Text(
                    email,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 6),
          
          // Level and Points
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatItem(
                context: context,
                icon: Icons.star,
                value: 'Level ${(consecutiveDays / 7).floor() + 1}',
                label: 'Level',
                color: Colors.white,
              ),
              Container(
                width: 1,
                height: 25,
                color: Colors.white.withOpacity(0.3),
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
              _buildStatItem(
                context: context,
                icon: Icons.emoji_events,
                value: '${consecutiveDays}',
                label: 'Consecutive days of study',
                color: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(ThemeData theme) {
    final userState = ref.watch(userProvider);
    final taskState = ref.watch(taskProvider);
    
    // Get real statistics
    final consecutiveDays = userState.consecutiveDays;
    final totalTasks = taskState.statistics['totalTasks'] ?? 0;
    final completedTasks = taskState.statistics['completedTasks'] ?? 0;
    final completionRate = taskState.statistics['completionRate'] ?? 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analytics',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context: context,
                title: 'Completed tasks',
                value: '$completedTasks/$totalTasks',
                icon: Icons.check_circle,
                color: AppThemes.accentColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context: context,
                title: 'Consecutive days of study',
                value: '$consecutiveDays',
                icon: Icons.local_fire_department,
                color: AppThemes.warningColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context: context,
                title: 'Completion rate',
                value: '${(completionRate * 100).toStringAsFixed(1)}%',
                icon: Icons.schedule,
                color: AppThemes.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context: context,
                title: 'Remaining tasks',
                value: '${totalTasks - completedTasks}',
                icon: Icons.trending_up,
                color: AppThemes.secondaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAchievementsSection(ThemeData theme) {
    final userState = ref.watch(userProvider);
    final taskState = ref.watch(taskProvider);
    final subjectState = ref.watch(subjectProvider);
    
    // Get real statistics
    final consecutiveDays = userState.consecutiveDays;
    final totalTasks = taskState.statistics['totalTasks'] ?? 0;
    final completedTasks = taskState.statistics['completedTasks'] ?? 0;
    final subjects = subjectState.subjects;
    
    // Calculate achievements based on real data
    final achievements = [
      {
        'title': 'Học sinh xuất sắc',
        'description': 'Hoàn thành 50 bài tập',
        'icon': Icons.emoji_events,
        'color': AppThemes.warningColor,
        'isUnlocked': completedTasks >= 50,
        'progress': (completedTasks / 50).clamp(0.0, 1.0),
      },
      {
        'title': 'Chăm chỉ',
        'description': 'Học 7 ngày liên tiếp',
        'icon': Icons.local_fire_department,
        'color': AppThemes.errorColor,
        'isUnlocked': consecutiveDays >= 7,
        'progress': (consecutiveDays / 7).clamp(0.0, 1.0),
      },
      {
        'title': 'Toán học',
        'description': 'Hoàn thành 20 bài tập Toán',
        'icon': Icons.calculate,
        'color': AppThemes.primaryColor,
        'isUnlocked': false, // TODO: Calculate based on subject
        'progress': 0.0,
      },
      {
        'title': 'Tiếng Anh',
        'description': 'Hoàn thành 15 bài tập Tiếng Anh',
        'icon': Icons.language,
        'color': AppThemes.secondaryColor,
        'isUnlocked': false, // TODO: Calculate based on subject
        'progress': 0.0,
      },
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Achievements',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: achievements.map((achievement) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _buildAchievementCard(
                  context: context,
                  title: achievement['title'] as String,
                  description: achievement['description'] as String,
                  icon: achievement['icon'] as IconData,
                  color: achievement['color'] as Color,
                  isUnlocked: achievement['isUnlocked'] as bool,
                  progress: achievement['progress'] as double,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(ThemeData theme) {
    final authState = ref.watch(authNotifierProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cài đặt',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GlassCard(
          child: Column(
            children: [
              _buildSettingItem(
                context: context,
                icon: Icons.notifications,
                title: 'Notifications',
                subtitle: 'Enable notifications for tasks',
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    // TODO: Implement notification toggle
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Notifications ${value ? 'enabled' : 'disabled'}'),
                        backgroundColor: AppThemes.primaryColor,
                      ),
                    );
                  },
                  activeColor: AppThemes.primaryColor,
                ),
              ),
              const Divider(),
              _buildSettingItem(
                context: context,
                icon: Icons.dark_mode,
                title: 'Dark mode',
                subtitle: 'Switch between light and dark mode',
                trailing: Switch(
                  value: theme.brightness == Brightness.dark,
                  onChanged: (value) {
                    // Toggle theme mode using theme provider instead of Navigator
                    final currentMode = Theme.of(context).brightness;
                    final newMode = currentMode == Brightness.light ? Brightness.dark : Brightness.light;
                    
                    // Use theme provider to update theme
                    ref.read(themeProvider.notifier).toggleTheme();
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Dark mode ${value ? 'enabled' : 'disabled'}'),
                        backgroundColor: AppThemes.primaryColor,
                      ),
                    );
                  },
                  activeColor: AppThemes.primaryColor,
                ),
              ),
              const Divider(),
              _buildSettingItem(
                context: context,
                icon: Icons.sync,
                title: 'Sync data',
                subtitle: 'Sync with account',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SyncSettingsScreen(),
                    ),
                  );
                },
              ),
              const Divider(),
              _buildSettingItem(
                context: context,
                icon: Icons.security,
                title: 'Security',
                subtitle: 'Change password, 2FA',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SecuritySettingsScreen(),
                    ),
                  );
                },
              ),
              const Divider(),
              _buildSettingItem(
                context: context,
                icon: Icons.notifications,
                title: 'Notifications',
                subtitle: 'Settings for notifications',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationSettingsScreen(),
                    ),
                  );
                },
              ),
              const Divider(),
              _buildSettingItem(
                context: context,
                icon: Icons.logout,
                title: 'Logout',
                subtitle: 'Logout from account',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showLogoutDialog(context);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStudyGoalsSection(ThemeData theme) {
    final studyTargetState = ref.watch(studyTargetProvider);
    final targets = studyTargetState.activeTargets;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Study goals',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const StudyTargetFormDialog(),
                );
              },
              icon: const Icon(Icons.add_circle, color: AppThemes.primaryColor),
              tooltip: 'Add new goal',
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (targets.isEmpty)
          GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.flag_outlined,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No goals yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to create a new study goal',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          GlassCard(
            child: Column(
              children: targets.map((target) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildStudyTargetItem(
                    context: context,
                    target: target,
                    theme: theme,
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildStudyTargetItem({
    required BuildContext context,
    required StudyTarget target,
    required ThemeData theme,
  }) {
    final progress = target.progress;
    final isOverdue = target.isOverdue;
    final daysRemaining = target.daysRemaining;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isOverdue ? Colors.red.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOverdue ? Colors.red.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  target.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isOverdue ? Colors.red : null,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      showDialog(
                        context: context,
                        builder: (context) => StudyTargetFormDialog(target: target),
                      );
                      break;
                    case 'delete':
                      _showDeleteTargetDialog(context, target);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 16),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                child: const Icon(Icons.more_vert, size: 20),
              ),
            ],
          ),
          if (target.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              target.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${target.currentValue.toStringAsFixed(1)}/${target.targetValue.toStringAsFixed(1)} ${target.unit}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: target.isCompleted ? Colors.green : Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (target.endDate != null && daysRemaining >= 0)
                Text(
                  'Remaining $daysRemaining days',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: daysRemaining <= 7 ? Colors.orange : Colors.grey.shade600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: (isOverdue ? Colors.red : AppThemes.primaryColor).withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              target.isCompleted 
                ? Colors.green 
                : (isOverdue ? Colors.red : AppThemes.primaryColor)
            ),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  void _showDeleteTargetDialog(BuildContext context, StudyTarget target) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete goal'),
        content: Text('Are you sure you want to delete the goal "${target.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(studyTargetProvider.notifier).deleteStudyTarget(target.id);
                // Kiểm tra mounted trước khi hiển thị SnackBar
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Goal has been deleted'),
                      backgroundColor: AppThemes.primaryColor,
                    ),
                  );
                }
              } catch (e) {
                // Kiểm tra mounted trước khi hiển thị SnackBar
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 20,
          color: color,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color.withOpacity(0.8),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
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
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required bool isUnlocked,
    required double progress,
  }) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnlocked 
            ? color.withOpacity(0.1)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnlocked 
              ? color.withOpacity(0.3)
              : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: isUnlocked ? color : Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isUnlocked ? color : Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isUnlocked ? color.withOpacity(0.8) : Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppThemes.primaryColor,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.grey.shade600,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildGoalItem({
    required BuildContext context,
    required String title,
    required double progress,
    required dynamic current,
    required dynamic total,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '$current/$total',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit profile'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Full name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Class',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'School',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Save profile changes
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout from your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(authNotifierProvider.notifier).signOut();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Logout successful'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Logout error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
} 