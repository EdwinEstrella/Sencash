import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              _showComingSoonDialog('Settings');
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;

          if (user == null) {
            return const Center(
              child: Text('User not found'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                _buildProfileHeader(user),
                const SizedBox(height: 24),

                // Profile Information
                _buildProfileInformation(user),
                const SizedBox(height: 24),

                // Account Settings
                _buildAccountSettings(),
                const SizedBox(height: 24),

                // Security Settings
                _buildSecuritySettings(),
                const SizedBox(height: 24),

                // Support
                _buildSupport(),
                const SizedBox(height: 24),

                // Logout Button
                _buildLogoutButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(dynamic user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Text(
              _getInitials(user.fullName),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.fullName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            user.email,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          if (user.isKycVerified)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Verified',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileInformation(dynamic user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Information',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        _buildInfoTile(
          'Full Name',
          user.fullName,
          Icons.person_outline,
        ),
        _buildInfoTile(
          'Email',
          user.email,
          Icons.email_outlined,
        ),
        _buildInfoTile(
          'Phone',
          user.phoneNumber,
          Icons.phone_outlined,
        ),
        _buildInfoTile(
          'Member Since',
          _formatDate(user.createdAt),
          Icons.calendar_today_outlined,
        ),
      ],
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
          if (title == 'Full Name' || title == 'Phone')
            Icon(
              Icons.edit_outlined,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              size: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildAccountSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Settings',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        _buildSettingTile(
          'Edit Profile',
          'Update your personal information',
          Icons.person_outline,
          () {
            _showComingSoonDialog('Edit Profile');
          },
        ),
        _buildSettingTile(
          'Notification Preferences',
          'Manage your notification settings',
          Icons.notifications_outlined,
          () {
            _showComingSoonDialog('Notification Preferences');
          },
        ),
        _buildSettingTile(
          'Privacy Settings',
          'Control your privacy preferences',
          Icons.lock_outline,
          () {
            _showComingSoonDialog('Privacy Settings');
          },
        ),
      ],
    );
  }

  Widget _buildSecuritySettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Security',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        _buildSettingTile(
          'Change Password',
          'Update your account password',
          Icons.lock_outline,
          () {
            _showChangePasswordDialog();
          },
        ),
        _buildSettingTile(
          'Two-Factor Authentication',
          'Add an extra layer of security',
          Icons.security,
          () {
            _showComingSoonDialog('Two-Factor Authentication');
          },
        ),
        Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return _buildSettingTile(
              'Biometric Authentication',
              'Use fingerprint or face recognition',
              Icons.fingerprint,
              () {
                _toggleBiometricAuth();
              },
              trailing: Switch(
                value: false,
                onChanged: (value) {
                  _toggleBiometricAuth();
                },
                activeThumbColor: Theme.of(context).colorScheme.primary,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSupport() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Support',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        _buildSettingTile(
          'Help Center',
          'Get help and support',
          Icons.help_outline,
          () {
            _showComingSoonDialog('Help Center');
          },
        ),
        _buildSettingTile(
          'Contact Us',
          'Get in touch with our team',
          Icons.mail_outline,
          () {
            _showComingSoonDialog('Contact Us');
          },
        ),
        _buildSettingTile(
          'Terms and Conditions',
          'Read our terms and conditions',
          Icons.description_outlined,
          () {
            _showComingSoonDialog('Terms and Conditions');
          },
        ),
        _buildSettingTile(
          'Privacy Policy',
          'Read our privacy policy',
          Icons.privacy_tip_outlined,
          () {
            _showComingSoonDialog('Privacy Policy');
          },
        ),
      ],
    );
  }

  Widget _buildSettingTile(
    String title,
    String description,
    IconData icon,
    VoidCallback onTap, {
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
        ],
      ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: OutlinedButton(
        onPressed: _handleLogout,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(
            color: Colors.red.withValues(alpha: 0.5),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Log Out',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  String _getInitials(String fullName) {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0][0].toUpperCase();
    } else {
      return '?';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().logout();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    }
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return ElevatedButton(
                onPressed: authProvider.isLoading ? null : () async {
                  if (currentPasswordController.text.isNotEmpty &&
                      newPasswordController.text.isNotEmpty &&
                      confirmPasswordController.text.isNotEmpty &&
                      newPasswordController.text == confirmPasswordController.text) {
                    final success = await authProvider.changePassword(
                      currentPassword: currentPasswordController.text,
                      newPassword: newPasswordController.text,
                    );

                    if (success) {
                      if (mounted) {
                        Navigator.of(context).pop();
                      }
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Password changed successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  }
                },
                child: authProvider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Change'),
              );
            },
          ),
        ],
      ),
    );
  }

  void _toggleBiometricAuth() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Biometric authentication feature coming soon'),
      ),
    );
  }

  void _showComingSoonDialog(String featureName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon'),
        content: Text('$featureName feature coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}