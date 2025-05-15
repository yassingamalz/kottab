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
      const Surah(
        id: 11,
        name: "Hud",
        arabicName: "هود",
        verseCount: 123,
      ),
      const Surah(
        id: 12,
        name: "Yusuf",
        arabicName: "يوسف",
        verseCount: 111,
      ),
      const Surah(
        id: 13,
        name: "Ar-Ra'd",
        arabicName: "الرعد",
        verseCount: 43,
      ),
      const Surah(
        id: 14,
        name: "Ibrahim",
        arabicName: "إبراهيم",
        verseCount: 52,
      ),
      const Surah(
        id: 15,
        name: "Al-Hijr",
        arabicName: "الحجر",
        verseCount: 99,
      ),
      const Surah(
        id: 16,
        name: "An-Nahl",
        arabicName: "النحل",
        verseCount: 128,
      ),
      const Surah(
        id: 17,
        name: "Al-Isra",
        arabicName: "الإسراء",
        verseCount: 111,
      ),
      const Surah(
        id: 18,
        name: "Al-Kahf",
        arabicName: "الكهف",
        verseCount: 110,
      ),
      const Surah(
        id: 19,
        name: "Maryam",
        arabicName: "مريم",
        verseCount: 98,
      ),
      const Surah(
        id: 20,
        name: "Ta-Ha",
        arabicName: "طه",
        verseCount: 135,
      ),
      const Surah(
        id: 21,
        name: "Al-Anbiya",
        arabicName: "الأنبياء",
        verseCount: 112,
      ),
      const Surah(
        id: 22,
        name: "Al-Hajj",
        arabicName: "الحج",
        verseCount: 78,
      ),
      const Surah(
        id: 23,
        name: "Al-Mu'minun",
        arabicName: "المؤمنون",
        verseCount: 118,
      ),
      const Surah(
        id: 24,
        name: "An-Nur",
        arabicName: "النور",
        verseCount: 64,
      ),
      const Surah(
        id: 25,
        name: "Al-Furqan",
        arabicName: "الفرقان",
        verseCount: 77,
      ),
      const Surah(
        id: 26,
        name: "Ash-Shu'ara",
        arabicName: "الشعراء",
        verseCount: 227,
      ),
      const Surah(
        id: 27,
        name: "An-Naml",
        arabicName: "النمل",
        verseCount: 93,
      ),
      const Surah(
        id: 28,
        name: "Al-Qasas",
        arabicName: "القصص",
        verseCount: 88,
      ),
      const Surah(
        id: 29,
        name: "Al-Ankabut",
        arabicName: "العنكبوت",
        verseCount: 69,
      ),
      const Surah(
        id: 30,
        name: "Ar-Rum",
        arabicName: "الروم",
        verseCount: 60,
      ),
      const Surah(
        id: 31,
        name: "Luqman",
        arabicName: "لقمان",
        verseCount: 34,
      ),
      const Surah(
        id: 32,
        name: "As-Sajdah",
        arabicName: "السجدة",
        verseCount: 30,
      ),
      const Surah(
        id: 33,
        name: "Al-Ahzab",
        arabicName: "الأحزاب",
        verseCount: 73,
      ),
      const Surah(
        id: 34,
        name: "Saba",
        arabicName: "سبأ",
        verseCount: 54,
      ),
      const Surah(
        id: 35,
        name: "Fatir",
        arabicName: "فاطر",
        verseCount: 45,
      ),
      const Surah(
        id: 36,
        name: "Ya-Sin",
        arabicName: "يس",
        verseCount: 83,
      ),
      const Surah(
        id: 37,
        name: "As-Saffat",
        arabicName: "الصافات",
        verseCount: 182,
      ),
      const Surah(
        id: 38,
        name: "Sad",
        arabicName: "ص",
        verseCount: 88,
      ),
      const Surah(
        id: 39,
        name: "Az-Zumar",
        arabicName: "الزمر",
        verseCount: 75,
      ),
      const Surah(
        id: 40,
        name: "Ghafir",
        arabicName: "غافر",
        verseCount: 85,
      ),
      const Surah(
        id: 41,
        name: "Fussilat",
        arabicName: "فصلت",
        verseCount: 54,
      ),
      const Surah(
        id: 42,
        name: "Ash-Shura",
        arabicName: "الشورى",
        verseCount: 53,
      ),
      const Surah(
        id: 43,
        name: "Az-Zukhruf",
        arabicName: "الزخرف",
        verseCount: 89,
      ),
      const Surah(
        id: 44,
        name: "Ad-Dukhan",
        arabicName: "الدخان",
        verseCount: 59,
      ),
      const Surah(
        id: 45,
        name: "Al-Jathiyah",
        arabicName: "الجاثية",
        verseCount: 37,
      ),
      const Surah(
        id: 46,
        name: "Al-Ahqaf",
        arabicName: "الأحقاف",
        verseCount: 35,
      ),
      const Surah(
        id: 47,
        name: "Muhammad",
        arabicName: "محمد",
        verseCount: 38,
      ),
      const Surah(
        id: 48,
        name: "Al-Fath",
        arabicName: "الفتح",
        verseCount: 29,
      ),
      const Surah(
        id: 49,
        name: "Al-Hujurat",
        arabicName: "الحجرات",
        verseCount: 18,
      ),
      const Surah(
        id: 50,
        name: "Qaf",
        arabicName: "ق",
        verseCount: 45,
      ),
      const Surah(
        id: 51,
        name: "Adh-Dhariyat",
        arabicName: "الذاريات",
        verseCount: 60,
      ),
      const Surah(
        id: 52,
        name: "At-Tur",
        arabicName: "الطور",
        verseCount: 49,
      ),
      const Surah(
        id: 53,
        name: "An-Najm",
        arabicName: "النجم",
        verseCount: 62,
      ),
      const Surah(
        id: 54,
        name: "Al-Qamar",
        arabicName: "القمر",
        verseCount: 55,
      ),
      const Surah(
        id: 55,
        name: "Ar-Rahman",
        arabicName: "الرحمن",
        verseCount: 78,
      ),
      const Surah(
        id: 56,
        name: "Al-Waqi'ah",
        arabicName: "الواقعة",
        verseCount: 96,
      ),
      const Surah(
        id: 57,
        name: "Al-Hadid",
        arabicName: "الحديد",
        verseCount: 29,
      ),
      const Surah(
        id: 58,
        name: "Al-Mujadila",
        arabicName: "المجادلة",
        verseCount: 22,
      ),
      const Surah(
        id: 59,
        name: "Al-Hashr",
        arabicName: "الحشر",
        verseCount: 24,
      ),
      const Surah(
        id: 60,
        name: "Al-Mumtahanah",
        arabicName: "الممتحنة",
        verseCount: 13,
      ),
      const Surah(
        id: 61,
        name: "As-Saf",
        arabicName: "الصف",
        verseCount: 14,
      ),
      const Surah(
        id: 62,
        name: "Al-Jumu'ah",
        arabicName: "الجمعة",
        verseCount: 11,
      ),
      const Surah(
        id: 63,
        name: "Al-Munafiqun",
        arabicName: "المنافقون",
        verseCount: 11,
      ),
      const Surah(
        id: 64,
        name: "At-Taghabun",
        arabicName: "التغابن",
        verseCount: 18,
      ),
      const Surah(
        id: 65,
        name: "At-Talaq",
        arabicName: "الطلاق",
        verseCount: 12,
      ),
      const Surah(
        id: 66,
        name: "At-Tahrim",
        arabicName: "التحريم",
        verseCount: 12,
      ),
      const Surah(
        id: 67,
        name: "Al-Mulk",
        arabicName: "الملك",
        verseCount: 30,
      ),
      const Surah(
        id: 68,
        name: "Al-Qalam",
        arabicName: "القلم",
        verseCount: 52,
      ),
      const Surah(
        id: 69,
        name: "Al-Haqqah",
        arabicName: "الحاقة",
        verseCount: 52,
      ),
      const Surah(
        id: 70,
        name: "Al-Ma'arij",
        arabicName: "المعارج",
        verseCount: 44,
      ),
      const Surah(
        id: 71,
        name: "Nuh",
        arabicName: "نوح",
        verseCount: 28,
      ),
      const Surah(
        id: 72,
        name: "Al-Jinn",
        arabicName: "الجن",
        verseCount: 28,
      ),
      const Surah(
        id: 73,
        name: "Al-Muzzammil",
        arabicName: "المزمل",
        verseCount: 20,
      ),
      const Surah(
        id: 74,
        name: "Al-Muddathir",
        arabicName: "المدثر",
        verseCount: 56,
      ),
      const Surah(
        id: 75,
        name: "Al-Qiyamah",
        arabicName: "القيامة",
        verseCount: 40,
      ),
      const Surah(
        id: 76,
        name: "Al-Insan",
        arabicName: "الإنسان",
        verseCount: 31,
      ),
      const Surah(
        id: 77,
        name: "Al-Mursalat",
        arabicName: "المرسلات",
        verseCount: 50,
      ),
      const Surah(
        id: 78,
        name: "An-Naba",
        arabicName: "النبأ",
        verseCount: 40,
      ),
      const Surah(
        id: 79,
        name: "An-Nazi'at",
        arabicName: "النازعات",
        verseCount: 46,
      ),
      const Surah(
        id: 80,
        name: "Abasa",
        arabicName: "عبس",
        verseCount: 42,
      ),
      const Surah(
        id: 81,
        name: "At-Takwir",
        arabicName: "التكوير",
        verseCount: 29,
      ),
      const Surah(
        id: 82,
        name: "Al-Infitar",
        arabicName: "الإنفطار",
        verseCount: 19,
      ),
      const Surah(
        id: 83,
        name: "Al-Mutaffifin",
        arabicName: "المطففين",
        verseCount: 36,
      ),
      const Surah(
        id: 84,
        name: "Al-Inshiqaq",
        arabicName: "الإنشقاق",
        verseCount: 25,
      ),
      const Surah(
        id: 85,
        name: "Al-Buruj",
        arabicName: "البروج",
        verseCount: 22,
      ),
      const Surah(
        id: 86,
        name: "At-Tariq",
        arabicName: "الطارق",
        verseCount: 17,
      ),
      const Surah(
        id: 87,
        name: "Al-A'la",
        arabicName: "الأعلى",
        verseCount: 19,
      ),
      const Surah(
        id: 88,
        name: "Al-Ghashiyah",
        arabicName: "الغاشية",
        verseCount: 26,
      ),
      const Surah(
        id: 89,
        name: "Al-Fajr",
        arabicName: "الفجر",
        verseCount: 30,
      ),
      const Surah(
        id: 90,
        name: "Al-Balad",
        arabicName: "البلد",
        verseCount: 20,
      ),
      const Surah(
        id: 91,
        name: "Ash-Shams",
        arabicName: "الشمس",
        verseCount: 15,
      ),
      const Surah(
        id: 92,
        name: "Al-Lail",
        arabicName: "الليل",
        verseCount: 21,
      ),
      const Surah(
        id: 93,
        name: "Ad-Duha",
        arabicName: "الضحى",
        verseCount: 11,
      ),
      const Surah(
        id: 94,
        name: "Ash-Sharh",
        arabicName: "الشرح",
        verseCount: 8,
      ),
      const Surah(
        id: 95,
        name: "At-Tin",
        arabicName: "التين",
        verseCount: 8,
      ),
      const Surah(
        id: 96,
        name: "Al-Alaq",
        arabicName: "العلق",
        verseCount: 19,
      ),
      const Surah(
        id: 97,
        name: "Al-Qadr",
        arabicName: "القدر",
        verseCount: 5,
      ),
      const Surah(
        id: 98,
        name: "Al-Bayyinah",
        arabicName: "البينة",
        verseCount: 8,
      ),
      const Surah(
        id: 99,
        name: "Az-Zalzalah",
        arabicName: "الزلزلة",
        verseCount: 8,
      ),
      const Surah(
        id: 100,
        name: "Al-Adiyat",
        arabicName: "العاديات",
        verseCount: 11,
      ),
      const Surah(
        id: 101,
        name: "Al-Qari'ah",
        arabicName: "القارعة",
        verseCount: 11,
      ),
      const Surah(
        id: 102,
        name: "At-Takathur",
        arabicName: "التكاثر",
        verseCount: 8,
      ),
      const Surah(
        id: 103,
        name: "Al-Asr",
        arabicName: "العصر",
        verseCount: 3,
      ),
      const Surah(
        id: 104,
        name: "Al-Humazah",
        arabicName: "الهمزة",
        verseCount: 9,
      ),
      const Surah(
        id: 105,
        name: "Al-Fil",
        arabicName: "الفيل",
        verseCount: 5,
      ),
      const Surah(
        id: 106,
        name: "Quraish",
        arabicName: "قريش",
        verseCount: 4,
      ),
      const Surah(
        id: 107,
        name: "Al-Ma'un",
        arabicName: "الماعون",
        verseCount: 7,
      ),
      const Surah(
        id: 108,
        name: "Al-Kawthar",
        arabicName: "الكوثر",
        verseCount: 3,
      ),
      const Surah(
        id: 109,
        name: "Al-Kafirun",
        arabicName: "الكافرون",
        verseCount: 6,
      ),
      const Surah(
        id: 110,
        name: "An-Nasr",
        arabicName: "النصر",
        verseCount: 3,
      ),
      const Surah(
        id: 111,
        name: "Al-Masad",
        arabicName: "المسد",
        verseCount: 5,
      ),
      const Surah(
        id: 112,
        name: "Al-Ikhlas",
        arabicName: "الإخلاص",
        verseCount: 4,
      ),
      const Surah(
        id: 113,
        name: "Al-Falaq",
        arabicName: "الفلق",
        verseCount: 5,
      ),
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
