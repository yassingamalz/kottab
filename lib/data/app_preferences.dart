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
    try {
      final userJson = jsonEncode(user.toJson());
      return prefs.setString(_userKey, userJson);
    } catch (e) {
      print('Error saving user data: $e');
      return false;
    }
  }

  /// Load user data from local storage
  static Future<User?> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);

    if (userJson != null && userJson.isNotEmpty) {
      try {
        return User.fromJson(jsonDecode(userJson));
      } catch (e) {
        print('Error loading user data: $e');
        // Create a new user if the data is corrupted
        return User.create();
      }
    }

    // Create a new user if none exists
    return User.create();
  }

  /// Save statistics to local storage
  static Future<bool> saveStatistics(Statistics stats) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final statsJson = jsonEncode(stats.toJson());
      return prefs.setString(_statsKey, statsJson);
    } catch (e) {
      print('Error saving statistics data: $e');
      return false;
    }
  }

  /// Load statistics from local storage
  static Future<Statistics> loadStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString(_statsKey);

    if (statsJson != null && statsJson.isNotEmpty) {
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
    try {
      // Ensure unique entries
      final uniqueIds = setIds.toSet().toList();
      return prefs.setStringList(_memorizedSetsKey, uniqueIds);
    } catch (e) {
      print('Error saving memorized sets: $e');
      return false;
    }
  }

  /// Load the list of memorized verse set IDs
  static Future<List<String>> loadMemorizedSets() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_memorizedSetsKey);
    if (ids != null) {
      // Ensure unique IDs
      return ids.toSet().toList();
    }
    return [];
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
    try {
      await prefs.remove(_userKey);
      await prefs.remove(_statsKey);
      await prefs.remove(_memorizedSetsKey);
      // Or use this to remove all keys:
      // await prefs.clear();
      return true;
    } catch (e) {
      print('Error clearing app data: $e');
      return false;
    }
  }
}
