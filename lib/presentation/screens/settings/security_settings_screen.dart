import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studybuddy/core/theme/app_theme.dart';
import 'package:studybuddy/presentation/widgets/common/gradient_card.dart';
import 'package:studybuddy/presentation/providers/auth_provider.dart';

class SecuritySettingsScreen extends ConsumerStatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  ConsumerState<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends ConsumerState<SecuritySettingsScreen> {
  bool _biometricEnabled = false;
  bool _twoFactorEnabled = false;
  bool _autoLockEnabled = true;
  bool _showPassword = false;
  bool _isChangingPassword = false;

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authNotifierProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security'),
        backgroundColor: AppThemes.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Security Status
            GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.security,
                          color: AppThemes.primaryColor,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Security status',
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
                          'Account protected',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Email: ${authState.firebaseUser?.email ?? 'Chưa đăng nhập'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Authentication Methods
            Text(
              'Authentication methods',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            GlassCard(
              child: Column(
                children: [
                  _buildSecurityOption(
                    context: context,
                    icon: Icons.fingerprint,
                    title: 'Fingerprint / Face ID',
                    subtitle: 'Login with biometric',
                    value: _biometricEnabled,
                    onChanged: (value) {
                      setState(() {
                        _biometricEnabled = value;
                      });
                      _showBiometricDialog(context);
                    },
                  ),
                  const Divider(),
                  _buildSecurityOption(
                    context: context,
                    icon: Icons.verified_user,
                    title: 'Two-factor authentication',
                    subtitle: 'Secure account with 2FA',
                    value: _twoFactorEnabled,
                    onChanged: (value) {
                      setState(() {
                        _twoFactorEnabled = value;
                      });
                      _showTwoFactorDialog(context);
                    },
                  ),
                  const Divider(),
                  _buildSecurityOption(
                    context: context,
                    icon: Icons.lock_clock,
                    title: 'Auto-lock',
                    subtitle: 'Lock app after 5 minutes of inactivity',
                    value: _autoLockEnabled,
                    onChanged: (value) {
                      setState(() {
                        _autoLockEnabled = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Password Management
            Text(
              'Password management',
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
                    icon: Icons.lock_reset,
                    title: 'Change password',
                    subtitle: 'Change account password',
                    onTap: () => _showChangePasswordDialog(context),
                  ),
                  const Divider(),
                  _buildActionItem(
                    context: context,
                    icon: Icons.visibility,
                    title: 'Show password',
                    subtitle: 'Show password when entering',
                    onTap: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_showPassword ? 'Show password enabled' : 'Show password disabled'),
                          backgroundColor: AppThemes.primaryColor,
                        ),
                      );
                    },
                    trailing: Switch(
                      value: _showPassword,
                      onChanged: (value) {
                        setState(() {
                          _showPassword = value;
                        });
                      },
                      activeColor: AppThemes.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Privacy Settings
            Text(
                'Privacy settings',
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
                    icon: Icons.delete_forever,
                    title: 'Delete local data',
                    subtitle: 'Delete all data on this device',
                    onTap: () => _showClearDataDialog(context),
                  ),
                  const Divider(),
                  _buildActionItem(
                    context: context,
                    icon: Icons.history,
                    title: 'Delete activity history',
                    subtitle: 'Delete login and activity history',
                    onTap: () => _showClearHistoryDialog(context),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Security Log
            Text(
              'Security log',
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
                    _buildSecurityLogItem(
                      context: context,
                      title: 'Login successful',
                      time: 'Today, 14:30',
                      location: 'Hà Nội, Việt Nam',
                      isSuccess: true,
                    ),
                    const SizedBox(height: 12),
                    _buildSecurityLogItem(
                      context: context,
                      title: 'Change password',
                      time: 'Yesterday, 09:15',
                      location: 'Hà Nội, Việt Nam',
                      isSuccess: true,
                    ),
                    const SizedBox(height: 12),
                    _buildSecurityLogItem(
                      context: context,
                      title: 'Login from new device',
                      time: '2 days ago, 16:45',
                      location: 'TP.HCM, Việt Nam',
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

  Widget _buildSecurityOption({
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
    Widget? trailing,
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
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildSecurityLogItem({
    required BuildContext context,
    required String title,
    required String time,
    required String location,
    required bool isSuccess,
  }) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isSuccess ? Colors.green : Colors.red,
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
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                location,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showBiometricDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Biometric authentication'),
        content: const Text('Do you want to enable login with fingerprint or Face ID?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Biometric authentication enabled'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }

  void _showTwoFactorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Two-factor authentication'),
        content: const Text('Do you want to enable two-factor authentication to enhance security?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Two-factor authentication enabled'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _currentPasswordController,
              obscureText: !_showPassword,
              decoration: const InputDecoration(
                labelText: 'Current password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              obscureText: !_showPassword,
              decoration: const InputDecoration(
                labelText: 'New password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: !_showPassword,
              decoration: const InputDecoration(
                labelText: 'Confirm new password',
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
            onPressed: _isChangingPassword ? null : () async {
              await _changePassword(context);
            },
            child: _isChangingPassword
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Change password'),
          ),
        ],
      ),
    );
  }

  Future<void> _changePassword(BuildContext context) async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Confirm password does not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isChangingPassword = true;
    });

    try {
      // Simulate password change
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Clear controllers
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error changing password: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChangingPassword = false;
        });
      }
    }
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: const Text('Delete local data'),
        content: const Text('Are you sure you want to delete all data on this device? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Local data deleted'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete activity history'),
        content: const Text('Are you sure you want to delete login and activity history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Activity history deleted'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
} 