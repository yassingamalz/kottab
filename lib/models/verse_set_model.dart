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

  const VerseSet({
    required this.id,
    required this.surahId,
    required this.startVerse,
    required this.endVerse,
    this.status = MemorizationStatus.notStarted,
    this.reviewHistory = const [],
    this.progressPercentage = 0.0,
    this.lastReviewDate,
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

  /// Add a new review session to this verse set
  VerseSet addReview(double quality, {String notes = ''}) {
    final newReview = ReviewSession(
      date: DateTime.now(),
      quality: quality,
      notes: notes,
    );

    return copyWith(
      status: quality > 0.8 ? MemorizationStatus.memorized : MemorizationStatus.inProgress,
      progressPercentage: quality,
      lastReviewDate: DateTime.now(),
      reviewHistory: [...reviewHistory, newReview],
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
    );
  }

  /// Create a new verse set with default values
  factory VerseSet.create({
    required int surahId,
    required int startVerse,
    required int endVerse,
  }) {
    return VerseSet(
      id: '$surahId:$startVerse-$endVerse',
      surahId: surahId,
      startVerse: startVerse,
      endVerse: endVerse,
    );
  }
}