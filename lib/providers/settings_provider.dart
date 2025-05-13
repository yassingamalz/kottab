import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kottab/data/app_preferences.dart';
import 'package:kottab/models/user_model.dart';

/// Provider to manage app settings
class SettingsProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = true;
  ThemeMode _themeMode = ThemeMode.light;
  bool _notificationsEnabled = true;
  bool _reminderNotificationsEnabled = true;
  bool _achievementNotificationsEnabled = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);

  SettingsProvider() {
    _loadData();
  }

  /// Initialize by loading user settings
  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await AppPreferences.loadUser();

      if (_user != null) {
        // Load theme mode
        final themeString = _user!.settings['theme'] as String? ?? 'light';
        _themeMode = _getThemeModeFromString(themeString);

        // Load notification settings
        _notificationsEnabled = _user!.settings['notifications'] as bool? ?? true;
        _reminderNotificationsEnabled = _user!.settings['reminderNotifications'] as bool? ?? true;
        _achievementNotificationsEnabled = _user!.settings['achievementNotifications'] as bool? ?? true;

        // Load reminder time
        final reminderHour = _user!.settings['reminderHour'] as int? ?? 20;
        final reminderMinute = _user!.settings['reminderMinute'] as int? ?? 0;
        _reminderTime = TimeOfDay(hour: reminderHour, minute: reminderMinute);
      }
    } catch (e) {
      print('Error loading settings: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Refresh settings data
  Future<void> refreshData() async {
    await _loadData();
  }

  /// Get the current user
  User? get user => _user;

  /// Check if data is still loading
  bool get isLoading => _isLoading;

  /// Get the current theme mode
  ThemeMode get themeMode => _themeMode;

  /// Check if notifications are enabled
  bool get notificationsEnabled => _notificationsEnabled;

  /// Check if reminder notifications are enabled
  bool get reminderNotificationsEnabled => _reminderNotificationsEnabled;

  /// Check if achievement notifications are enabled
  bool get achievementNotificationsEnabled => _achievementNotificationsEnabled;

  /// Get the reminder time
  TimeOfDay get reminderTime => _reminderTime;

  /// Update the theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;

    // Save to preferences
    if (_user != null) {
      await AppPreferences.saveSetting('theme', mode.toString().split('.').last);
    }

    notifyListeners();
  }

  /// Update notification settings
  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;

    // Save to preferences
    if (_user != null) {
      await AppPreferences.saveSetting('notifications', enabled);
    }

    notifyListeners();
  }

  /// Update reminder notification settings
  Future<void> setReminderNotificationsEnabled(bool enabled) async {
    _reminderNotificationsEnabled = enabled;

    // Save to preferences
    if (_user != null) {
      await AppPreferences.saveSetting('reminderNotifications', enabled);
    }

    notifyListeners();
  }

  /// Update achievement notification settings
  Future<void> setAchievementNotificationsEnabled(bool enabled) async {
    _achievementNotificationsEnabled = enabled;

    // Save to preferences
    if (_user != null) {
      await AppPreferences.saveSetting('achievementNotifications', enabled);
    }

    notifyListeners();
  }

  /// Update reminder time
  Future<void> setReminderTime(TimeOfDay time) async {
    _reminderTime = time;

    // Save to preferences
    if (_user != null) {
      await AppPreferences.saveSetting('reminderHour', time.hour);
      await AppPreferences.saveSetting('reminderMinute', time.minute);
    }

    notifyListeners();
  }

  /// Update user display name
  Future<void> setUserName(String name) async {
    if (_user == null) return;

    final updatedUser = _user!.copyWith(name: name);
    await AppPreferences.saveUser(updatedUser);
    _user = updatedUser;

    notifyListeners();
  }

  /// Reset all user data
  Future<void> resetAllData() async {
    await AppPreferences.clearAllData();

    // Create a new user
    final newUser = User.create();
    await AppPreferences.saveUser(newUser);
    _user = newUser;

    // Reset settings to defaults
    _themeMode = ThemeMode.light;
    _notificationsEnabled = true;
    _reminderNotificationsEnabled = true;
    _achievementNotificationsEnabled = true;
    _reminderTime = const TimeOfDay(hour: 20, minute: 0);

    notifyListeners();
  }

  /// Export user data as JSON
  Map<String, dynamic> exportUserData() {
    if (_user == null) {
      return {};
    }

    return _user!.toJson();
  }

  /// Get ThemeMode from string
  ThemeMode _getThemeModeFromString(String theme) {
    switch (theme) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      case 'light':
      default:
        return ThemeMode.light;
    }
  }
}