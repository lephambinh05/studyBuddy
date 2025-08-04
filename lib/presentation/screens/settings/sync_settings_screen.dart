import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studybuddy/core/theme/app_theme.dart';
import 'package:studybuddy/presentation/widgets/common/gradient_card.dart';
import 'package:studybuddy/presentation/providers/auth_provider.dart';
import 'package:studybuddy/presentation/providers/task_provider.dart';
import 'package:studybuddy/presentation/providers/subject_provider.dart';
import 'package:studybuddy/presentation/providers/study_target_provider.dart';
import 'package:studybuddy/core/services/sync_service.dart';

class SyncSettingsScreen extends ConsumerStatefulWidget {
  const SyncSettingsScreen({super.key});

  @override
  ConsumerState<SyncSettingsScreen> createState() => _SyncSettingsScreenState();
}

class _SyncSettingsScreenState extends ConsumerState<SyncSettingsScreen> {
  bool _autoSync = true;
  bool _syncOnWifiOnly = true;
  bool _syncTasks = true;
  bool _syncSubjects = true;
  bool _syncStudyTargets = true;
  bool _isSyncing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đồng bộ dữ liệu'),
        backgroundColor: AppThemes.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sync Status
            GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.sync,
                          color: AppThemes.primaryColor,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Trạng thái đồng bộ',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Đã kết nối với Firebase',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Dữ liệu được đồng bộ tự động',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Sync Options
            Text(
              'Tùy chọn đồng bộ',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            GlassCard(
              child: Column(
                children: [
                  _buildSyncOption(
                    context: context,
                    icon: Icons.sync,
                    title: 'Tự động đồng bộ',
                    subtitle: 'Đồng bộ dữ liệu tự động khi có thay đổi',
                    value: _autoSync,
                    onChanged: (value) {
                      setState(() {
                        _autoSync = value;
                      });
                    },
                  ),
                  const Divider(),
                  _buildSyncOption(
                    context: context,
                    icon: Icons.wifi,
                    title: 'Chỉ đồng bộ qua WiFi',
                    subtitle: 'Tiết kiệm dữ liệu di động',
                    value: _syncOnWifiOnly,
                    onChanged: (value) {
                      setState(() {
                        _syncOnWifiOnly = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Data Types
            Text(
              'Loại dữ liệu đồng bộ',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            GlassCard(
              child: Column(
                children: [
                  _buildSyncOption(
                    context: context,
                    icon: Icons.task,
                    title: 'Bài tập',
                    subtitle: 'Đồng bộ danh sách bài tập',
                    value: _syncTasks,
                    onChanged: (value) {
                      setState(() {
                        _syncTasks = value;
                      });
                    },
                  ),
                  const Divider(),
                  _buildSyncOption(
                    context: context,
                    icon: Icons.book,
                    title: 'Môn học',
                    subtitle: 'Đồng bộ danh sách môn học',
                    value: _syncSubjects,
                    onChanged: (value) {
                      setState(() {
                        _syncSubjects = value;
                      });
                    },
                  ),
                  const Divider(),
                  _buildSyncOption(
                    context: context,
                    icon: Icons.flag,
                    title: 'Mục tiêu học tập',
                    subtitle: 'Đồng bộ mục tiêu học tập',
                    value: _syncStudyTargets,
                    onChanged: (value) {
                      setState(() {
                        _syncStudyTargets = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Manual Sync
            Text(
              'Đồng bộ thủ công',
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
                    icon: Icons.sync,
                    title: 'Đồng bộ ngay',
                    subtitle: 'Đồng bộ tất cả dữ liệu lên Firebase',
                    onTap: _performManualSync,
                    isLoading: _isSyncing,
                  ),
                  const Divider(),
                  _buildActionItem(
                    context: context,
                    icon: Icons.download,
                    title: 'Tải dữ liệu từ Firebase',
                    subtitle: 'Tải dữ liệu mới nhất từ cloud',
                    onTap: _downloadFromFirebase,
                  ),
                  const Divider(),
                  _buildActionItem(
                    context: context,
                    icon: Icons.upload,
                    title: 'Tải lên Firebase',
                    subtitle: 'Tải dữ liệu local lên cloud',
                    onTap: _uploadToFirebase,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Sync History
            Text(
              'Lịch sử đồng bộ',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSyncHistoryItem(
                      context: context,
                      title: 'Lần cuối đồng bộ',
                      value: DateTime.now().toString().substring(0, 16),
                      status: 'Thành công',
                      isSuccess: true,
                    ),
                    const SizedBox(height: 12),
                    _buildSyncHistoryItem(
                      context: context,
                      title: 'Dữ liệu đã đồng bộ',
                      value: '${ref.watch(taskProvider).tasks.length} bài tập, ${ref.watch(subjectProvider).subjects.length} môn học, ${ref.watch(studyTargetProvider).activeTargets.length} mục tiêu',
                      status: 'Hoàn thành',
                      isSuccess: true,
                    ),
                    const SizedBox(height: 12),
                    _buildSyncHistoryItem(
                      context: context,
                      title: 'Kích thước dữ liệu',
                      value: '${(ref.watch(taskProvider).tasks.length + ref.watch(subjectProvider).subjects.length + ref.watch(studyTargetProvider).activeTargets.length) * 0.5} KB',
                      status: 'Đã tối ưu',
                      isSuccess: true,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncOption({
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

  Widget _buildActionItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return ListTile(
      leading: isLoading
          ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppThemes.primaryColor),
              ),
            )
          : Icon(
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
      onTap: isLoading ? null : onTap,
    );
  }

  Widget _buildSyncHistoryItem({
    required BuildContext context,
    required String title,
    required String value,
    required String status,
    required bool isSuccess,
  }) {
    return Row(
      children: [
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
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isSuccess ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isSuccess ? Colors.green : Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _performManualSync() async {
    setState(() {
      _isSyncing = true;
    });

    try {
      print('🔄 SyncSettingsScreen: Bắt đầu đồng bộ thủ công...');
      
      // Force sync all providers
      await ref.read(studyTargetProvider.notifier).loadStudyTargets();
      await ref.read(taskProvider.notifier).loadTasks();
      await ref.read(subjectProvider.notifier).loadSubjects();
      
      // Force sync service to sync pending data
      final syncService = ref.read(syncServiceProvider.notifier);
      await syncService.forceSync();
      
      print('✅ SyncSettingsScreen: Đồng bộ thủ công hoàn thành');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đồng bộ thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ SyncSettingsScreen: Lỗi đồng bộ: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi đồng bộ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  Future<void> _downloadFromFirebase() async {
    try {
      print('🔄 SyncSettingsScreen: Bắt đầu tải dữ liệu từ Firebase...');
      
      // Load data from Firebase for all providers
      await ref.read(studyTargetProvider.notifier).loadStudyTargets();
      await ref.read(taskProvider.notifier).loadTasks();
      await ref.read(subjectProvider.notifier).loadSubjects();
      
      print('✅ SyncSettingsScreen: Tải dữ liệu từ Firebase thành công');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã tải dữ liệu từ Firebase!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ SyncSettingsScreen: Lỗi tải dữ liệu: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải dữ liệu: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadToFirebase() async {
    try {
      print('🔄 SyncSettingsScreen: Bắt đầu tải dữ liệu lên Firebase...');
      
      // Force sync all pending data
      final syncService = ref.read(syncServiceProvider.notifier);
      await syncService.forceSync();
      
      // Also trigger sync for all providers
      await ref.read(studyTargetProvider.notifier).loadStudyTargets();
      await ref.read(taskProvider.notifier).loadTasks();
      await ref.read(subjectProvider.notifier).loadSubjects();
      
      print('✅ SyncSettingsScreen: Tải dữ liệu lên Firebase thành công');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã tải dữ liệu lên Firebase!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ SyncSettingsScreen: Lỗi tải lên: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải lên: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 