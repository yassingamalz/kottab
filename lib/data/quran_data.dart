import 'package:kottab/models/surah_model.dart';

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
      const Surah(
        id: 3,
        name: "Aal-E-Imran",
        arabicName: "آل عمران",
        verseCount: 200,
      ),
      const Surah(
        id: 4,
        name: "An-Nisa",
        arabicName: "النساء",
        verseCount: 176,
      ),
      const Surah(
        id: 5,
        name: "Al-Ma'idah",
        arabicName: "المائدة",
        verseCount: 120,
      ),
      const Surah(
        id: 6,
        name: "Al-An'am",
        arabicName: "الأنعام",
        verseCount: 165,
      ),
      const Surah(
        id: 7,
        name: "Al-A'raf",
        arabicName: "الأعراف",
        verseCount: 206,
      ),
      const Surah(
        id: 8,
        name: "Al-Anfal",
        arabicName: "الأنفال",
        verseCount: 75,
      ),
      const Surah(
        id: 9,
        name: "At-Tawbah",
        arabicName: "التوبة",
        verseCount: 129,
      ),
      const Surah(
        id: 10,
        name: "Yunus",
        arabicName: "يونس",
        verseCount: 109,
      ),
      // ... Additional surahs would be included here
      // For brevity, we're only including the first 10
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

  /// Generate default verse sets for a surah
  static List<Map<String, dynamic>> generateDefaultSets(int surahId) {
    final surah = getSurahById(surahId);
    final setSize = getRecommendedSetSize(surahId);
    final List<Map<String, dynamic>> sets = [];

    int startVerse = 1;
    while (startVerse <= surah.verseCount) {
      int endVerse = startVerse + setSize - 1;
      if (endVerse > surah.verseCount) {
        endVerse = surah.verseCount;
      }

      sets.add({
        'id': '$surahId:$startVerse-$endVerse',
        'surahId': surahId,
        'startVerse': startVerse,
        'endVerse': endVerse,
        'status': 0, // MemorizationStatus.notStarted
      });

      startVerse = endVerse + 1;
    }

    return sets;
  }
}