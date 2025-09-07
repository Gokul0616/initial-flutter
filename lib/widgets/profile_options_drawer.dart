import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/theme.dart';
import '../screens/profile/edit_profile_screen.dart';

class ProfileOptionsDrawer extends StatelessWidget {
  const ProfileOptionsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.primarySurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: context.secondaryText,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Options list
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildOptionTile(
                  context,
                  icon: Icons.edit,
                  title: 'Edit Profile',
                  subtitle: 'Update your profile information',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    );
                  },
                ),
                
                _buildOptionTile(
                  context,
                  icon: Icons.qr_code,
                  title: 'QR Code',
                  subtitle: 'Share your profile',
                  onTap: () {
                    Navigator.pop(context);
                    _showQRCode(context);
                  },
                ),
                
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return _buildOptionTile(
                      context,
                      icon: Icons.palette,
                      title: 'Theme Settings',
                      subtitle: 'Current: ${themeProvider.themeName}',
                      onTap: () {
                        Navigator.pop(context);
                        _showThemeSelector(context);
                      },
                    );
                  },
                ),
                
                _buildOptionTile(
                  context,
                  icon: Icons.privacy_tip,
                  title: 'Privacy Settings',
                  subtitle: 'Manage your privacy',
                  onTap: () {
                    Navigator.pop(context);
                    _showPrivacySettings(context);
                  },
                ),
                
                _buildOptionTile(
                  context,
                  icon: Icons.notifications,
                  title: 'Notifications',
                  subtitle: 'Manage notifications',
                  onTap: () {
                    Navigator.pop(context);
                    _showNotificationSettings(context);
                  },
                ),
                
                _buildOptionTile(
                  context,
                  icon: Icons.security,
                  title: 'Security',
                  subtitle: 'Account security settings',
                  onTap: () {
                    Navigator.pop(context);
                    _showSecuritySettings(context);
                  },
                ),
                
                _buildOptionTile(
                  context,
                  icon: Icons.help,
                  title: 'Help & Support',
                  subtitle: 'Get help and support',
                  onTap: () {
                    Navigator.pop(context);
                    _showHelpSupport(context);
                  },
                ),
                
                _buildOptionTile(
                  context,
                  icon: Icons.info,
                  title: 'About',
                  subtitle: 'App information',
                  onTap: () {
                    Navigator.pop(context);
                    _showAbout(context);
                  },
                ),
                
                const Divider(height: 32),
                
                _buildOptionTile(
                  context,
                  icon: Icons.logout,
                  title: 'Log Out',
                  subtitle: 'Sign out of your account',
                  textColor: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    _showLogoutDialog(context);
                  },
                ),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: textColor ?? context.primaryText,
        size: 24,
      ),
      title: Text(
        title,
        style: AppTextStyles.titleMedium.copyWith(
          color: textColor ?? context.primaryText,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: context.secondaryText,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  void _showThemeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.primarySurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: context.secondaryText,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            Text(
              'Choose Theme',
              style: AppTextStyles.headlineSmall.copyWith(
                color: context.primaryText,
              ),
            ),
            const SizedBox(height: 20),
            
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return Column(
                  children: [
                    // Quick toggle for dark/light
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => themeProvider.toggleDarkLight(),
                            icon: Icon(themeProvider.isDarkMode 
                                ? Icons.light_mode 
                                : Icons.dark_mode),
                            label: Text(themeProvider.isDarkMode 
                                ? 'Switch to Light' 
                                : 'Switch to Dark'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.primarySurface,
                              foregroundColor: context.primaryText,
                              side: BorderSide(color: context.primaryBorder),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 20),
                    
                    Text(
                      'Theme Options',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: context.primaryText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Theme options grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 2.5,
                      ),
                      itemCount: themeProvider.availableThemes.length,
                      itemBuilder: (context, index) {
                        final theme = themeProvider.availableThemes[index];
                        final isSelected = theme == themeProvider.currentTheme;
                        
                        return _buildThemeOption(
                          context,
                          theme,
                          isSelected,
                          () {
                            themeProvider.setTheme(theme);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, 
    AppThemeType theme, 
    bool isSelected, 
    VoidCallback onTap
  ) {
    final themeColors = AppTheme._getThemeColors(theme);
    final themeName = _getThemeName(theme);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? themeColors['primary']!.withOpacity(0.1) : context.primarySurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? themeColors['primary']! : context.primaryBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: themeColors['primary']!.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Row(
          children: [
            // Theme color preview
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [themeColors['primary']!, themeColors['secondary']!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(width: 12),
            
            // Theme name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    themeName,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: isSelected ? themeColors['primary'] : context.primaryText,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (isSelected)
                    Text(
                      'Active',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: themeColors['primary'],
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ),
            
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: themeColors['primary'],
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  String _getThemeName(AppThemeType theme) {
    switch (theme) {
      case AppThemeType.darkClassic:
        return 'Dark Classic';
      case AppThemeType.lightClassic:
        return 'Light Classic';
      case AppThemeType.darkNeon:
        return 'Dark Neon';
      case AppThemeType.lightPastel:
        return 'Light Pastel';
      case AppThemeType.darkPurple:
        return 'Dark Purple';
      case AppThemeType.lightGreen:
        return 'Light Green';
      case AppThemeType.darkOrange:
        return 'Dark Orange';
      case AppThemeType.lightBlue:
        return 'Light Blue';
    }
  }

  void _showQRCode(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profile QR Code'),
        content: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(
              Icons.qr_code,
              size: 150,
              color: Colors.black,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              // Implement share functionality
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('QR Code shared!')),
              );
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  void _showPrivacySettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.primarySurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Settings',
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Private Account'),
              subtitle: const Text('Only followers can see your videos'),
              value: false,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Allow Downloads'),
              subtitle: const Text('Let others download your videos'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Allow Duets'),
              subtitle: const Text('Let others create duets with your videos'),
              value: true,
              onChanged: (value) {},
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.primarySurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification Settings',
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Push Notifications'),
              subtitle: const Text('Receive notifications on your device'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Likes'),
              subtitle: const Text('When someone likes your video'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Comments'),
              subtitle: const Text('When someone comments on your video'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('New Followers'),
              subtitle: const Text('When someone follows you'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Messages'),
              subtitle: const Text('When you receive a new message'),
              value: true,
              onChanged: (value) {},
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSecuritySettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.primarySurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Security Settings',
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.key),
              title: const Text('Change Password'),
              subtitle: const Text('Update your account password'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Two-Factor Authentication'),
              subtitle: const Text('Add extra security to your account'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.devices),
              title: const Text('Manage Devices'),
              subtitle: const Text('See devices where you\'re logged in'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Blocked Users'),
              subtitle: const Text('Manage blocked accounts'),
              onTap: () {},
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpSupport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.primarySurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Help & Support',
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('FAQ'),
              subtitle: const Text('Frequently asked questions'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.contact_support),
              title: const Text('Contact Support'),
              subtitle: const Text('Get help from our support team'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.bug_report),
              title: const Text('Report a Bug'),
              subtitle: const Text('Let us know about issues'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.feedback),
              title: const Text('Send Feedback'),
              subtitle: const Text('Share your thoughts'),
              onTap: () {},
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About TikTok Clone'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('Build: 1'),
            SizedBox(height: 16),
            Text('A modern TikTok clone built with Flutter and Node.js'),
            SizedBox(height: 16),
            Text('© 2024 TikTok Clone. All rights reserved.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Perform logout
              context.read<AuthProvider>().logout();
            },
            child: Text(
              'Log Out',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}