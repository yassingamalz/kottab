import 'package:kottab/models/verse_set_model.dart';

/// Model representing a Surah (chapter) of the Quran
class Surah {
  final int id;
  final String name;
  final String arabicName;
  final int verseCount;
  final List<VerseSet> verseSets;

  const Surah({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.verseCount,
    this.verseSets = const [],
  });

  /// Calculate the memorization progress of this Surah
  double get memorizedPercentage {
    if (verseSets.isEmpty) return 0.0;

    int memorizedVerses = 0;
    for (var set in verseSets) {
      if (set.status == MemorizationStatus.memorized) {
        memorizedVerses += set.verseCount;
      } else if (set.status == MemorizationStatus.inProgress) {
        // Count partial progress for in-progress sets
        memorizedVerses += (set.verseCount * set.progressPercentage).round();
      }
    }

    return memorizedVerses / verseCount;
  }

  /// Get the total number of memorized verses in this Surah
  int get memorizedVerseCount {
    int count = 0;
    for (var set in verseSets) {
      if (set.status == MemorizationStatus.memorized) {
        count += set.verseCount;
      }
    }
    return count;
  }

  /// Create a copy of this Surah with updated fields
  Surah copyWith({
    int? id,
    String? name,
    String? arabicName,
    int? verseCount,
    List<VerseSet>? verseSets,
  }) {
    return Surah(
      id: id ?? this.id,
      name: name ?? this.name,
      arabicName: arabicName ?? this.arabicName,
      verseCount: verseCount ?? this.verseCount,
      verseSets: verseSets ?? this.verseSets,
    );
  }

  /// Convert the Surah to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'arabicName': arabicName,
      'verseCount': verseCount,
      'verseSets': verseSets.map((set) => set.toJson()).toList(),
    };
  }

  /// Create a Surah from a JSON map
  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      id: json['id'],
      name: json['name'],
      arabicName: json['arabicName'],
      verseCount: json['verseCount'],
      verseSets: (json['verseSets'] as List?)
          ?.map((e) => VerseSet.fromJson(e))
          .toList() ?? [],
    );
  }
}