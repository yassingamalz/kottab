/// Utility class for handling Arabic numbers and text
class ArabicNumbers {
  /// Convert Western Arabic numerals to Eastern Arabic numerals
  static String toArabicDigits(dynamic number) {
    if (number == null) return '';

    final String strNumber = number.toString();
    final Map<String, String> arabicDigits = {
      '0': '٠',
      '1': '١',
      '2': '٢',
      '3': '٣',
      '4': '٤',
      '5': '٥',
      '6': '٦',
      '7': '٧',
      '8': '٨',
      '9': '٩',
    };

    return strNumber.split('')
        .map((digit) => arabicDigits[digit] ?? digit)
        .join('');
  }

  /// Format a percentage in Arabic style
  static String formatPercentage(double percentage) {
    final int roundedPercentage = (percentage * 100).round();
    return '${toArabicDigits(roundedPercentage)}%';
  }

  /// Format a fraction in Arabic style (e.g., 5/10)
  static String formatFraction(int numerator, int denominator) {
    return '${toArabicDigits(numerator)}/${toArabicDigits(denominator)}';
  }

  /// Format a verse count with آية suffix
  static String formatVerseCount(int count) {
    return '${toArabicDigits(count)} آية';
  }

  /// Format a day count with يوم suffix
  static String formatDayCount(int count) {
    return '${toArabicDigits(count)} يوم';
  }

  /// Get Arabic ordinal suffix
  static String getOrdinalSuffix(int number) {
    switch (number % 10) {
      case 1:
        return 'الأول';
      case 2:
        return 'الثاني';
      case 3:
        return 'الثالث';
      case 4:
        return 'الرابع';
      case 5:
        return 'الخامس';
      case 6:
        return 'السادس';
      case 7:
        return 'السابع';
      case 8:
        return 'الثامن';
      case 9:
        return 'التاسع';
      case 0:
        return 'العاشر';
      default:
        return '';
    }
  }
}