import 'package:kottab/data/app_preferences.dart';
import 'package:kottab/data/quran_data.dart';
import 'package:kottab/models/statistics_model.dart';
import 'package:kottab/models/surah_model.dart';
import 'package:kottab/models/user_model.dart';
import 'package:kottab/models/verse_set_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/schedule_provider.dart';

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

    print(
        "MemorizationService: Loading Surahs with progress. Memorized sets: ${memorizedSetIds.length}");

    // Print the memorized sets for debugging
    if (memorizedSetIds.isNotEmpty) {
      print("Current memorized sets: ${memorizedSetIds.join(", ")}");
    }

    // Load in-progress sets from preferences
    final prefs = await SharedPreferences.getInstance();
    final inProgressSets = prefs.getStringList('in_progress_sets') ?? [];
    final inProgressMap = <String, double>{};

    for (final setId in inProgressSets) {
      final progress = prefs.getDouble('progress_$setId') ?? 0.0;
      inProgressMap[setId] = progress;
    }

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
          // Debug output when using a memorized set
          print(
              "Found memorized set: $verseSetId for surah ${surah.arabicName}");
        }
        // Check if this set is in the in-progress list
        else if (inProgressMap.containsKey(verseSetId)) {
          setData['status'] = MemorizationStatus.inProgress.index;
          setData['progressPercentage'] = inProgressMap[verseSetId];
          print(
              "Found in-progress set: $verseSetId with progress: ${inProgressMap[verseSetId]}");
        }

        return VerseSet.fromJson(setData);
      }).toList();

      final result = surah.copyWith(verseSets: verseSets);

      // Debug output for surah progress
      if (result.memorizedPercentage > 0) {
        print(
            "Surah ${result.arabicName} progress: ${(result.memorizedPercentage * 100).toStringAsFixed(1)}%");
      }

      return result;
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

  /// Generate a verse set respecting surah boundaries
  VerseSet generateVerseSet(int surahId, int startVerse, int maxVerseCount) {
    final surah = QuranData.getSurahById(surahId);

    // Ensure we don't exceed the surah's verse count
    final endVerse = startVerse + maxVerseCount - 1 <= surah.verseCount
        ? startVerse + maxVerseCount - 1
        : surah.verseCount;

    return VerseSet.create(
      surahId: surahId,
      startVerse: startVerse,
      endVerse: endVerse,
    );
  }

  /// Save the progress for in-progress verse sets
  Future<void> saveInProgressSet(String setId, double progress) async {
    try {
      // Create a new preference key for in-progress sets
      final prefs = await SharedPreferences.getInstance();
      final inProgressSets = prefs.getStringList('in_progress_sets') ?? [];

      // Add set ID if not already there
      if (!inProgressSets.contains(setId)) {
        inProgressSets.add(setId);
        await prefs.setStringList('in_progress_sets', inProgressSets);
      }

      // Save progress value for this set
      await prefs.setDouble('progress_$setId', progress);

      print('STORAGE: Saved in-progress set: $setId with progress: $progress');
    } catch (e) {
      print('Error saving in-progress set: $e');
    }
  }

  /// Record a memorization session with improved error checking and SM-2 algorithm
  Future<bool> recordMemorizationSession({
    required int surahId,
    required int startVerse,
    required int endVerse,
    required double quality,
    String notes = '',
  }) async {
    try {
      // Validate the parameters
      if (surahId <= 0 ||
          startVerse <= 0 ||
          endVerse <= 0 ||
          quality < 0 ||
          quality > 1) {
        print(
            'Invalid session parameters: surahId=$surahId, verses=$startVerse-$endVerse, quality=$quality');
        return false;
      }

      // Get the verse set
      final setId = '$surahId:$startVerse-$endVerse';
      print('Recording session for set: $setId with quality: $quality');

      // Get surahs (this ensures we have valid data to work with)
      final surahs = await getSurahsWithProgress();
      final surahIndex = surahs.indexWhere((s) => s.id == surahId);

      if (surahIndex == -1) {
        print('Surah not found: $surahId');
        return false;
      }

      final surah = surahs[surahIndex];

      // Find the verse set by ID
      final matchingSetIndex =
          surah.verseSets.indexWhere((set) => set.id == setId);

      if (matchingSetIndex == -1) {
        print('Verse set not found: $setId');
        // Create a new verse set if none exists
        final newSet =
            generateVerseSet(surahId, startVerse, endVerse - startVerse + 1);

        // Add review directly to the new set
        final updatedSet = newSet.addReview(quality, notes: notes);

        // Update memorized sets list if needed
        if (updatedSet.status == MemorizationStatus.memorized) {
          final memorizedSets = await AppPreferences.loadMemorizedSets();
          if (!memorizedSets.contains(setId)) {
            memorizedSets.add(setId);
            await AppPreferences.saveMemorizedSets(memorizedSets);
            print('Added new set to memorized sets: $setId');
          }
        } else if (updatedSet.status == MemorizationStatus.inProgress) {
          await saveInProgressSet(setId, updatedSet.averageQuality);
          print('Added new set to in-progress sets: $setId');
        }

        // Update user statistics
        await _updateStatistics(surahId, updatedSet);

        // Update user daily progress
        await _updateUserProgress(updatedSet.verseCount);

        // Force a refresh of statistics to ensure UI updates
        await refreshStatistics();

        return true;
      }

      // Update the existing verse set with the new review
      final existingSet = surah.verseSets[matchingSetIndex];
      final updatedSet = existingSet.addReview(quality, notes: notes);

      // Update memorized sets list if needed
      if (updatedSet.status == MemorizationStatus.memorized) {
        final memorizedSets = await AppPreferences.loadMemorizedSets();
        if (!memorizedSets.contains(setId)) {
          memorizedSets.add(setId);
          await AppPreferences.saveMemorizedSets(memorizedSets);
          print('Added to memorized sets: $setId');
        }
      } else if (updatedSet.status == MemorizationStatus.inProgress) {
        await saveInProgressSet(setId, updatedSet.averageQuality);
        print('Added to in-progress sets: $setId');
      }

      // Update user statistics
      await _updateStatistics(surahId, updatedSet);

      // Update user daily progress
      await _updateUserProgress(updatedSet.verseCount);

      // Force a refresh of statistics to ensure UI updates
      await refreshStatistics();

      return true;
    } catch (e) {
      print('Error recording memorization session: $e');
      return false;
    }
  }

  /// Generate today's memorization plan according to current settings and SM-2 algorithm
  Future<Map<String, List<VerseSet>>> generateTodayPlan() async {
    final user = await getUser();
    final memorizedSets = await AppPreferences.loadMemorizedSets();
    final surahs = await getSurahsWithProgress();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Get settings - use user settings or defaults
    final dailyVerseTarget = user.settings['dailyVerseTarget'] as int? ?? 10;
    final reviewSetSize = user.settings['reviewSetSize'] as int? ?? 20;
    final oldReviewCycle = user.settings['oldReviewCycle'] as int? ?? 5;

    // Find sets for new memorization, recent review, and old review
    final newSets = <VerseSet>[];
    final recentSets = <VerseSet>[];
    final oldSets = <VerseSet>[];

    // Find all verse sets due for review today based on nextReviewDate
    // and categorize them based on their repetition count
    for (final surah in surahs) {
      for (final set in surah.verseSets) {
        // Skip sets that aren't due today
        if (set.nextReviewDate == null || set.nextReviewDate!.isAfter(today)) {
          continue;
        }

        // Categorize based on repetition count and status
        if (set.status == MemorizationStatus.notStarted) {
          if (newSets.length < 1) {
            // Limit to one new set per day
            newSets.add(set);
          }
        } else if (set.repetitionCount <= 2) {
          // Recent review (early in SM-2 cycle)
          recentSets.add(set);
        } else {
          // Old review (further along in SM-2 cycle)
          oldSets.add(set);
        }
      }
    }

    // If no new sets are due, find the next not started set
    if (newSets.isEmpty) {
      for (final surah in surahs) {
        bool found = false;
        for (final set in surah.verseSets) {
          if (set.status == MemorizationStatus.notStarted) {
            newSets.add(set);
            found = true;
            break;
          }
        }
        if (found) break;
      }
    }

    // Sort recent sets by review date (most recent first)
    recentSets.sort((a, b) {
      if (a.lastReviewDate == null) return 1;
      if (b.lastReviewDate == null) return -1;
      return b.lastReviewDate!.compareTo(a.lastReviewDate!);
    });

    // Sort old sets by days since last review
    oldSets.sort((a, b) {
      if (a.lastReviewDate == null) return 1;
      if (b.lastReviewDate == null) return -1;
      final aDays = now.difference(a.lastReviewDate!).inDays;
      final bDays = now.difference(b.lastReviewDate!).inDays;
      return bDays.compareTo(aDays); // Descending order
    });

    // Take only one old set for review per day
    final topOldSets = oldSets.take(1).toList();

    return {
      'new': newSets,
      'recent': recentSets.take(2).toList(), // Limit to 2 recent sets
      'old': topOldSets,
    };
  }

  /// Get all memorized set IDs
  Future<List<String>> getAllMemorizedSetIds() async {
    return await AppPreferences.loadMemorizedSets();
  }

  /// Force refresh statistics to ensure progress is accurately reflected
  Future<void> refreshStatistics() async {
    // Load all surahs to also find in-progress sets
    final surahs = await getSurahsWithProgress();
    final user = await getUser();
    final stats = await AppPreferences.loadStatistics();

    // Count both memorized and in-progress verses
    int totalVerses = 0;

    // Count all memorized sets from stored list
    final memorizedSets = await AppPreferences.loadMemorizedSets();
    for (final setId in memorizedSets) {
      try {
        final parts = setId.split(':');
        final verseParts = parts[1].split('-');
        final startVerse = int.parse(verseParts[0]);
        final endVerse = int.parse(verseParts[1]);
        totalVerses += (endVerse - startVerse + 1);
      } catch (e) {
        // Skip invalid IDs
        print('Error processing set ID: $setId - $e');
      }
    }

    // Also add partial credit for in-progress sets
    final prefs = await SharedPreferences.getInstance();
    final inProgressSets = prefs.getStringList('in_progress_sets') ?? [];
    for (final setId in inProgressSets) {
      try {
        final parts = setId.split(':');
        final verseParts = parts[1].split('-');
        final startVerse = int.parse(verseParts[0]);
        final endVerse = int.parse(verseParts[1]);
        final verseCount = endVerse - startVerse + 1;

        // Get saved progress for this set
        final progress = prefs.getDouble('progress_$setId') ?? 0.0;

        // Calculate partial verses
        final partialVerses = (verseCount * progress).round();
        totalVerses += partialVerses;
        print(
            'REFRESH: Adding $partialVerses partially memorized verses from $setId (stored progress: $progress)');
      } catch (e) {
        print('Error processing in-progress set ID: $setId - $e');
      }
    }

    // Update statistics
    final updatedStats = stats.copyWith(
      totalMemorizedVerses: totalVerses,
    );

    await AppPreferences.saveStatistics(updatedStats);

    // Debugging information
    print('REFRESH: Statistics refreshed with in-progress sets included');
    print('REFRESH: Total memorized verses: $totalVerses');
    print('REFRESH: Fully memorized sets count: ${memorizedSets.length}');
    print('REFRESH: Quran percentage: ${updatedStats.quranPercentage * 100}%');

    // Also update user's total memorized verses
    if (user != null) {
      final updatedUser = user.copyWith(
        totalMemorizedVerses: totalVerses,
      );
      await AppPreferences.saveUser(updatedUser);
    }
  }

  /// Get due verse sets for today
  /// Check if Al-Fatiha is fully memorized
  bool _isAlFatihaMemorized(List<Surah> surahs) {
    try {
      final fatiha = surahs.firstWhere((s) => s.id == 1);
      return fatiha.verseSets
          .every((set) => set.status == MemorizationStatus.memorized);
    } catch (e) {
      return false; // Could not find Al-Fatiha
    }
  }

  /// Generate the week schedule based on SM-2 algorithm and surah progression
  Future<List<DaySchedule>> _generateWeekSchedule() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekSchedule = <DaySchedule>[];

    // Get all Surahs for display names and progression checks
    final surahs = await getSurahsWithProgress();

    // Check if Al-Fatiha is memorized before scheduling other surahs
    bool alFatihaMemorized = _isAlFatihaMemorized(surahs);

    // Get the plan for today based on SM-2 algorithm
    final todayPlan = await generateTodayPlan();

    // Format sessions for today
    final todaySessions = <ScheduledSession>[];

    // If Al-Fatiha is not memorized, only schedule it and ignore other new memorization
    if (!alFatihaMemorized) {
      // Find Al-Fatiha
      try {
        final fatiha = surahs.firstWhere((s) => s.id == 1);
        final notMemorizedSets = fatiha.verseSets
            .where((set) => set.status != MemorizationStatus.memorized)
            .toList();

        if (notMemorizedSets.isNotEmpty) {
          final set = notMemorizedSets.first;
          todaySessions.add(ScheduledSession(
            surahId: 1,
            surahName: "الفاتحة",
            startVerse: set.startVerse,
            endVerse: set.endVerse,
            type: SessionType.newMemorization,
            isCompleted: false,
            dueDate: set.nextReviewDate,
          ));
        } else {
          // Add full Al-Fatiha for memorization
          todaySessions.add(ScheduledSession(
            surahId: 1,
            surahName: "الفاتحة",
            startVerse: 1,
            endVerse: 7,
            type: SessionType.newMemorization,
            isCompleted: false,
            dueDate: today,
          ));
        }
      } catch (e) {
        // Al-Fatiha not found, add default
        todaySessions.add(ScheduledSession(
          surahId: 1,
          surahName: "الفاتحة",
          startVerse: 1,
          endVerse: 7,
          type: SessionType.newMemorization,
          isCompleted: false,
          dueDate: today,
        ));
      }
    } else {
      // Al-Fatiha is memorized, follow normal plan

      // Always show Al-Fatiha as a review task
      todaySessions.add(ScheduledSession(
        surahId: 1,
        surahName: "الفاتحة",
        startVerse: 1,
        endVerse: 7,
        type: SessionType.recentReview,
        isCompleted: false,
        dueDate: today,
      ));

      // Add new memorization sessions for next Surah (Al-Baqarah)
      // Only if no other new memorization tasks are present
      if (!todayPlan['new']!.any((set) => set.surahId > 1)) {
        todaySessions.add(ScheduledSession(
          surahId: 2,
          surahName: "البقرة",
          startVerse: 1,
          endVerse: 10,
          // First 10 verses of Al-Baqarah
          type: SessionType.newMemorization,
          isCompleted: false,
          dueDate: today,
        ));
      } else {
        // Add new memorization sessions from the plan
        for (final verseSet in todayPlan['new'] ?? []) {
          if (verseSet.surahId > 1) {
            // Skip Al-Fatiha since we've already added it
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
              isCompleted: verseSet.status == MemorizationStatus.memorized,
              dueDate: verseSet.nextReviewDate,
            ));
          }
        }
      }
    }

    // Add review sessions only for surahs that have been started
    // Recent reviews
    for (final verseSet in todayPlan['recent'] ?? []) {
      // Only schedule reviews for Al-Fatiha if it's not fully memorized
      if (!alFatihaMemorized && verseSet.surahId > 1) {
        continue;
      }

      // Skip Al-Fatiha since we've already handled it specially
      if (alFatihaMemorized && verseSet.surahId == 1) {
        continue;
      }

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
        isCompleted: false,
        dueDate: verseSet.nextReviewDate,
      ));
    }

    // Old reviews
    for (final verseSet in todayPlan['old'] ?? []) {
      // Only schedule reviews for Al-Fatiha if it's not fully memorized
      if (!alFatihaMemorized && verseSet.surahId > 1) {
        continue;
      }

      // Skip Al-Fatiha since we've already handled it specially
      if (alFatihaMemorized && verseSet.surahId == 1) {
        continue;
      }

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
        isCompleted: false,
        dueDate: verseSet.nextReviewDate,
      ));
    }

    // Add today to schedule
    weekSchedule.add(DaySchedule(
      date: today,
      isToday: true,
      sessions: todaySessions,
    ));

    // Generate schedules for the rest of the week - ESPECIALLY TOMORROW
    for (int i = 1; i < 7; i++) {
      final date = today.add(Duration(days: i));
      final dueSessions = <ScheduledSession>[];

      // For the next day (tomorrow), always include Al-Fatiha review if it's memorized
      if (i == 1 && alFatihaMemorized) {
        dueSessions.add(ScheduledSession(
          surahId: 1,
          surahName: "الفاتحة",
          startVerse: 1,
          endVerse: 7,
          type: SessionType.recentReview,
          isCompleted: false,
          dueDate: date,
        ));

        // Also include Al-Baqarah for new memorization
        dueSessions.add(ScheduledSession(
          surahId: 2,
          surahName: "البقرة",
          startVerse: 1,
          endVerse: 10,
          // First 10 verses of Al-Baqarah
          type: SessionType.newMemorization,
          isCompleted: false,
          dueDate: date,
        ));
      } else if (i == 1 && !alFatihaMemorized) {
        // If Al-Fatiha is not memorized, schedule it for tomorrow
        dueSessions.add(ScheduledSession(
          surahId: 1,
          surahName: "الفاتحة",
          startVerse: 1,
          endVerse: 7,
          type: SessionType.newMemorization,
          isCompleted: false,
          dueDate: date,
        ));
      }

      // Find all additional sets due on this date from verse sets
      for (final surah in surahs) {
        // Skip if we're controlling tasks manually
        if (i == 1) continue;

        for (final set in surah.verseSets) {
          if (set.nextReviewDate != null) {
            final nextReviewDate = set.nextReviewDate!;
            final reviewDay = DateTime(
                nextReviewDate.year, nextReviewDate.month, nextReviewDate.day);

            if (reviewDay.isAtSameMomentAs(date)) {
              // Determine the session type based on repetition count
              SessionType sessionType;
              if (set.status == MemorizationStatus.notStarted) {
                sessionType = SessionType.newMemorization;
              } else if (set.repetitionCount <= 2) {
                sessionType = SessionType.recentReview;
              } else {
                sessionType = SessionType.oldReview;
              }

              // Find the surah name
              final surahName = surahs
                  .firstWhere((s) => s.id == set.surahId,
                      orElse: () => const Surah(
                          id: 0,
                          name: "Unknown",
                          arabicName: "غير معروف",
                          verseCount: 0))
                  .arabicName;

              dueSessions.add(ScheduledSession(
                surahId: set.surahId,
                surahName: surahName,
                startVerse: set.startVerse,
                endVerse: set.endVerse,
                type: sessionType,
                isCompleted: false,
                dueDate: set.nextReviewDate,
              ));
            }
          }
        }
      }

      weekSchedule.add(DaySchedule(
        date: date,
        isToday: false,
        sessions: dueSessions,
      ));
    }

    return weekSchedule;
  }

  Future<List<VerseSet>> getDueVerseSets() async {
    final surahs = await getSurahsWithProgress();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final dueSets = <VerseSet>[];

    for (final surah in surahs) {
      for (final set in surah.verseSets) {
        if (set.nextReviewDate != null && !set.nextReviewDate!.isAfter(today)) {
          dueSets.add(set);
        }
      }
    }

    return dueSets;
  }

  /// Update user statistics after a memorization session
  Future<void> _updateStatistics(int surahId, VerseSet verseSet) async {
    final stats = await AppPreferences.loadStatistics();
    final user = await getUser();

    // FIX: Update total memorized verses - count verses as fully completed
    int newMemorizedVerses = 0;
    if (verseSet.status == MemorizationStatus.memorized) {
      // Full credit for memorized verses
      newMemorizedVerses = verseSet.verseCount;
      print(
          "PROGRESS UPDATE: Adding ${verseSet.verseCount} fully memorized verses for set ${verseSet.id}");
    } else if (verseSet.status == MemorizationStatus.inProgress) {
      // Add partial progress based on quality for in-progress sets
      newMemorizedVerses =
          (verseSet.verseCount * verseSet.averageQuality).round();
      print(
          "PROGRESS UPDATE: Adding ${newMemorizedVerses} partially memorized verses for set ${verseSet.id}");
      print(
          "PROGRESS UPDATE: Quality: ${verseSet.averageQuality}, Verse Count: ${verseSet.verseCount}");
    }

    // Update review count by day of week
    final dayName = _getDayName(DateTime.now().weekday);
    final reviewsByDay = Map<String, int>.from(stats.reviewsByDay);
    reviewsByDay[dayName] = (reviewsByDay[dayName] ?? 0) + 1;

    // Check if this is the most reviewed set
    String mostReviewedSet = stats.mostReviewedSet;
    int mostReviewedCount = stats.mostReviewedSetCount;

    if (verseSet.reviewCount > mostReviewedCount) {
      mostReviewedSet =
          '${QuranData.getSurahById(surahId).arabicName} ${verseSet.rangeText}';
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
    final newTotalQuality = stats.averageReviewQuality * stats.totalReviews +
        verseSet.averageQuality;
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

    // Save the updated statistics
    await AppPreferences.saveStatistics(updatedStats);

    // Also update user's total memorized verses
    if (user != null) {
      final updatedUser = user.copyWith(
        totalMemorizedVerses: stats.totalMemorizedVerses + newMemorizedVerses,
      );
      await AppPreferences.saveUser(updatedUser);
    }

    print(
        'PROGRESS UPDATE: Statistics updated: Total memorized verses = ${updatedStats.totalMemorizedVerses}');
    print(
        'PROGRESS UPDATE: Quran percentage = ${updatedStats.quranPercentage * 100}%');
  }

  /// Update user progress for today
  Future<void> _updateUserProgress(int verses) async {
    final user = await getUser();

    // FIX: Mark as 100% complete when task is done
    final targetVerses = user.settings['dailyVerseTarget'] as int? ?? 10;
    final completedVerses = verses;

    print(
        'DAILY PROGRESS: Updating with $completedVerses verses (daily target: $targetVerses)');

    // Mark as 100% complete for the specific task
    double progressPercentage = 1.0;

    final updatedUser = user.updateTodayProgress(
      progressPercentage,
      completedVerses,
      targetVerses,
    );

    await AppPreferences.saveUser(updatedUser);

    // Print the updated daily progress for debugging
    final todayProgress = updatedUser.todayProgress;
    if (todayProgress != null) {
      print(
          'DAILY PROGRESS: Updated to ${todayProgress.completedVerses}/${todayProgress.targetVerses} verses (${todayProgress.progress * 100}%)');
    }
  }

  /// Get day name from weekday number
  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Unknown';
    }
  }
}
