import 'package:kottab/models/surah_model.dart';
import 'package:kottab/models/verse_set_model.dart';

/// A data provider class that contains static Quran data
class QuranData {
  /// Get all surahs of the Quran
  static List<Surah> getAllSurahs() {
    return [
      const Surah(
        id: 1,
        name: "Al-Fatihah",
        arabicName: "الفاتحة",
        verseCount: 7,
      ),
      const Surah(
        id: 2,
        name: "Al-Baqarah",
        arabicName: "البقرة",
        verseCount: 286,
      ),
      // ... (all other surahs - preserving the original list)
      const Surah(
        id: 114,
        name: "An-Nas",
        arabicName: "الناس",
        verseCount: 6,
      ),
    ];
  }

  /// Get a specific surah by ID
  static Surah getSurahById(int id) {
    return getAllSurahs().firstWhere(
          (surah) => surah.id == id,
      orElse: () => throw Exception('Surah with ID $id not found'),
    );
  }

  /// Get recommended verse set size for a specific surah
  static int getRecommendedSetSize(int surahId) {
    // Logic to determine appropriate set size based on surah
    // For short surahs, the whole surah might be one set
    // For longer surahs, 10 verses is a common recommendation
    final surah = getSurahById(surahId);

    if (surah.verseCount <= 10) {
      return surah.verseCount;
    } else if (surah.verseCount <= 50) {
      return 5;
    } else {
      return 10;
    }
  }

  /// Generate default verse sets for a surah with SM-2 parameters
  static List<Map<String, dynamic>> generateDefaultSets(int surahId) {
    final surah = getSurahById(surahId);
    final setSize = getRecommendedSetSize(surahId);
    final List<Map<String, dynamic>> sets = [];

    int startVerse = 1;
    while (startVerse <= surah.verseCount) {
      // Calculate end verse respecting the surah boundary
      int endVerse = startVerse + setSize - 1;
      if (endVerse > surah.verseCount) {
        endVerse = surah.verseCount;
      }

      // Create tomorrow's date for initial nextReviewDate
      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day + 1);

      sets.add({
        'id': '$surahId:$startVerse-$endVerse',
        'surahId': surahId,
        'startVerse': startVerse,
        'endVerse': endVerse,
        'status': 0, // MemorizationStatus.notStarted
        'repetitionCount': 0,
        'easinessFactor': 2.5,
        'interval': 1,
        'nextReviewDate': tomorrow.toIso8601String(),
      });

      startVerse = endVerse + 1;
    }

    return sets;
  }
}
