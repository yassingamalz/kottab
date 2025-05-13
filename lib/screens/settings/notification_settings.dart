import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kottab/providers/settings_provider.dart';

class NotificationSettings extends StatelessWidget {
  const NotificationSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الإشعارات'),
        ),
        body: Consumer<SettingsProvider>(
          builder: (context, settingsProvider, child) {
            return ListView(
              children: [
                // Enable all notifications
                SwitchListTile(
                  title: const Text('تفعيل الإشعارات'),
                  subtitle: const Text('إيقاف هذا الخيار سيمنع جميع الإشعارات'),
                  value: settingsProvider.notificationsEnabled,
                  onChanged: (value) {
                    settingsProvider.setNotificationsEnabled(value);
                  },
                ),

                const Divider(),

                // Reminder notifications
                SwitchListTile(
                  title: const Text('تذكير يومي'),
                  subtitle: const Text('تذكير لمتابعة الحفظ والمراجعة'),
                  value: settingsProvider.reminderNotificationsEnabled &&
                      settingsProvider.notificationsEnabled,
                  onChanged: settingsProvider.notificationsEnabled
                      ? (value) {
                    settingsProvider.setReminderNotificationsEnabled(value);
                  }
                      : null,
                ),

                // Reminder time
                ListTile(
                  enabled: settingsProvider.reminderNotificationsEnabled &&
                      settingsProvider.notificationsEnabled,
                  title: const Text('وقت التذكير'),
                  subtitle: Text(
                    _formatTimeOfDay(settingsProvider.reminderTime),
                  ),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: settingsProvider.reminderTime,
                    );

                    if (time != null) {
                      settingsProvider.setReminderTime(time);
                    }
                  },
                ),

                const Divider(),

                // Achievement notifications
                SwitchListTile(
                  title: const Text('إشعارات الإنجازات'),
                  subtitle: const Text('إشعارات عند تحقيق إنجاز جديد'),
                  value: settingsProvider.achievementNotificationsEnabled &&
                      settingsProvider.notificationsEnabled,
                  onChanged: settingsProvider.notificationsEnabled
                      ? (value) {
                    settingsProvider.setAchievementNotificationsEnabled(value);
                  }
                      : null,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Format TimeOfDay to string
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}