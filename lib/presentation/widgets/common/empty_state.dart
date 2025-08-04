import 'package:flutter/material.dart';
import 'package:studybuddy/core/theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onActionPressed;
  final String? actionText;

  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.onActionPressed,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppThemes.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppThemes.primaryColor.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: 40,
                color: AppThemes.primaryColor,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Title
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppThemes.textPrimaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Message
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppThemes.textSecondaryColor,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            if (onActionPressed != null && actionText != null) ...[
              const SizedBox(height: 32),
              
              // Action Button
              Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppThemes.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppThemes.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onActionPressed,
                    borderRadius: BorderRadius.circular(12),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            actionText!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Empty state cho Tasks
class EmptyTasksState extends StatelessWidget {
  final VoidCallback? onAddTask;

  const EmptyTasksState({
    super.key,
    this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: 'Chưa có bài tập nào',
      message: 'Bạn chưa có bài tập nào được tạo. Hãy thêm bài tập đầu tiên để bắt đầu học tập!',
      icon: Icons.assignment_outlined,
      onActionPressed: onAddTask,
      actionText: 'Thêm bài tập',
    );
  }
}

// Empty state cho Events
class EmptyEventsState extends StatelessWidget {
  final VoidCallback? onAddEvent;

  const EmptyEventsState({
    super.key,
    this.onAddEvent,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: 'Chưa có sự kiện nào',
      message: 'Bạn chưa có sự kiện nào được lên lịch. Hãy thêm sự kiện đầu tiên để quản lý thời gian!',
      icon: Icons.event_outlined,
      onActionPressed: onAddEvent,
      actionText: 'Thêm sự kiện',
    );
  }
}

// Empty state cho Notifications
class EmptyNotificationsState extends StatelessWidget {
  const EmptyNotificationsState({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: 'Chưa có thông báo nào',
      message: 'Bạn chưa có thông báo nào. Các thông báo về bài tập và sự kiện sẽ xuất hiện ở đây.',
      icon: Icons.notifications_outlined,
    );
  }
}

// Empty state cho Search Results
class EmptySearchState extends StatelessWidget {
  final String searchTerm;

  const EmptySearchState({
    super.key,
    required this.searchTerm,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: 'Không tìm thấy kết quả',
      message: 'Không có kết quả nào cho "$searchTerm". Hãy thử tìm kiếm với từ khóa khác.',
      icon: Icons.search_off_outlined,
    );
  }
} 