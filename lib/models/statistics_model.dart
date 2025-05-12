/// Model for tracking memorization statistics
class Statistics {
  final int totalMemorizedVerses;
  final int totalReviews;
  final Map<String, int> reviewsByDay; // Map of day name to count
  final String mostReviewedSet;
  final int mostReviewedSetCount;
  final double averageReviewQuality;
  final int currentStreak;
  final int longestStreak;
  final int daysActive;

  const Statistics({
    this.totalMemorizedVerses = 0,
    this.totalReviews = 0,
    this.reviewsByDay = const {},
    this.mostReviewedSet = '',
    this.mostReviewedSetCount = 0,
    this.averageReviewQuality = 0.0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.daysActive = 0,
  });

  /// The percentage of the Quran memorized
  double get quranPercentage {
    const totalVerses = 6236; // Total verses in the Quran
    return totalMemorizedVerses / totalVerses;
  }

  /// Create a copy of this statistics with updated fields
  Statistics copyWith({
    int? totalMemorizedVerses,
    int? totalReviews,
    Map<String, int>? reviewsByDay,
    String? mostReviewedSet,
    int? mostReviewedSetCount,
    double? averageReviewQuality,
    int? currentStreak,
    int? longestStreak,
    int? daysActive,
  }) {
    return Statistics(
      totalMemorizedVerses: totalMemorizedVerses ?? this.totalMemorizedVerses,
      totalReviews: totalReviews ?? this.totalReviews,
      reviewsByDay: reviewsByDay ?? this.reviewsByDay,
      mostReviewedSet: mostReviewedSet ?? this.mostReviewedSet,
      mostReviewedSetCount: mostReviewedSetCount ?? this.mostReviewedSetCount,
      averageReviewQuality: averageReviewQuality ?? this.averageReviewQuality,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      daysActive: daysActive ?? this.daysActive,
    );
  }

  /// Convert the statistics to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'totalMemorizedVerses': totalMemorizedVerses,
      'totalReviews': totalReviews,
      'reviewsByDay': reviewsByDay,
      'mostReviewedSet': mostReviewedSet,
      'mostReviewedSetCount': mostReviewedSetCount,
      'averageReviewQuality': averageReviewQuality,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'daysActive': daysActive,
    };
  }

  /// Create statistics from a JSON map
  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      totalMemorizedVerses: json['totalMemorizedVerses'] ?? 0,
      totalReviews: json['totalReviews'] ?? 0,
      reviewsByDay: (json['reviewsByDay'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value as int),
      ) ?? {},
      mostReviewedSet: json['mostReviewedSet'] ?? '',
      mostReviewedSetCount: json['mostReviewedSetCount'] ?? 0,
      averageReviewQuality: json['averageReviewQuality'] ?? 0.0,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      daysActive: json['daysActive'] ?? 0,
    );
  }

  /// Create default statistics
  factory Statistics.initial() {
    return const Statistics(
      reviewsByDay: {
        'Monday': 0,
        'Tuesday': 0,
        'Wednesday': 0,
        'Thursday': 0,
        'Friday': 0,
        'Saturday': 0,
        'Sunday': 0,
      },
    );
  }
}