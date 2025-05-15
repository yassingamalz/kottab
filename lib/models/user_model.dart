/// Model representing the user's settings and progress
class User {
  final String id;
  final String name;
  final int streak;
  final DateTime lastActivity;
  final bool isFirstTime;
  final int totalMemorizedVerses;
  final Map<String, dynamic> settings;
  final List<DailyProgress> dailyProgress;

  const User({
    required this.id,
    this.name = '',
    this.streak = 0,
    required this.lastActivity,
    this.isFirstTime = true,
    this.totalMemorizedVerses = 0,
    this.settings = const {},
    this.dailyProgress = const [],
  });

  /// Calculate the percentage of the Quran memorized
  double get quranProgress {
    const totalVerses = 6236; // Total verses in the Quran
    return totalMemorizedVerses / totalVerses;
  }

  /// Check if user has been active today
  bool get isActiveToday {
    final now = DateTime.now();
    return lastActivity.year == now.year &&
        lastActivity.month == now.month &&
        lastActivity.day == now.day;
  }

  /// Get progress for the past week
  List<DailyProgress> get weeklyProgress {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    return dailyProgress
        .where((progress) => progress.date.isAfter(weekAgo))
        .toList();
  }

  /// Get today's progress, if any
  DailyProgress? get todayProgress {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    try {
      return dailyProgress.firstWhere(
        (p) => p.date.year == today.year && 
               p.date.month == today.month && 
               p.date.day == today.day
      );
    } catch (e) {
      return null;
    }
  }

  /// Update the daily progress for today
  User updateTodayProgress(double progress, int completedVerses, int targetVerses) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Find if we already have progress for today
    final existingIndex = dailyProgress.indexWhere(
            (p) => p.date.year == today.year &&
            p.date.month == today.month &&
            p.date.day == today.day
    );

    List<DailyProgress> updatedProgress = List.from(dailyProgress);

    if (existingIndex >= 0) {
      // Update existing progress - ADD to existing progress, not replace
      final existing = updatedProgress[existingIndex];
      final newCompleted = existing.completedVerses + completedVerses;
      final newProgress = (newCompleted / targetVerses).clamp(0.0, 1.0);
      
      updatedProgress[existingIndex] = DailyProgress(
        date: today,
        progress: newProgress,
        completedVerses: newCompleted,
        targetVerses: targetVerses,
      );
      print("DAILY: Updated today's progress: $newCompleted/$targetVerses (${newProgress * 100}%)");
    } else {
      // Add new progress for today
      updatedProgress.add(DailyProgress(
        date: today,
        progress: progress.clamp(0.0, 1.0),
        completedVerses: completedVerses,
        targetVerses: targetVerses,
      ));
      print("DAILY: Added new progress for today: $completedVerses/$targetVerses (${progress * 100}%)");
    }

    // Calculate streak
    int newStreak = streak;
    final yesterday = today.subtract(const Duration(days: 1));

    // Check if user was active yesterday to continue streak
    bool wasActiveYesterday = dailyProgress.any(
            (p) => p.date.year == yesterday.year &&
            p.date.month == yesterday.month &&
            p.date.day == yesterday.day
    );

    if (wasActiveYesterday || streak == 0) {
      newStreak = streak + 1;
    } else {
      // Streak broken, reset to 1
      newStreak = 1;
    }

    return copyWith(
      lastActivity: now,
      streak: newStreak,
      isFirstTime: false,
      dailyProgress: updatedProgress,
    );
  }

  /// Create a copy of this user with updated fields
  User copyWith({
    String? id,
    String? name,
    int? streak,
    DateTime? lastActivity,
    bool? isFirstTime,
    int? totalMemorizedVerses,
    Map<String, dynamic>? settings,
    List<DailyProgress>? dailyProgress,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      streak: streak ?? this.streak,
      lastActivity: lastActivity ?? this.lastActivity,
      isFirstTime: isFirstTime ?? this.isFirstTime,
      totalMemorizedVerses: totalMemorizedVerses ?? this.totalMemorizedVerses,
      settings: settings ?? this.settings,
      dailyProgress: dailyProgress ?? this.dailyProgress,
    );
  }

  /// Convert the user to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'streak': streak,
      'lastActivity': lastActivity.toIso8601String(),
      'isFirstTime': isFirstTime,
      'totalMemorizedVerses': totalMemorizedVerses,
      'settings': settings,
      'dailyProgress': dailyProgress.map((p) => p.toJson()).toList(),
    };
  }

  /// Create a user from a JSON map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? '',
      streak: json['streak'] ?? 0,
      lastActivity: DateTime.parse(json['lastActivity']),
      isFirstTime: json['isFirstTime'] ?? true,
      totalMemorizedVerses: json['totalMemorizedVerses'] ?? 0,
      settings: json['settings'] ?? {},
      dailyProgress: (json['dailyProgress'] as List?)
          ?.map((e) => DailyProgress.fromJson(e))
          .toList() ?? [],
    );
  }

  /// Create a new user with default values
  factory User.create() {
    return User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      lastActivity: DateTime.now(),
      settings: {
        'dailyVerseTarget': 10,
        'reviewSetSize': 20,
        'oldReviewCycle': 5,
        'theme': 'light',
        'notifications': true,
      },
    );
  }
}

/// Model representing the user's progress for a single day
class DailyProgress {
  final DateTime date;
  final double progress; // 0.0 to 1.0
  final int completedVerses;
  final int targetVerses;

  const DailyProgress({
    required this.date,
    required this.progress,
    required this.completedVerses,
    required this.targetVerses,
  });

  /// Convert the daily progress to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'progress': progress,
      'completedVerses': completedVerses,
      'targetVerses': targetVerses,
    };
  }

  /// Create a daily progress from a JSON map
  factory DailyProgress.fromJson(Map<String, dynamic> json) {
    return DailyProgress(
      date: DateTime.parse(json['date']),
      progress: json['progress'],
      completedVerses: json['completedVerses'],
      targetVerses: json['targetVerses'],
    );
  }
}
