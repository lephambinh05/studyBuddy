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
            content: Text('Đã cập nhật cài đặt thông báo'),
            backgroundColor: AppThemes.primaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi cập nhật cài đặt: ${e.toString()}'),
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
        title: const Text('Cài đặt thông báo'),
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
                    'Thông báo thông minh',
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
                          title: 'Thông báo thông minh',
                          subtitle: 'Thông báo dựa trên hành vi học tập',
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
                          title: 'Thông báo dựa trên hành vi',
                          subtitle: 'Phân tích hành vi để gửi thông báo phù hợp',
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
                    'Loại thông báo',
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
                          title: 'Nhắc nhở bài tập',
                          subtitle: 'Thông báo deadline và bài tập sắp đến hạn',
                          value: _notificationPreferences['task_reminders'] ?? true,
                          onChanged: (value) => _updateNotificationPreference('task_reminders', value),
                        ),
                        const Divider(),
                        _buildNotificationOption(
                          context: context,
                          icon: Icons.event,
                          title: 'Nhắc nhở sự kiện',
                          subtitle: 'Thông báo về lịch học và sự kiện',
                          value: _notificationPreferences['event_reminders'] ?? true,
                          onChanged: (value) => _updateNotificationPreference('event_reminders', value),
                        ),
                        const Divider(),
                        _buildNotificationOption(
                          context: context,
                          icon: Icons.emoji_events,
                          title: 'Thông báo thành tích',
                          subtitle: 'Thông báo khi đạt được thành tích mới',
                          value: _notificationPreferences['achievement_notifications'] ?? true,
                          onChanged: (value) => _updateNotificationPreference('achievement_notifications', value),
                        ),
                        const Divider(),
                        _buildNotificationOption(
                          context: context,
                          icon: Icons.school,
                          title: 'Nhắc nhở học tập',
                          subtitle: 'Thông báo nhắc nhở học tập định kỳ',
                          value: _notificationPreferences['study_reminders'] ?? true,
                          onChanged: (value) => _updateNotificationPreference('study_reminders', value),
                        ),
                        const Divider(),
                        _buildNotificationOption(
                          context: context,
                          icon: Icons.favorite,
                          title: 'Tin nhắn động lực',
                          subtitle: 'Tin nhắn khuyến khích và động lực học tập',
                          value: _notificationPreferences['motivational_messages'] ?? true,
                          onChanged: (value) => _updateNotificationPreference('motivational_messages', value),
                        ),
                        const Divider(),
                        _buildNotificationOption(
                          context: context,
                          icon: Icons.warning,
                          title: 'Cảnh báo deadline',
                          subtitle: 'Cảnh báo khi deadline sắp đến',
                          value: _notificationPreferences['deadline_warnings'] ?? true,
                          onChanged: (value) => _updateNotificationPreference('deadline_warnings', value),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Notification Schedule Section
                  Text(
                    'Lịch thông báo',
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
                                'Thời gian thông báo',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Thông báo sẽ được gửi trong khoảng thời gian phù hợp:',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildTimeRangeItem(
                            context: context,
                            icon: Icons.wb_sunny,
                            title: 'Buổi sáng',
                            time: '8:00 - 12:00',
                            description: 'Thông báo động lực và nhắc nhở học tập',
                          ),
                          const SizedBox(height: 8),
                          _buildTimeRangeItem(
                            context: context,
                            icon: Icons.wb_cloudy,
                            title: 'Buổi chiều',
                            time: '14:00 - 18:00',
                            description: 'Nhắc nhở deadline và bài tập',
                          ),
                          const SizedBox(height: 8),
                          _buildTimeRangeItem(
                            context: context,
                            icon: Icons.nightlight,
                            title: 'Buổi tối',
                            time: '19:00 - 22:00',
                            description: 'Tóm tắt ngày và kế hoạch ngày mai',
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Test Notifications Section
                  Text(
                    'Kiểm tra thông báo',
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
                          title: 'Gửi thông báo test',
                          subtitle: 'Gửi thông báo để kiểm tra cài đặt',
                          onTap: _sendTestNotification,
                        ),
                        const Divider(),
                        _buildActionItem(
                          context: context,
                          icon: Icons.school,
                          title: 'Gửi nhắc nhở học tập',
                          subtitle: 'Gửi thông báo nhắc nhở học tập',
                          onTap: _sendStudyReminder,
                        ),
                        const Divider(),
                        _buildActionItem(
                          context: context,
                          icon: Icons.favorite,
                          title: 'Gửi tin nhắn động lực',
                          subtitle: 'Gửi tin nhắn khuyến khích học tập',
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
        title: '🧪 Thông báo test',
        body: 'Đây là thông báo test để kiểm tra cài đặt!',
        data: {
          'type': 'test_notification',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã gửi thông báo test!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi gửi thông báo: ${e.toString()}'),
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
            content: Text('Đã gửi nhắc nhở học tập!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi gửi nhắc nhở: ${e.toString()}'),
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
        message: 'Hôm nay là một ngày tuyệt vời để học tập và phát triển! 💪',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã gửi tin nhắn động lực!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi gửi tin nhắn: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 