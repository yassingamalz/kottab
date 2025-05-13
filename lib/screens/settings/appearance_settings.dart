import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kottab/config/app_colors.dart';
import 'package:kottab/providers/settings_provider.dart';

class AppearanceSettings extends StatelessWidget {
  const AppearanceSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المظهر'),
        ),
        body: Consumer<SettingsProvider>(
          builder: (context, settingsProvider, child) {
            return ListView(
              children: [
                // Theme mode
                ListTile(
                  title: const Text('وضع السمة'),
                  subtitle: const Text('اختر بين الوضع الفاتح والداكن'),
                  trailing: DropdownButton<ThemeMode>(
                    value: settingsProvider.themeMode,
                    onChanged: (value) {
                      if (value != null) {
                        settingsProvider.setThemeMode(value);
                      }
                    },
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text('فاتح'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text('داكن'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text('النظام'),
                      ),
                    ],
                  ),
                ),

                // Text size - future enhancement
                ListTile(
                  enabled: false, // Disabled for now
                  title: const Text('حجم الخط'),
                  subtitle: const Text('ضبط حجم الخط في التطبيق'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('متوسط'),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),

                const Divider(height: 32),

                // Color scheme section
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'لون التطبيق الرئيسي',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

                // Color options - future enhancement
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildColorOption(
                      context,
                      color: AppColors.primary,
                      isSelected: true,
                    ),
                    _buildColorOption(
                      context,
                      color: Colors.blue,
                      isEnabled: false,
                    ),
                    _buildColorOption(
                      context,
                      color: Colors.purple,
                      isEnabled: false,
                    ),
                    _buildColorOption(
                      context,
                      color: Colors.amber.shade700,
                      isEnabled: false,
                    ),
                    _buildColorOption(
                      context,
                      color: Colors.red,
                      isEnabled: false,
                    ),
                    _buildColorOption(
                      context,
                      color: Colors.pink,
                      isEnabled: false,
                    ),
                    _buildColorOption(
                      context,
                      color: Colors.indigo,
                      isEnabled: false,
                    ),
                    _buildColorOption(
                      context,
                      color: Colors.cyan,
                      isEnabled: false,
                    ),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'المزيد من خيارات المظهر سيتم إضافتها في الإصدارات القادمة.',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Build a color option
  Widget _buildColorOption(
      BuildContext context, {
        required Color color,
        bool isSelected = false,
        bool isEnabled = true,
      }) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.4,
        child: InkWell(
          onTap: isEnabled ? () {} : null,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: isSelected
                ? const Icon(
              Icons.check,
              color: Colors.white,
            )
                : null,
          ),
        ),
      ),
    );
  }
}