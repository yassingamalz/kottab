import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kottab/config/app_colors.dart';
import 'package:kottab/providers/settings_provider.dart';
import 'package:kottab/screens/help/help_screen.dart';
import 'package:kottab/screens/settings/settings_screen.dart';
import 'package:kottab/screens/search_screen.dart';
import 'package:kottab/screens/stats_screen.dart';
import 'package:kottab/screens/achievements_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Drawer(
        child: Consumer<SettingsProvider>(
          builder: (context, settingsProvider, child) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                // Enhanced profile header
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _buildProfileHeader(context, settingsProvider),
                ),

                // Menu items with curved background
                Column(
                  children: [
                    // Add space for header
                    SizedBox(
                      height: 280, // Adjust this height based on header size
                    ),
                    
                    // Menu items container
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                        ),
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            const SizedBox(height: 8),
                            
                            // Settings
                            _buildMenuItem(
                              context,
                              title: 'الإعدادات',
                              icon: Icons.settings,
                              color: AppColors.primary,
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
                              color: AppColors.blue,
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
                              color: AppColors.purple,
                              onTap: () {
                                Navigator.pop(context);
                                _showAboutDialog(context);
                              },
                            ),
                            
                            // Notifications 
                            _buildMenuItem(
                              context,
                              title: 'الإشعارات',
                              icon: Icons.notifications_outlined,
                              color: Colors.amber.shade700,
                              onTap: () {
                                Navigator.pop(context);
                                // Navigate to notification settings
                              },
                            ),
                            
                            // Bookmarks
                            _buildMenuItem(
                              context,
                              title: 'المحفوظات',
                              icon: Icons.bookmark_outline,
                              color: AppColors.purple,
                              onTap: () {
                                Navigator.pop(context);
                                // Navigate to bookmarks
                              },
                            ),
                            
                            // Statistics
                            _buildMenuItem(
                              context,
                              title: 'الإحصائيات',
                              icon: Icons.bar_chart,
                              color: AppColors.blue,
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => const StatsScreen()),
                                );
                              },
                            ),
                            
                            // Achievements
                            _buildMenuItem(
                              context,
                              title: 'الإنجازات',
                              icon: Icons.emoji_events_outlined,
                              color: Colors.amber.shade700,
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => const AchievementsScreen()),
                                );
                              },
                            ),
                            
                            // Theme Mode
                            _buildMenuItem(
                              context,
                              title: settingsProvider.themeMode == ThemeMode.dark 
                                    ? 'الوضع الفاتح' 
                                    : 'الوضع الداكن',
                              icon: settingsProvider.themeMode == ThemeMode.dark 
                                    ? Icons.light_mode
                                    : Icons.dark_mode,
                              color: Colors.deepPurple,
                              onTap: () {
                                ThemeMode newMode = settingsProvider.themeMode == ThemeMode.dark 
                                    ? ThemeMode.light 
                                    : ThemeMode.dark;
                                settingsProvider.setThemeMode(newMode);
                                Navigator.pop(context);
                              },
                            ),

                            const Divider(
                              height: 40,
                              thickness: 1,
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
                    ),

                    // App version
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: const Color(0xFFF9FAFB),
                      child: Text(
                        'الإصدار 1.0.0',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Build enhanced profile header
  Widget _buildProfileHeader(BuildContext context, SettingsProvider provider) {
    final user = provider.user;
    final int streak = user?.streak ?? 0;
    final double quranProgress = (user?.quranProgress ?? 0) * 100;
    final int totalMemorizedVerses = user?.totalMemorizedVerses ?? 0;
    
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 32,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, Color(0xFF0D8060)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Column(
        children: [
          // User avatar, name and edit button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Edit profile button
              const Spacer(),
              IconButton(
                onPressed: () {
                  // Edit profile
                },
                icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                tooltip: 'تعديل الملف الشخصي',
              ),
            ],
          ),
          
          // Avatar with streak indicator
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppColors.primary,
                    size: 54,
                  ),
                ),
              ),
              if (streak > 0)
                Positioned(
                  bottom: -6,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$streak',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const Text(
                          ' يوم',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // User name
          Text(
            user?.name.isNotEmpty == true ? user!.name : 'ضيف',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Stats grid
          Row(
            children: [
              _buildStatItem(
                context,
                value: streak.toString(),
                label: 'يوم نشاط',
              ),
              _buildStatItem(
                context,
                value: '${quranProgress.toStringAsFixed(0)}%',
                label: 'من القرآن',
              ),
              _buildStatItem(
                context,
                value: totalMemorizedVerses.toString(),
                label: 'آية محفوظة',
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build a stat item for the profile header
  Widget _buildStatItem(
    BuildContext context, {
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build an enhanced menu item
  Widget _buildMenuItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
    Color? iconColor,
    Color? textColor,
  }) {
    final itemColor = iconColor ?? color ?? AppColors.primary;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            children: [
              // Icon with background
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: textColor != null 
                      ? Colors.red.shade50 
                      : color?.withOpacity(0.1) ?? AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: itemColor,
                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              // Title
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: textColor ?? AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Chevron icon
              Icon(
                Icons.chevron_right,
                color: textColor ?? AppColors.textSecondary,
                size: 18,
              ),
            ],
          ),
        ),
      ),
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
