import 'package:flutter/material.dart';
import 'package:studybuddy/core/theme/app_theme.dart';
import 'package:studybuddy/presentation/widgets/common/gradient_card.dart';

class TaskCard extends StatelessWidget {
  final String title;
  final String? description;
  final String subject;
  final DateTime deadline;
  final bool isCompleted;
  final int priority;
  final bool isLoading;
  final VoidCallback? onTap;
  final VoidCallback? onToggleComplete;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TaskCard({
    super.key,
    required this.title,
    this.description,
    required this.subject,
    required this.deadline,
    required this.isCompleted,
    required this.priority,
    this.isLoading = false,
    this.onTap,
    this.onToggleComplete,
    this.onEdit,
    this.onDelete,
  });

  Color _getPriorityColor() {
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

  String _getPriorityText() {
    switch (priority) {
      case 1:
        return 'Cao';
      case 2:
        return 'Trung bình';
      case 3:
        return 'Thấp';
      default:
        return 'Bình thường';
    }
  }

  String _getTimeRemaining() {
    final now = DateTime.now();
    final difference = deadline.difference(now);
    
    if (difference.isNegative) {
      return 'Đã trễ hạn';
    }
    
    final days = difference.inDays;
    final hours = difference.inHours % 24;
    
    if (days > 0) {
      return 'Còn $days ngày';
    } else if (hours > 0) {
      return 'Còn $hours giờ';
    } else {
      return 'Còn ${difference.inMinutes} phút';
    }
  }

  bool _isOverdue() {
    final now = DateTime.now();
    return deadline.isBefore(now);
  }

  Color _getTimeRemainingColor() {
    final now = DateTime.now();
    final difference = deadline.difference(now);
    
    if (difference.isNegative) {
      return AppThemes.errorColor;
    }
    
    final days = difference.inDays;
    if (days <= 1) {
      return AppThemes.errorColor;
    } else if (days <= 3) {
      return AppThemes.warningColor;
    } else {
      return AppThemes.accentColor;
    }
  }

  void _showOverdueDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: AppThemes.errorColor,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text('Bài tập đã trễ hạn'),
          ],
        ),
        content: Text(
          'Bài tập "$title" đã quá hạn deadline (${deadline.day}/${deadline.month}/${deadline.year}). '
          'Bạn không thể đánh dấu hoàn thành cho bài tập đã trễ hạn.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GlassCard(
      onTap: onTap,
      backgroundColor: isCompleted ? AppThemes.cardColor : AppThemes.surfaceColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Checkbox with overdue handling
              GestureDetector(
                onTap: isLoading 
                    ? null 
                    : (_isOverdue() && !isCompleted 
                        ? () => _showOverdueDialog(context)
                        : onToggleComplete),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted 
                          ? AppThemes.primaryColor 
                          : _isOverdue() 
                              ? AppThemes.errorColor 
                              : AppThemes.textLightColor,
                      width: 2,
                    ),
                    color: isCompleted ? AppThemes.primaryColor : Colors.transparent,
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppThemes.primaryColor,
                            ),
                          ),
                        )
                      : isCompleted
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : _isOverdue() && !isCompleted
                              ? Icon(
                                  Icons.warning,
                                  size: 16,
                                  color: AppThemes.errorColor,
                                )
                              : null,
                ),
              ),
              const SizedBox(width: 12),
              
              // Title and subject
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                        color: isCompleted ? AppThemes.textSecondaryColor : AppThemes.textPrimaryColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppThemes.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            subject,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppThemes.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getPriorityColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getPriorityText(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _getPriorityColor(),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Action buttons
              if (!isCompleted) ...[
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: AppThemes.textSecondaryColor,
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit?.call();
                        break;
                      case 'delete':
                        onDelete?.call();
                        break;
                      case 'complete':
                        if (_isOverdue()) {
                          _showOverdueDialog(context);
                        } else {
                          onToggleComplete?.call();
                        }
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'complete',
                      child: Row(
                        children: [
                          Icon(
                            _isOverdue() ? Icons.warning : Icons.check_circle,
                            size: 20,
                            color: _isOverdue() ? AppThemes.errorColor : AppThemes.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isOverdue() ? 'Đã trễ hạn' : 'Hoàn thành',
                            style: TextStyle(
                              color: _isOverdue() ? AppThemes.errorColor : AppThemes.textPrimaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20, color: AppThemes.textPrimaryColor),
                          const SizedBox(width: 8),
                          Text('Chỉnh sửa', style: TextStyle(color: AppThemes.textPrimaryColor)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: AppThemes.errorColor),
                          const SizedBox(width: 8),
                          Text('Xóa', style: TextStyle(color: AppThemes.errorColor)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          
          if (description != null && description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              description!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppThemes.textSecondaryColor,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          
          const SizedBox(height: 12),
          
          // Deadline and time remaining
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 16,
                color: _getTimeRemainingColor(),
              ),
              const SizedBox(width: 4),
              Text(
                '${deadline.day}/${deadline.month}/${deadline.year}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppThemes.textSecondaryColor,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getTimeRemainingColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _getTimeRemaining(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _getTimeRemainingColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TaskCardCompact extends StatelessWidget {
  final String title;
  final String subject;
  final DateTime deadline;
  final bool isCompleted;
  final int priority;
  final VoidCallback? onTap;
  final VoidCallback? onToggleComplete;

  const TaskCardCompact({
    super.key,
    required this.title,
    required this.subject,
    required this.deadline,
    required this.isCompleted,
    required this.priority,
    this.onTap,
    this.onToggleComplete,
  });

  Color _getPriorityColor() {
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

  bool _isOverdue() {
    final now = DateTime.now();
    return deadline.isBefore(now);
  }

  void _showOverdueDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: AppThemes.errorColor,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text('Bài tập đã trễ hạn'),
          ],
        ),
        content: Text(
          'Bài tập "$title" đã quá hạn deadline (${deadline.day}/${deadline.month}/${deadline.year}). '
          'Bạn không thể đánh dấu hoàn thành cho bài tập đã trễ hạn.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GlassCard(
      onTap: onTap,
      backgroundColor: isCompleted ? AppThemes.cardColor : AppThemes.surfaceColor,
      child: Row(
        children: [
          // Checkbox with overdue handling
          GestureDetector(
            onTap: _isOverdue() && !isCompleted 
                ? () => _showOverdueDialog(context)
                : onToggleComplete,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted 
                      ? AppThemes.primaryColor 
                      : _isOverdue() 
                          ? AppThemes.errorColor 
                          : AppThemes.textLightColor,
                  width: 2,
                ),
                color: isCompleted ? AppThemes.primaryColor : Colors.transparent,
              ),
              child: isCompleted
                  ? const Icon(
                      Icons.check,
                      size: 12,
                      color: Colors.white,
                    )
                  : _isOverdue() && !isCompleted
                      ? Icon(
                          Icons.warning,
                          size: 12,
                          color: AppThemes.errorColor,
                        )
                      : null,
            ),
          ),
          const SizedBox(width: 12),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted ? AppThemes.textSecondaryColor : AppThemes.textPrimaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      subject,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppThemes.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _getPriorityColor(),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${deadline.day}/${deadline.month}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _isOverdue() ? AppThemes.errorColor : AppThemes.textSecondaryColor,
                        fontWeight: _isOverdue() ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
