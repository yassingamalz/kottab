import 'package:flutter/foundation.dart';
import 'package:kottab/data/app_preferences.dart';
import 'package:kottab/models/verse_set_model.dart';
import 'package:kottab/services/memorization_service.dart';

/// Type of memorization session
enum SessionType {
  newMemorization,
  recentReview,
  oldReview,
}

/// Model for a scheduled memorization session
class ScheduledSession {
  final int surahId;
  final String surahName;
  final int startVerse;
  final int endVerse;
  final SessionType type;
  final bool isCompleted;

  const ScheduledSession({
    required this.surahId,
    required this.surahName,
    required this.startVerse,
    required this.endVerse,
    required this.type,
    this.isCompleted = false,
  });

  /// Get the verse range as a formatted string
  String get verseRange => '$startVerse-$endVerse';
}

/// Model for a day's schedule
class DaySchedule {
  final DateTime date;
  final bool isToday;
  final List<ScheduledSession> sessions;

  const DaySchedule({
    required this.date,
    this.isToday = false,
    this.sessions = const [],
  });
}

/// Provider to manage memorization schedule
class ScheduleProvider extends ChangeNotifier {
  final MemorizationService _memorizationService = MemorizationService();

  List<DaySchedule> _weekSchedule = [];
  bool _isLoading = true;
  Map<String, dynamic> _settings = {};

  ScheduleProvider() {
    _loadData();
  }

  /// Initialize by loading schedule data
  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load user settings
      final user = await _memorizationService.getUser();
      _settings = Map<String, dynamic>.from(user.settings);

      // Generate this week's schedule
      _weekSchedule = await _generateWeekSchedule();
    } catch (e) {
      print('Error loading schedule: $e');
      // Create empty schedule if there's an error
      _weekSchedule = _generateEmptyWeekSchedule();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Refresh the schedule data
  Future<void> refreshData() async {
    await _loadData();
  }

  /// Get the week schedule
  List<DaySchedule> get weekSchedule => _weekSchedule;

  /// Get user settings
  Map<String, dynamic> get settings => _settings;

  /// Check if data is still loading
  bool get isLoading => _isLoading;

  /// Get the number of verses to memorize daily
  int get dailyVerseTarget => _settings['dailyVerseTarget'] ?? 10;

  /// Get the size of recent review sets
  int get reviewSetSize => _settings['reviewSetSize'] ?? 20;

  /// Get the cycle for older reviews
  int get oldReviewCycle => _settings['oldReviewCycle'] ?? 5;

  /// Update a setting value
  Future<void> updateSetting(String key, dynamic value) async {
    await AppPreferences.saveSetting(key, value);
    _settings[key] = value;
    notifyListeners();

    // Regenerate schedule with new settings
    await refreshData();
  }

  /// Generate an empty week schedule
  List<DaySchedule> _generateEmptyWeekSchedule() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return List.generate(7, (index) {
      final date = today.add(Duration(days: index));
      return DaySchedule(
        date: date,
        isToday: index == 0,
        sessions: [],
      );
    });
  }

  /// Generate the week schedule based on memorization plan
  Future<List<DaySchedule>> _generateWeekSchedule() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekSchedule = <DaySchedule>[];

    // Generate today's plan
    final todayPlan = await _memorizationService.generateTodayPlan();

    // Format sessions for today
    final todaySessions = <ScheduledSession>[];

    // Add new memorization sessions
    for (final verseSet in todayPlan['new'] ?? []) {
      todaySessions.add(ScheduledSession(
        surahId: verseSet.surahId,
        surahName: 'سورة ${verseSet.surahId}',
        startVerse: verseSet.startVerse,
        endVerse: verseSet.endVerse,
        type: SessionType.newMemorization,
      ));
    }

    // Add recent review sessions
    for (final verseSet in todayPlan['recent'] ?? []) {
      todaySessions.add(ScheduledSession(
        surahId: verseSet.surahId,
        surahName: 'سورة ${verseSet.surahId}',
        startVerse: verseSet.startVerse,
        endVerse: verseSet.endVerse,
        type: SessionType.recentReview,
      ));
    }

    // Add old review sessions
    for (final verseSet in todayPlan['old'] ?? []) {
      todaySessions.add(ScheduledSession(
        surahId: verseSet.surahId,
        surahName: 'سورة ${verseSet.surahId}',
        startVerse: verseSet.startVerse,
        endVerse: verseSet.endVerse,
        type: SessionType.oldReview,
      ));
    }

    // Add today to schedule
    weekSchedule.add(DaySchedule(
      date: today,
      isToday: true,
      sessions: todaySessions,
    ));

    // Generate the rest of the week with placeholder sessions
    // In a real app, this would use a more sophisticated algorithm
    for (int i = 1; i < 7; i++) {
      final date = today.add(Duration(days: i));
      final sessions = _generatePlaceholderSessions();

      weekSchedule.add(DaySchedule(
        date: date,
        isToday: false,
        sessions: sessions,
      ));
    }

    return weekSchedule;
  }

  /// Generate placeholder sessions for future days
  /// This is a simplified version that just clones today's plan
  List<ScheduledSession> _generatePlaceholderSessions() {
    if (_weekSchedule.isEmpty || _weekSchedule[0].sessions.isEmpty) {
      return [
        const ScheduledSession(
          surahId: 2,
          surahName: 'سورة 2',
          startVerse: 1,
          endVerse: 10,
          type: SessionType.newMemorization,
        ),
        const ScheduledSession(
          surahId: 2,
          surahName: 'سورة 2',
          startVerse: 1,
          endVerse: 20,
          type: SessionType.recentReview,
        ),
        const ScheduledSession(
          surahId: 1,
          surahName: 'سورة 1',
          startVerse: 1,
          endVerse: 7,
          type: SessionType.oldReview,
        ),
      ];
    }

    // Clone today's sessions but mark them as not completed
    return _weekSchedule[0].sessions.map((session) => ScheduledSession(
      surahId: session.surahId,
      surahName: session.surahName,
      startVerse: session.startVerse,
      endVerse: session.endVerse,
      type: session.type,
      isCompleted: false,
    )).toList();
  }
}