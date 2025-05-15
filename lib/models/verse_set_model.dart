/// Status of memorization for a set of verses
enum MemorizationStatus {
  notStarted,
  inProgress,
  memorized,
}

/// Model representing a review session for a verse set
class ReviewSession {
  final DateTime date;
  final double quality; // 0.0 to 1.0 score
  final String notes;

  const ReviewSession({
    required this.date,
    required this.quality,
    this.notes = '',
  });

  /// Convert the review session to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'quality': quality,
      'notes': notes,
    };
  }

  /// Create a review session from a JSON map
  factory ReviewSession.fromJson(Map<String, dynamic> json) {
    return ReviewSession(
      date: DateTime.parse(json['date']),
      quality: json['quality'],
      notes: json['notes'] ?? '',
    );
  }
}

/// Model representing a set of verses for memorization
class VerseSet {
  final String id; // Format: "surahId:startVerse-endVerse"
  final int surahId;
  final int startVerse;
  final int endVerse;
  final MemorizationStatus status;
  final List<ReviewSession> reviewHistory;
  final double progressPercentage; // 0.0 to 1.0 for in-progress sets
  final DateTime? lastReviewDate;
  
  // SM-2 algorithm specific fields
  final int repetitionCount; // n in the algorithm
  final double easinessFactor; // EF in the algorithm
  final int interval; // I in the algorithm (days)
  final DateTime? nextReviewDate;

  const VerseSet({
    required this.id,
    required this.surahId,
    required this.startVerse,
    required this.endVerse,
    this.status = MemorizationStatus.notStarted,
    this.reviewHistory = const [],
    this.progressPercentage = 0.0,
    this.lastReviewDate,
    this.repetitionCount = 0,
    this.easinessFactor = 2.5,
    this.interval = 1,
    this.nextReviewDate,
  });

  /// The number of verses in this set
  int get verseCount => endVerse - startVerse + 1;

  /// The verse range as a formatted string
  String get rangeText => '$startVerse-$endVerse';

  /// The number of times this set has been reviewed
  int get reviewCount => reviewHistory.length;

  /// The average quality of reviews (0.0 to 1.0)
  double get averageQuality {
    if (reviewHistory.isEmpty) return 0.0;
    double sum = 0.0;
    for (var review in reviewHistory) {
      sum += review.quality;
    }
    return sum / reviewHistory.length;
  }

  /// Calculate the next interval based on SM-2 algorithm
  int calculateNextInterval(double quality) {
    // Convert quality from 0.0-1.0 to 0-5 scale for SM-2
    final sm2Quality = (quality * 5).round();
    
    if (sm2Quality < 3) {
      // Failed recall - reset to 1 day
      return 1;
    }
    
    // Successful recall - apply SM-2 interval calculation
    int newRepetitionCount = repetitionCount + 1;
    
    if (newRepetitionCount == 1) {
      return 1; // First interval is always 1 day
    } else if (newRepetitionCount == 2) {
      return 6; // Second interval is always 6 days
    } else {
      // For subsequent intervals: I(n) = I(n-1) * EF
      return (interval * easinessFactor).ceil();
    }
  }
  
  /// Calculate the next easiness factor based on SM-2 algorithm
  double calculateNextEasinessFactor(double quality) {
    // Convert quality from 0.0-1.0 to 0-5 scale for SM-2
    final sm2Quality = (quality * 5).round();
    
    // Update EF using the SM-2 formula
    double newEF = easinessFactor + 0.1 - (5 - sm2Quality) * (0.08 + 0.02 * (5 - sm2Quality));
    
    // Ensure EF doesn't go below 1.3
    return newEF < 1.3 ? 1.3 : newEF;
  }

  /// Add a new review session to this verse set
  VerseSet addReview(double quality, {String notes = ''}) {
    final newReview = ReviewSession(
      date: DateTime.now(),
      quality: quality,
      notes: notes,
    );
    
    // Convert quality from 0.0-1.0 to 0-5 scale for SM-2
    final sm2Quality = (quality * 5).round();
    
    // Update repetition count based on recall success
    int newRepetitionCount = sm2Quality >= 3 ? repetitionCount + 1 : 0;
    
    // Calculate new easiness factor
    double newEF = calculateNextEasinessFactor(quality);
    
    // Calculate next interval
    int newInterval;
    if (sm2Quality < 3) {
      // Failed recall - reset
      newInterval = 1;
    } else if (newRepetitionCount == 1) {
      newInterval = 1;
    } else if (newRepetitionCount == 2) {
      newInterval = 6;
    } else {
      newInterval = (interval * newEF).ceil();
    }
    
    // Calculate next review date
    final now = DateTime.now();
    final nextDate = DateTime(now.year, now.month, now.day + newInterval);
    
    // FIXED: Modified the status determination for better progress tracking
    // Consider the set memorized if:
    // 1. Quality is excellent (>= 0.8) and we've reviewed it at least once, OR
    // 2. We've reviewed it repeatedly (repetitionCount >= 2) with at least decent quality (>= 0.6)
    MemorizationStatus newStatus;
    
    if ((quality >= 0.8 && reviewHistory.length >= 1) || 
        (newRepetitionCount >= 2 && quality >= 0.6)) {
      // Mark as memorized with good quality and multiple reviews
      print("Verse set ${id} marked as MEMORIZED: quality=${quality}, repCount=${newRepetitionCount}");
      newStatus = MemorizationStatus.memorized;
    } else if (reviewHistory.length > 0 || quality > 0.0) {
      // Mark as in progress if any review has been attempted
      print("Verse set ${id} marked as IN PROGRESS: quality=${quality}, reviews=${reviewHistory.length + 1}");
      newStatus = MemorizationStatus.inProgress;
    } else {
      print("Verse set ${id} remains NOT STARTED: quality=${quality}");
      newStatus = MemorizationStatus.notStarted;
    }

    return copyWith(
      status: newStatus,
      progressPercentage: quality,
      lastReviewDate: now,
      reviewHistory: [...reviewHistory, newReview],
      repetitionCount: newRepetitionCount,
      easinessFactor: newEF,
      interval: newInterval,
      nextReviewDate: nextDate,
    );
  }

  /// Create a copy of this verse set with updated fields
  VerseSet copyWith({
    String? id,
    int? surahId,
    int? startVerse,
    int? endVerse,
    MemorizationStatus? status,
    List<ReviewSession>? reviewHistory,
    double? progressPercentage,
    DateTime? lastReviewDate,
    int? repetitionCount,
    double? easinessFactor,
    int? interval,
    DateTime? nextReviewDate,
  }) {
    return VerseSet(
      id: id ?? this.id,
      surahId: surahId ?? this.surahId,
      startVerse: startVerse ?? this.startVerse,
      endVerse: endVerse ?? this.endVerse,
      status: status ?? this.status,
      reviewHistory: reviewHistory ?? this.reviewHistory,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      lastReviewDate: lastReviewDate ?? this.lastReviewDate,
      repetitionCount: repetitionCount ?? this.repetitionCount,
      easinessFactor: easinessFactor ?? this.easinessFactor,
      interval: interval ?? this.interval,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
    );
  }

  /// Convert the verse set to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'surahId': surahId,
      'startVerse': startVerse,
      'endVerse': endVerse,
      'status': status.index,
      'reviewHistory': reviewHistory.map((review) => review.toJson()).toList(),
      'progressPercentage': progressPercentage,
      'lastReviewDate': lastReviewDate?.toIso8601String(),
      'repetitionCount': repetitionCount,
      'easinessFactor': easinessFactor,
      'interval': interval,
      'nextReviewDate': nextReviewDate?.toIso8601String(),
    };
  }

  /// Create a verse set from a JSON map
  factory VerseSet.fromJson(Map<String, dynamic> json) {
    return VerseSet(
      id: json['id'],
      surahId: json['surahId'],
      startVerse: json['startVerse'],
      endVerse: json['endVerse'],
      status: MemorizationStatus.values[json['status']],
      reviewHistory: (json['reviewHistory'] as List?)
          ?.map((e) => ReviewSession.fromJson(e))
          .toList() ?? [],
      progressPercentage: json['progressPercentage'] ?? 0.0,
      lastReviewDate: json['lastReviewDate'] != null
          ? DateTime.parse(json['lastReviewDate'])
          : null,
      repetitionCount: json['repetitionCount'] ?? 0,
      easinessFactor: json['easinessFactor'] ?? 2.5,
      interval: json['interval'] ?? 1,
      nextReviewDate: json['nextReviewDate'] != null
          ? DateTime.parse(json['nextReviewDate'])
          : null,
    );
  }

  /// Create a new verse set with default values
  factory VerseSet.create({
    required int surahId,
    required int startVerse,
    required int endVerse,
  }) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    
    return VerseSet(
      id: '$surahId:$startVerse-$endVerse',
      surahId: surahId,
      startVerse: startVerse,
      endVerse: endVerse,
      repetitionCount: 0,
      easinessFactor: 2.5,
      interval: 1,
      nextReviewDate: tomorrow,
    );
  }
}
