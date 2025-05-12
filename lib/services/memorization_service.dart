import 'package:kottab/data/app_preferences.dart';
import 'package:kottab/data/quran_data.dart';
import 'package:kottab/models/surah_model.dart';
import 'package:kottab/models/verse_set_model.dart';
import 'package:kottab/models/user_model.dart';
import 'package:kottab/models/statistics_model.dart';

/// Service class for managing memorization functionality
class MemorizationService {
  /// Get user data, creating a new user if none exists
  Future<User> getUser() async {
    final user = await AppPreferences.loadUser();
    if (user != null) {
      return user;
    }

    // Create new user if none exists
    final newUser = User.create();
    await AppPreferences.saveUser(newUser);
    return newUser;
  }

  /// Get all surahs with their memorization progress
  Future<List<Surah>> getSurahsWithProgress() async {
    final memorizedSetIds = await AppPreferences.loadMemorizedSets();
    final surahs = QuranData.getAllSurahs();

    // Create surah copies with verse sets populated from stored progress
    return surahs.map((surah) {
      final defaultSets = QuranData.generateDefaultSets(surah.id);

      // Convert default sets to VerseSet objects and update status
      // based on memorized sets data
      final verseSets = defaultSets.map((setData) {
        final verseSetId = setData['id'] as String;

        // Check if this set is in the memorized list
        if (memorizedSetIds.contains(verseSetId)) {
          setData['status'] = MemorizationStatus.memorized.index;
        }

        return VerseSet.fromJson(setData);
      }).toList();

      return surah.copyWith(verseSets: verseSets);
    }).toList();
  }

  /// Get a single surah with its memorization progress
  Future<Surah> getSurahWithProgress(int surahId) async {
    final surahs = await getSurahsWithProgress();
    return surahs.firstWhere(
          (surah) => surah.id == surahId,
      orElse: () => throw Exception('Surah with ID $surahId not found'),
    );
  }

  /// Record a memorization session
  Future<bool> recordMemorizationSession({
    required int surahId,
    required int startVerse,
    required int endVerse,
    required double quality,
    String notes = '',
  }) async {
    try {
      // Get the verse set
      final setId = '$surahId:$startVerse-$endVerse';
      final surahs = await getSurahsWithProgress();
      final surah = surahs.firstWhere((s) => s.id == surahId);

      // Find the verse set
      final setIndex = surah.verseSets.indexWhere((set) => set.id == setId);
      if (setIndex == -1) {
        throw Exception('Verse set not found');
      }

      // Update the verse set with the new review
      final updatedSet = surah.verseSets[setIndex].addReview(quality, notes: notes);
      final updatedSets = List<VerseSet>.from(surah.verseSets);
      updatedSets[setIndex] = updatedSet;

      // Update memorized sets list if needed
      if (updatedSet.status == MemorizationStatus.memorized) {
        final memorizedSets = await AppPreferences.loadMemorizedSets();
        if (!memorizedSets.contains(setId)) {
          memorizedSets.add(setId);
          await AppPreferences.saveMemorizedSets(memorizedSets);
        }
      }

      // Update user statistics
      await _updateStatistics(surahId, updatedSet);

      // Update user daily progress
      await _updateUserProgress(1);

      return true;
    } catch (e) {
      print('Error recording memorization session: $e');
      return false;
    }
  }

  /// Generate today's memorization plan
  Future<Map<String, List<VerseSet>>> generateTodayPlan() async {
    final user = await getUser();
    final memorizedSets = await AppPreferences.loadMemorizedSets();
    final surahs = await getSurahsWithProgress();

    // Get settings
    final dailyVerseTarget = user.settings['dailyVerseTarget'] as int? ?? 10;
    final reviewSetSize = user.settings['reviewSetSize'] as int? ?? 20;
    final oldReviewCycle = user.settings['oldReviewCycle'] as int? ?? 5;

    // Find sets for new memorization
    final newSets = <VerseSet>[];
    final recentSets = <VerseSet>[];
    final oldSets = <VerseSet>[];

    // Find the next set to memorize (first not started set)
    for (final surah in surahs) {
      for (final set in surah.verseSets) {
        if (set.status == MemorizationStatus.notStarted &&
            set.verseCount <= dailyVerseTarget &&
            newSets.isEmpty) {
          newSets.add(set);
          break;
        }
      }
      if (newSets.isNotEmpty) break;
    }

    // Find recently memorized sets for review
    int recentVerseCount = 0;
    for (final surah in surahs) {
      for (final set in surah.verseSets) {
        if (set.status == MemorizationStatus.memorized &&
            recentVerseCount < reviewSetSize) {
          // Sort by recent first
          if (set.lastReviewDate != null) {
            recentSets.add(set);
            recentVerseCount += set.verseCount;
          }
        }
      }
    }

    // Sort recent sets by last review date
    recentSets.sort((a, b) {
      if (a.lastReviewDate == null) return 1;
      if (b.lastReviewDate == null) return -1;
      return b.lastReviewDate!.compareTo(a.lastReviewDate!);
    });

    // Take only the most recent sets up to the review set size
    final topRecentSets = recentSets.take(2).toList();

    // Find older memorized sets for periodic review
    // Using the review cycle to determine which sets to review
    final now = DateTime.now();
    for (final surah in surahs) {
      for (final set in surah.verseSets) {
        if (set.status == MemorizationStatus.memorized &&
            set.lastReviewDate != null) {
          final daysSinceReview = now.difference(set.lastReviewDate!).inDays;
          if (daysSinceReview >= oldReviewCycle &&
              !topRecentSets.contains(set)) {
            oldSets.add(set);
          }
        }
      }
    }

    // Sort old sets by days since last review
    oldSets.sort((a, b) {
      final aDays = now.difference(a.lastReviewDate!).inDays;
      final bDays = now.difference(b.lastReviewDate!).inDays;
      return bDays.compareTo(aDays); // Descending order
    });

    // Take only one old set for review
    final topOldSets = oldSets.take(1).toList();

    return {
      'new': newSets,
      'recent': topRecentSets,
      'old': topOldSets,
    };
  }

  /// Update user statistics after a memorization session
  Future<void> _updateStatistics(int surahId, VerseSet verseSet) async {
    final stats = await AppPreferences.loadStatistics();
    final user = await getUser();

    // Update total memorized verses if this set was newly memorized
    int newMemorizedVerses = 0;
    if (verseSet.status == MemorizationStatus.memorized) {
      newMemorizedVerses = verseSet.verseCount;
    }

    // Update review count by day of week
    final dayName = _getDayName(DateTime.now().weekday);
    final reviewsByDay = Map<String, int>.from(stats.reviewsByDay);
    reviewsByDay[dayName] = (reviewsByDay[dayName] ?? 0) + 1;

    // Check if this is the most reviewed set
    String mostReviewedSet = stats.mostReviewedSet;
    int mostReviewedCount = stats.mostReviewedSetCount;

    if (verseSet.reviewCount > mostReviewedCount) {
      mostReviewedSet = '${QuranData.getSurahById(surahId).arabicName} ${verseSet.rangeText}';
      mostReviewedCount = verseSet.reviewCount;
    }

    // Update streak if needed
    int currentStreak = user.streak;
    int longestStreak = stats.longestStreak;

    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }

    // Update average review quality
    final totalReviews = stats.totalReviews + 1;
    final newTotalQuality = stats.averageReviewQuality * stats.totalReviews + verseSet.averageQuality;
    final newAverageQuality = newTotalQuality / totalReviews;

    // Create updated statistics
    final updatedStats = stats.copyWith(
      totalMemorizedVerses: stats.totalMemorizedVerses + newMemorizedVerses,
      totalReviews: totalReviews,
      reviewsByDay: reviewsByDay,
      mostReviewedSet: mostReviewedSet,
      mostReviewedSetCount: mostReviewedCount,
      averageReviewQuality: newAverageQuality,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      daysActive: user.isActiveToday ? stats.daysActive : stats.daysActive + 1,
    );

    await AppPreferences.saveStatistics(updatedStats);
  }

  /// Update user progress for today
  Future<void> _updateUserProgress(int verses) async {
    final user = await getUser();

    final targetVerses = user.settings['dailyVerseTarget'] as int? ?? 10;
    final completedVerses = verses;
    final progress = verses / targetVerses;

    final updatedUser = user.updateTodayProgress(
      progress.clamp(0.0, 1.0),
      completedVerses,
      targetVerses,
    );

    await AppPreferences.saveUser(updatedUser);
  }

  /// Get day name from weekday number
  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return 'Unknown';
    }
  }
}