import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kottab/config/app_colors.dart';
import 'package:kottab/providers/settings_provider.dart';
import 'package:kottab/widgets/shared/custom_snackbar.dart';

class DataSettings extends StatelessWidget {
  const DataSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('البيانات والنسخ الاحتياطي'),
        ),
        body: Consumer<SettingsProvider>(
          builder: (context, settingsProvider, child) {
            return ListView(
              children: [
                // Backup and restore section
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'النسخ الاحتياطي والاستعادة',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

                // Export data
                _buildDataOption(
                  context,
                  title: 'تصدير البيانات',
                  subtitle: 'تصدير بياناتك لملف',
                  icon: Icons.upload_file,
                  onTap: () {
                    _showExportDialog(context, settingsProvider);
                  },
                ),

                // Import data
                _buildDataOption(
                  context,
                  title: 'استيراد البيانات',
                  subtitle: 'استيراد بياناتك من ملف',
                  icon: Icons.download,
                  onTap: () {
                    // TODO: Implement import functionality
                    _showFeatureComingSoonDialog(context);
                  },
                ),

                const Divider(height: 32),

                // Data management section
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'إدارة البيانات',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

                // Update profile
                _buildDataOption(
                  context,
                  title: 'تحديث بيانات الملف الشخصي',
                  subtitle: 'تغيير اسمك وإعدادات أخرى',
                  icon: Icons.person,
                  onTap: () {
                    _showUpdateProfileDialog(context, settingsProvider);
                  },
                ),

                // Reset data
                _buildDataOption(
                  context,
                  title: 'إعادة تعيين البيانات',
                  subtitle: 'حذف جميع بياناتك وإعادة تعيين التطبيق',
                  icon: Icons.delete_forever,
                  iconColor: Colors.red.shade700,
                  onTap: () {
                    _showResetDataConfirmation(context, settingsProvider);
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Build a data option
  Widget _buildDataOption(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required VoidCallback onTap,
        Color? iconColor,
      }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? AppColors.primary,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  /// Show export dialog
  void _showExportDialog(BuildContext context, SettingsProvider provider) {
    // In a real app, this would handle actual file export
    // For now, just show a mock dialog

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تصدير البيانات'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: AppColors.primary,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              'تم تصدير بياناتك بنجاح',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  /// Show update profile dialog
  void _showUpdateProfileDialog(BuildContext context, SettingsProvider provider) {
    final nameController = TextEditingController();
    nameController.text = provider.user?.name ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تحديث الملف الشخصي'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'الاسم',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'ستتم إضافة المزيد من الخيارات في الإصدارات القادمة.',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              provider.setUserName(nameController.text);
              Navigator.of(context).pop();
              showCustomSnackBar(
                context: context,
                message: 'تم تحديث الملف الشخصي',
                type: SnackBarType.success,
              );
            },
            child: const Text('حفظ'),
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
                showCustomSnackBar(
                  context: context,
                  message: 'تمت إعادة تعيين البيانات',
                  type: SnackBarType.success,
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

  /// Show feature coming soon dialog
  void _showFeatureComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('قادم قريباً'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.engineering,
              color: AppColors.primary,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              'هذه الميزة قادمة في الإصدارات القادمة. ترقبوا المزيد!',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }
}