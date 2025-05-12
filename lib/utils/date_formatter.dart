/// Utility class for formatting dates in Arabic context
class DateFormatter {
  /// Get the Arabic name of a weekday
  static String getArabicDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'الإثنين';
      case DateTime.tuesday:
        return 'الثلاثاء';
      case DateTime.wednesday:
        return 'الأربعاء';
      case DateTime.thursday:
        return 'الخميس';
      case DateTime.friday:
        return 'الجمعة';
      case DateTime.saturday:
        return 'السبت';
      case DateTime.sunday:
        return 'الأحد';
      default:
        return '';
    }
  }

  /// Get the Arabic name of a month
  static String getArabicMonthName(int month) {
    switch (month) {
      case DateTime.january:
        return 'يناير';
      case DateTime.february:
        return 'فبراير';
      case DateTime.march:
        return 'مارس';
      case DateTime.april:
        return 'أبريل';
      case DateTime.may:
        return 'مايو';
      case DateTime.june:
        return 'يونيو';
      case DateTime.july:
        return 'يوليو';
      case DateTime.august:
        return 'أغسطس';
      case DateTime.september:
        return 'سبتمبر';
      case DateTime.october:
        return 'أكتوبر';
      case DateTime.november:
        return 'نوفمبر';
      case DateTime.december:
        return 'ديسمبر';
      default:
        return '';
    }
  }

  /// Format a date in Arabic style (day, DD month)
  static String formatArabicDate(DateTime date) {
    final day = getArabicDayName(date.weekday);
    final month = getArabicMonthName(date.month);
    return '$day، ${date.day} $month';
  }

  /// Format a time in Arabic style (HH:MM)
  static String formatArabicTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Get relative date string (today, yesterday, etc)
  static String getRelativeDateString(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateDay = DateTime(date.year, date.month, date.day);

    if (dateDay == today) {
      return 'اليوم';
    } else if (dateDay == yesterday) {
      return 'أمس';
    } else if (today.difference(dateDay).inDays <= 7) {
      return 'قبل ${today.difference(dateDay).inDays} أيام';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}