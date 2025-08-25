import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studybuddy/data/sources/remote/firebase_auth_service.dart';
import 'package:studybuddy/presentation/providers/auth_provider.dart';
import 'package:studybuddy/presentation/providers/task_provider.dart';
import 'package:studybuddy/presentation/providers/user_provider.dart';
import 'package:studybuddy/core/theme/app_theme.dart';

class CrudDemoScreen extends ConsumerStatefulWidget {
  const CrudDemoScreen({super.key});

  @override
  ConsumerState<CrudDemoScreen> createState() => _CrudDemoScreenState();
}

class _CrudDemoScreenState extends ConsumerState<CrudDemoScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _syncResult;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final taskState = ref.watch(taskProvider);
    final userState = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CRUD Demo & Admin Tools'),
        backgroundColor: AppThemes.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Authentication Status
            _buildStatusCard(
              'Authentication Status',
              [
                'Status: ${authState.status}',
                'User ID: ${authState.firebaseUser?.uid ?? 'None'}',
                'Email: ${authState.firebaseUser?.email ?? 'None'}',
                'Error: ${authState.errorMessage ?? 'None'}',
              ],
              authState.status == AuthStatus.authenticated ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 16),

            // User Status
            _buildStatusCard(
              'User Status',
              [
                'User: ${userState.user?.displayName ?? 'None'}',
                'Email: ${userState.user?.email ?? 'None'}',
                'Consecutive Days: ${userState.consecutiveDays}',
                'Error: ${userState.errorMessage ?? 'None'}',
              ],
              userState.user != null ? Colors.green : Colors.orange,
            ),
            const SizedBox(height: 16),

            // Task Status
            _buildStatusCard(
              'Task Status',
              [
                'Total Tasks: ${taskState.tasks.length}',
                'Completed: ${taskState.statistics['completedTasks'] ?? 0}',
                'Pending: ${taskState.statistics['pendingTasks'] ?? 0}',
                'Loading: ${taskState.isLoading}',
              ],
              Colors.blue,
            ),
            const SizedBox(height: 16),

            // Admin Tools
            _buildAdminTools(),
            const SizedBox(height: 16),

            // Results
            if (_syncResult != null) _buildSyncResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String title, List<String> items, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(item, style: const TextStyle(fontSize: 14)),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminTools() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.admin_panel_settings, color: AppThemes.primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Admin Tools',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppThemes.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Import All Users to Firebase Auth
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _importAllUsersToAuth,
              icon: const Icon(Icons.upload),
              label: const Text('Import All Users to Firebase Auth'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 8),

            // Cleanup Orphaned Users
            if (_syncResult != null && (_syncResult!['orphanedUsers'] ?? 0) > 0)
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _cleanupOrphanedUsers,
                icon: const Icon(Icons.clean_hands),
                label: Text('Cleanup ${_syncResult!['orphanedUsers']} Orphaned Users'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            const SizedBox(height: 8),

            // Recreate Missing User Data
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _recreateMissingUserData,
              icon: const Icon(Icons.person_add),
              label: const Text('Recreate Missing User Data'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 8),

            // Clear Error
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _clearError,
              icon: const Icon(Icons.clear),
              label: const Text('Clear Error Messages'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncResults() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: AppThemes.secondaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Import Results',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppThemes.secondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Total Users: ${_syncResult!['totalUsers']}'),
            Text('Successfully Imported: ${_syncResult!['successCount']}'),
            Text('Failed to Import: ${_syncResult!['failedCount']}'),
            if (_syncResult!['failedUserIds'] != null && (_syncResult!['failedUserIds'] as List<String>).isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('Failed User IDs:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...(_syncResult!['failedUserIds'] as List<String>).map((id) => 
                Text('  • $id', style: const TextStyle(fontSize: 12))
              ),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Text(
                '💡 Note: Users will receive password reset emails to set their own passwords.',
                style: TextStyle(fontSize: 12, color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkUserSync() async {
    setState(() => _isLoading = true);
    
    try {
      final firebaseAuthService = ref.read(firebaseAuthServiceProvider);
      final result = await firebaseAuthService.checkAndFixUserSync();
      
      setState(() {
        _syncResult = result;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync check completed: ${result['totalFirestoreUsers']} total, ${result['orphanedUsers']} orphaned'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking sync: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _importAllUsersToAuth() async {
    setState(() => _isLoading = true);
    
    try {
      final firebaseAuthService = ref.read(firebaseAuthServiceProvider);
      final result = await firebaseAuthService.importAllUsersToAuth();
      
      setState(() {
        _syncResult = result;
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import completed: ${result['successCount']} successful, ${result['failedCount']} failed'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error importing users: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _cleanupOrphanedUsers() async {
    if (_syncResult == null || (_syncResult!['orphanedUserIds'] as List<String>).isEmpty) {
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final firebaseAuthService = ref.read(firebaseAuthServiceProvider);
      await firebaseAuthService.cleanupOrphanedUsers(_syncResult!['orphanedUserIds'] as List<String>);
      
      // Refresh sync results
      await _checkUserSync();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Orphaned users cleaned up successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cleaning up orphaned users: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _recreateMissingUserData() async {
    setState(() => _isLoading = true);
    
    try {
      final firebaseAuthService = ref.read(firebaseAuthServiceProvider);
      await firebaseAuthService.recreateMissingUserData();
      
      // Refresh user data
      await ref.read(userProvider.notifier).loadCurrentUser();
      
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Missing user data recreated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error recreating user data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearError() async {
    ref.read(authNotifierProvider.notifier).clearError();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error messages cleared'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
} 