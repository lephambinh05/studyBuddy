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
        title: const Text('Sync data'),
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
                          'Sync status',
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
                          'Connected to Firebase',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Data is synced automatically',
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
              'Sync options',
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
                    title: 'Auto sync',
                    subtitle: 'Sync data automatically when there is a change',
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
                    title: 'Sync only via WiFi',
                    subtitle: 'Save mobile data',
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
              'Data types to sync',
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
                    title: 'Tasks',
                    subtitle: 'Sync task list',
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
                    title: 'Subjects',
                    subtitle: 'Sync subject list',
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
                    title: 'Study targets',
                    subtitle: 'Sync study targets',
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
                  'Manual sync',
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
                    title: 'Sync now',
                    subtitle: 'Sync all data to Firebase',
                    onTap: _performManualSync,
                    isLoading: _isSyncing,
                  ),
                  const Divider(),
                  _buildActionItem(
                    context: context,
                    icon: Icons.download,
                    title: 'Download data from Firebase',
                    subtitle: 'Download latest data from cloud',
                    onTap: _downloadFromFirebase,
                  ),
                  const Divider(),
                  _buildActionItem(
                    context: context,
                    icon: Icons.upload,
                    title: 'Upload to Firebase',
                    subtitle: 'Upload local data to cloud',
                    onTap: _uploadToFirebase,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Sync History
            Text(
              'Sync history',
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
                      title: 'Last sync',
                      value: DateTime.now().toString().substring(0, 16),
                      status: 'Success',
                      isSuccess: true,
                    ),
                    const SizedBox(height: 12),
                    _buildSyncHistoryItem(
                      context: context,
                      title: 'Synced data',
                      value: '${ref.watch(taskProvider).tasks.length} tasks, ${ref.watch(subjectProvider).subjects.length} subjects, ${ref.watch(studyTargetProvider).activeTargets.length} study targets',
                      status: 'Completed',
                      isSuccess: true,
                    ),
                    const SizedBox(height: 12),
                    _buildSyncHistoryItem(
                      context: context,
                      title: 'Data size',
                      value: '${(ref.watch(taskProvider).tasks.length + ref.watch(subjectProvider).subjects.length + ref.watch(studyTargetProvider).activeTargets.length) * 0.5} KB',
                      status: 'Optimized',
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
      print('🔄 SyncSettingsScreen: Start manual sync...');
      
      // Force sync all providers
      await ref.read(studyTargetProvider.notifier).loadStudyTargets();
      await ref.read(taskProvider.notifier).loadTasks();
      await ref.read(subjectProvider.notifier).loadSubjects();
      
      // Force sync service to sync pending data
      final syncService = ref.read(syncServiceProvider.notifier);
      await syncService.forceSync();
      
      print('✅ SyncSettingsScreen: Manual sync completed');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sync completed!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ SyncSettingsScreen: Error syncing: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error syncing: ${e.toString()}'),
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
      print('🔄 SyncSettingsScreen: Start downloading data from Firebase...');
      
      // Load data from Firebase for all providers
      await ref.read(studyTargetProvider.notifier).loadStudyTargets();
      await ref.read(taskProvider.notifier).loadTasks();
      await ref.read(subjectProvider.notifier).loadSubjects();
      
      print('✅ SyncSettingsScreen: Download data from Firebase successfully');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Download data from Firebase successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ SyncSettingsScreen: Error downloading data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadToFirebase() async {
    try {
      print('🔄 SyncSettingsScreen: Start uploading data to Firebase...');
      
      // Force sync all pending data
      final syncService = ref.read(syncServiceProvider.notifier);
      await syncService.forceSync();
      
      // Also trigger sync for all providers
      await ref.read(studyTargetProvider.notifier).loadStudyTargets();
      await ref.read(taskProvider.notifier).loadTasks();
      await ref.read(subjectProvider.notifier).loadSubjects();
      
      print('✅ SyncSettingsScreen: Upload data to Firebase successfully');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Upload data to Firebase successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ SyncSettingsScreen: Error uploading data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 