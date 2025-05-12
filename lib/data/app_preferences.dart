import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kottab/models/user_model.dart';
import 'package:kottab/models/statistics_model.dart';

/// A service class for handling app preferences and persistent storage
class AppPreferences {
  static const String _userKey = 'user_data';
  static const String _statsKey = 'statistics_data';
  static const String _memorizedSetsKey = 'memorized_sets';

  /// Save user data to local storage
  static Future<bool> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  /// Load user data from local storage
  static Future<User?> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);

    if (userJson != null) {
      try {
        return User.fromJson(jsonDecode(userJson));
      } catch (e) {
        print('Error loading user data: $e');
        return null;
      }
    }

    return null;
  }

  /// Save statistics to local storage
  static Future<bool> saveStatistics(Statistics stats) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_statsKey, jsonEncode(stats.toJson()));
  }

  /// Load statistics from local storage
  static Future<Statistics> loadStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString(_statsKey);

    if (statsJson != null) {
      try {
        return Statistics.fromJson(jsonDecode(statsJson));
      } catch (e) {
        print('Error loading statistics data: $e');
      }
    }

    return Statistics.initial();
  }

  /// Save a list of memorized verse set IDs
  static Future<bool> saveMemorizedSets(List<String> setIds) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setStringList(_memorizedSetsKey, setIds);
  }

  /// Load the list of memorized verse set IDs
  static Future<List<String>> loadMemorizedSets() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_memorizedSetsKey) ?? [];
  }

  /// Get user settings value with type safety
  static Future<T?> getSetting<T>(String key, [T? defaultValue]) async {
    final user = await loadUser();
    if (user == null) return defaultValue;

    final value = user.settings[key];
    if (value != null && value is T) {
      return value;
    }

    return defaultValue;
  }

  /// Save a user setting
  static Future<bool> saveSetting(String key, dynamic value) async {
    final user = await loadUser();
    if (user == null) return false;

    final updatedSettings = Map<String, dynamic>.from(user.settings);
    updatedSettings[key] = value;

    final updatedUser = user.copyWith(settings: updatedSettings);
    return saveUser(updatedUser);
  }

  /// Clear all app data
  static Future<bool> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }
}