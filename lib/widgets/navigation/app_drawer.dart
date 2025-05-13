import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kottab/config/app_colors.dart';
import 'package:kottab/providers/settings_provider.dart';
import 'package:kottab/screens/help/help_screen.dart';
import 'package:kottab/screens/settings/settings_screen.dart';
import 'package:kottab/widgets/profile/profile_header.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Drawer(
        child: Consumer<SettingsProvider>(
          builder: (context, settingsProvider, child) {
            return Column(
              children: [
                // Profile header
                ProfileHeader(
                  user: settingsProvider.user,
                  onEditProfile: () {
                    Navigator.pop(context);
                    // TODO: Navigate to profile edit screen
                  },
                ),

                // Divider
                const Divider(height: 1),

                // Menu items
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      // Settings
                      _buildMenuItem(
                        context,
                        title: 'الإعدادات',
                        icon: Icons.settings,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const SettingsScreen()),
                          );
                        },
                      ),

                      // Help & Support
                      _buildMenuItem(
                        context,
                        title: 'مساعدة ودعم',
                        icon: Icons.help_outline,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const HelpScreen()),
                          );
                        },
                      ),

                      // About
                      _buildMenuItem(
                        context,
                        title: 'عن التطبيق',
                        icon: Icons.info_outline,
                        onTap: () {
                          Navigator.pop(context);
                          // TODO: Navigate to about screen
                          _showAboutDialog(context);
                        },
                      ),

                      // Reset data
                      _buildMenuItem(
                        context,
                        title: 'إعادة تعيين البيانات',
                        icon: Icons.delete_outline,
                        iconColor: Colors.red.shade700,
                        textColor: Colors.red.shade700,
                        onTap: () {
                          Navigator.pop(context);
                          _showResetDataConfirmation(context, settingsProvider);
                        },
                      ),
                    ],
                  ),
                ),

                // App version
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'الإصدار 1.0.0',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Build a menu item
  Widget _buildMenuItem(
      BuildContext context, {
        required String title,
        required IconData icon,
        required VoidCallback onTap,
        Color? iconColor,
        Color? textColor,
      }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? AppColors.primary,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: textColor ?? AppColors.textPrimary,
        ),
      ),
      onTap: onTap,
    );
  }

  /// Show about dialog
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('عن التطبيق'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // App logo
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.menu_book,
                size: 40,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 16),

            // App name
            Text(
              'كتّاب',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            // App description
            Text(
              'رفيقك في حفظ القرآن',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 16),

            // App version
            Text(
              'الإصدار 1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 16),

            // Copyright
            Text(
              '© 2025 كتّاب. جميع الحقوق محفوظة.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'إغلاق',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  /// Show reset data confirmation dialog
  void _showResetDataConfirmation(BuildContext context, SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعادة تعيين البيانات'),
        content: const Text(
          'هذا سيؤدي إلى حذف جميع بياناتك وإعادة تعيين التطبيق. هذا الإجراء لا يمكن التراجع عنه. هل أنت متأكد؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              await provider.resetAllData();
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تمت إعادة تعيين البيانات'),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red.shade700,
            ),
            child: const Text('إعادة تعيين'),
          ),
        ],
      ),
    );
  }
}