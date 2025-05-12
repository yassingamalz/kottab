import 'package:flutter/foundation.dart';
import 'package:kottab/data/app_preferences.dart';
import 'package:kottab/models/statistics_model.dart';
import 'package:kottab/models/user_model.dart';

/// Provider to manage user statistics data
class StatisticsProvider extends ChangeNotifier {
  Statistics _statistics = Statistics.initial();
  User? _user;
  bool _isLoading = true;

  StatisticsProvider() {
    _loadData();
  }

  /// Initialize by loading statistics from storage
  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _statistics = await AppPreferences.loadStatistics();
      _user = await AppPreferences.loadUser();
    } catch (e) {
      print('Error loading statistics: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Refresh the statistics data
  Future<void> refreshData() async {
    await _loadData();
  }

  /// Get the current statistics
  Statistics get statistics => _statistics;

  /// Get the current user
  User? get user => _user;

  /// Check if data is still loading
  bool get isLoading => _isLoading;

  /// Get weekly review pattern data
  List<MapEntry<String, int>> get weeklyPattern {
    // Convert the map to a sorted list of entries
    final weekdayOrder = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];

    final entries = _statistics.reviewsByDay.entries.toList();

    // Sort by weekday
    entries.sort((a, b) {
      final aIndex = weekdayOrder.indexOf(a.key);
      final bIndex = weekdayOrder.indexOf(b.key);
      return aIndex.compareTo(bIndex);
    });

    return entries;
  }

  /// Get the maximum number of reviews in a day
  int get maxDailyReviews {
    if (_statistics.reviewsByDay.isEmpty) return 0;

    return _statistics.reviewsByDay.values.reduce(
            (max, value) => max > value ? max : value
    );
  }

  /// Get the total number of reviews
  int get totalReviews => _statistics.totalReviews;

  /// Get the current streak
  int get currentStreak => _user?.streak ?? 0;

  /// Get the longest streak
  int get longestStreak => _statistics.longestStreak;

  /// Get the memorized percentage
  double get memorizedPercentage => _statistics.quranPercentage;

  /// Get the total memorized verses
  int get memorizedVerses => _statistics.totalMemorizedVerses;

  /// Get the most reviewed verse set
  String get mostReviewedSet => _statistics.mostReviewedSet;

  /// Get the most reviewed set count
  int get mostReviewedSetCount => _statistics.mostReviewedSetCount;

  /// Get the total days active
  int get daysActive => _statistics.daysActive;

  /// Get average review quality
  double get averageQuality => _statistics.averageReviewQuality;
}