import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studybuddy/core/theme/app_theme.dart';
import 'package:studybuddy/presentation/widgets/common/gradient_card.dart';
import 'package:studybuddy/core/services/notification_service.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen> {
  bool _smartNotificationsEnabled = true;
  bool _behaviorBasedNotificationsEnabled = true;
  Map<String, bool> _notificationPreferences = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _notificationPreferences = NotificationService.getNotificationPreferences();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading notification settings: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateNotificationPreference(String key, bool value) async {
    try {
      await NotificationService.updateNotificationPreference(key, value);
      setState(() {
        _notificationPreferences[key] = value;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification settings updated'),
            backgroundColor: AppThemes.primaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating notification settings: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification settings'),
        backgroundColor: AppThemes.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Smart Notifications Section
                  Text(
                    'Smart notifications',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  GlassCard(
                    child: Column(
                      children: [
                        _buildNotificationOption(
                          context: context,
                          icon: Icons.psychology,
                          title: 'Smart notifications',
                          subtitle: 'Notifications based on study behavior',
                          value: _smartNotificationsEnabled,
                          onChanged: (value) {
                            setState(() {
                              _smartNotificationsEnabled = value;
                            });
                            NotificationService.setSmartNotificationsEnabled(value);
                          },
                        ),
                        const Divider(),
                        _buildNotificationOption(
                          context: context,
                          icon: Icons.trending_up,
                          title: 'Behavior-based notifications',
                          subtitle: 'Analyze behavior to send appropriate notifications',
                          value: _behaviorBasedNotificationsEnabled,
                          onChanged: (value) {
                            setState(() {
                              _behaviorBasedNotificationsEnabled = value;
                            });
                            NotificationService.setBehaviorBasedNotificationsEnabled(value);
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Notification Types Section
                  Text(
                    'Notification types',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  GlassCard(
                    child: Column(
                      children: [
                        _buildNotificationOption(
                          context: context,
                          icon: Icons.task,
                          title: 'Task reminders',
                          subtitle: 'Notifications for deadlines and upcoming tasks',
                          value: _notificationPreferences['task_reminders'] ?? true,
                          onChanged: (value) => _updateNotificationPreference('task_reminders', value),
                        ),
                        const Divider(),
                        _buildNotificationOption(
                          context: context,
                          icon: Icons.event,
                          title: 'Event reminders',
                          subtitle: 'Notifications for study schedules and events',
                          value: _notificationPreferences['event_reminders'] ?? true,
                          onChanged: (value) => _updateNotificationPreference('event_reminders', value),
                        ),
                        const Divider(),
                        _buildNotificationOption(
                          context: context,
                          icon: Icons.emoji_events,
                          title: 'Achievement notifications',
                          subtitle: 'Notifications when new achievements are reached',
                          value: _notificationPreferences['achievement_notifications'] ?? true,
                          onChanged: (value) => _updateNotificationPreference('achievement_notifications', value),
                        ),
                        const Divider(),
                        _buildNotificationOption(
                          context: context,
                          icon: Icons.school,
                          title: 'Study reminders',
                          subtitle: 'Periodic study reminders',
                          value: _notificationPreferences['study_reminders'] ?? true,
                          onChanged: (value) => _updateNotificationPreference('study_reminders', value),
                        ),
                        const Divider(),
                        _buildNotificationOption(
                          context: context,
                          icon: Icons.favorite,
                          title: 'Motivational messages',
                          subtitle: 'Motivational messages and encouragement',
                          value: _notificationPreferences['motivational_messages'] ?? true,
                          onChanged: (value) => _updateNotificationPreference('motivational_messages', value),
                        ),
                        const Divider(),
                        _buildNotificationOption(
                          context: context,
                          icon: Icons.warning,
                          title: 'Deadline warnings',
                          subtitle: 'Warnings when deadlines are approaching',
                          value: _notificationPreferences['deadline_warnings'] ?? true,
                          onChanged: (value) => _updateNotificationPreference('deadline_warnings', value),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Notification Schedule Section
                  Text(
                      'Notification schedule',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                color: AppThemes.primaryColor,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Notification time',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Notifications will be sent at the appropriate time:',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildTimeRangeItem(
                            context: context,
                            icon: Icons.wb_sunny,
                            title: 'Morning',
                            time: '8:00 - 12:00',
                            description: 'Motivational messages and study reminders',
                          ),
                          const SizedBox(height: 8),
                          _buildTimeRangeItem(
                            context: context,
                            icon: Icons.wb_cloudy,
                            title: 'Afternoon',
                            time: '14:00 - 18:00',
                            description: 'Deadline reminders and task reminders',
                          ),
                          const SizedBox(height: 8),
                          _buildTimeRangeItem(
                            context: context,
                            icon: Icons.nightlight,
                            title: 'Evening',
                            time: '19:00 - 22:00',
                            description: 'Daily summary and tomorrow\'s plan',
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Test Notifications Section
                  Text(
                    'Test notifications',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  GlassCard(
                    child: Column(
                      children: [
                        _buildActionItem(
                          context: context,
                          icon: Icons.notifications,
                          title: 'Send test notification',
                          subtitle: 'Send a test notification to check settings',
                          onTap: _sendTestNotification,
                        ),
                        const Divider(),
                        _buildActionItem(
                          context: context,
                          icon: Icons.school,
                          title: 'Send study reminder',
                          subtitle: 'Send a study reminder',
                          onTap: _sendStudyReminder,
                        ),
                        const Divider(),
                        _buildActionItem(
                          context: context,
                          icon: Icons.favorite,
                          title: 'Send motivational message',
                          subtitle: 'Send a motivational message',
                          onTap: _sendMotivationalMessage,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
    );
  }

  Widget _buildNotificationOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
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
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppThemes.primaryColor,
      ),
    );
  }

  Widget _buildTimeRangeItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String time,
    required String description,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppThemes.primaryColor,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                time,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppThemes.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
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
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Future<void> _sendTestNotification() async {
    try {
      final user = NotificationService.getUserBehavior();
      await NotificationService.sendNotificationToUser(
        userId: user['userId'] ?? '',
        title: '🧪 Test notification',
        body: 'This is a test notification to check settings!',
        data: {
          'type': 'test_notification',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test notification sent!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending notification: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendStudyReminder() async {
    try {
      final user = NotificationService.getUserBehavior();
      await NotificationService.sendPersonalizedStudyReminder(
        userId: user['userId'] ?? '',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Study reminder sent!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending study reminder: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendMotivationalMessage() async {
    try {
      final user = NotificationService.getUserBehavior();
      await NotificationService.sendMotivationalMessage(
        userId: user['userId'] ?? '',
        message: 'Today is a great day to study and develop! 💪',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Motivational message sent!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending motivational message: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 