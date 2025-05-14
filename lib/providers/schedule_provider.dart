import 'dart:math' as Math;

import 'package:flutter/foundation.dart';
import 'package:kottab/data/app_preferences.dart';
import 'package:kottab/data/quran_data.dart';
import 'package:kottab/services/memorization_service.dart';

import '../models/surah_model.dart';

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

  /// Update a setting value and regenerate schedule
  Future<void> updateSetting(String key, dynamic value) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Update in preferences
      await AppPreferences.saveSetting(key, value);

      // Update local settings map
      _settings[key] = value;

      // Reload user to ensure settings are consistent
      final user = await _memorizationService.getUser();
      _settings = Map<String, dynamic>.from(user.settings);

      // Regenerate schedule with new settings
      _weekSchedule = await _generateWeekSchedule();
    } catch (e) {
      print('Error updating setting $key: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

  /// Generate the week schedule based on memorization plan and current settings
  Future<List<DaySchedule>> _generateWeekSchedule() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekSchedule = <DaySchedule>[];

    // Get all Surahs for display names
    final surahs = QuranData.getAllSurahs();

    // Generate today's plan
    final todayPlan = await _memorizationService.generateTodayPlan();

    // Format sessions for today
    final todaySessions = <ScheduledSession>[];

    // Add new memorization sessions
    for (final verseSet in todayPlan['new'] ?? []) {
      final surahName = surahs
          .firstWhere((s) => s.id == verseSet.surahId,
              orElse: () => const Surah(
                  id: 0,
                  name: "Unknown",
                  arabicName: "غير معروف",
                  verseCount: 0))
          .arabicName;

      todaySessions.add(ScheduledSession(
        surahId: verseSet.surahId,
        surahName: surahName,
        startVerse: verseSet.startVerse,
        endVerse: verseSet.endVerse,
        type: SessionType.newMemorization,
      ));
    }

    // Add recent review sessions - use current reviewSetSize setting
    for (final verseSet in todayPlan['recent'] ?? []) {
      final surahName = surahs
          .firstWhere((s) => s.id == verseSet.surahId,
              orElse: () => const Surah(
                  id: 0,
                  name: "Unknown",
                  arabicName: "غير معروف",
                  verseCount: 0))
          .arabicName;

      todaySessions.add(ScheduledSession(
        surahId: verseSet.surahId,
        surahName: surahName,
        startVerse: verseSet.startVerse,
        endVerse: verseSet.endVerse,
        type: SessionType.recentReview,
      ));
    }

    // Add old review sessions - use current oldReviewCycle setting
    for (final verseSet in todayPlan['old'] ?? []) {
      final surahName = surahs
          .firstWhere((s) => s.id == verseSet.surahId,
              orElse: () => const Surah(
                  id: 0,
                  name: "Unknown",
                  arabicName: "غير معروف",
                  verseCount: 0))
          .arabicName;

      todaySessions.add(ScheduledSession(
        surahId: verseSet.surahId,
        surahName: surahName,
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

    // Generate the rest of the week with placeholder sessions based on current settings
    for (int i = 1; i < 7; i++) {
      final date = today.add(Duration(days: i));
      final sessions = _generatePlaceholderSessions(surahs);

      weekSchedule.add(DaySchedule(
        date: date,
        isToday: false,
        sessions: sessions,
      ));
    }

    return weekSchedule;
  }

  /// Generate placeholder sessions for future days using current settings
  List<ScheduledSession> _generatePlaceholderSessions(List<Surah> surahs) {
    final List<ScheduledSession> sessions = [];
    final int dailyTarget = dailyVerseTarget;
    final int reviewSize = reviewSetSize;
    final int reviewCycle = oldReviewCycle;

    // New memorization with dynamic verse count based on settings
    final surah = surahs.firstWhere((s) => s.id == 2, orElse: () => surahs.first);
    sessions.add(ScheduledSession(
      surahId: surah.id,
      surahName: surah.arabicName,
      startVerse: 11,
      endVerse: 11 + dailyTarget - 1,
      type: SessionType.newMemorization,
    ));

    // Add a recent review with dynamic size based on settings
    if (sessions.length % 2 == 0) {
      final endVerse = Math.min(10 + reviewSize, surahs.firstWhere((s) => s.id == 2, orElse: () => surahs.first).verseCount);
      sessions.add(ScheduledSession(
        surahId: 2,
        surahName: surahs.firstWhere((s) => s.id == 2, orElse: () => surahs.first).arabicName,
        startVerse: 1,
        endVerse: endVerse,
        type: SessionType.recentReview,
      ));
    }

    // Add an old review with cycle based on settings
    if (sessions.length % reviewCycle == 0 || reviewCycle == 1) {
      sessions.add(ScheduledSession(
        surahId: 1,
        surahName: surahs.firstWhere((s) => s.id == 1, orElse: () => surahs.first).arabicName,
        startVerse: 1,
        endVerse: 7,
        type: SessionType.oldReview,
      ));
    }

    return sessions;
  }
}
