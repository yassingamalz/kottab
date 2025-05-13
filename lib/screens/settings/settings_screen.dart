import 'package:flutter/material.dart';
import 'package:kottab/config/app_colors.dart';
import 'package:kottab/screens/settings/appearance_settings.dart';
import 'package:kottab/screens/settings/notification_settings.dart';
import 'package:kottab/screens/settings/data_settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الإعدادات'),
        ),
        body: ListView(
          children: [
            // Appearance settings
            _buildSettingsSection(
              context,
              title: 'المظهر',
              icon: Icons.palette_outlined,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AppearanceSettings()),
                );
              },
            ),

            const Divider(height: 1),

            // Notification settings
            _buildSettingsSection(
              context,
              title: 'الإشعارات',
              icon: Icons.notifications_outlined,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const NotificationSettings()),
                );
              },
            ),

            const Divider(height: 1),

            // Data & backup settings
            _buildSettingsSection(
              context,
              title: 'البيانات والنسخ الاحتياطي',
              icon: Icons.backup_outlined,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const DataSettings()),
                );
              },
            ),

            const Divider(height: 1),
          ],
        ),
      ),
    );
  }

  /// Build a settings section
  Widget _buildSettingsSection(
      BuildContext context, {
        required String title,
        required IconData icon,
        required VoidCallback onTap,
      }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.primary,
      ),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}