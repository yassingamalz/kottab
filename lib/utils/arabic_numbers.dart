/// Utility class for handling Arabic numbers
class ArabicNumbers {
  /// Convert Latin (Western) digits to Arabic digits
  static String toArabicDigits(int number) {
    final arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((digit) => 
      int.tryParse(digit) != null ? arabicDigits[int.parse(digit)] : digit
    ).join('');
  }
  
  /// Format a number as a percentage with Arabic digits
  static String formatPercentage(double percentage) {
    // Ensure percentage is non-negative
    percentage = percentage.abs();
    
    // Multiply by 100 to convert to percentage
    final percentValue = percentage * 100;
    
    // Format with appropriate precision
    String formattedValue;
    if (percentValue < 0.1) {
      formattedValue = percentValue.toStringAsFixed(2); // Show more decimals for very small values
    } else if (percentValue < 1) {
      formattedValue = percentValue.toStringAsFixed(1); // Show one decimal for small values
    } else {
      formattedValue = percentValue.toStringAsFixed(0); // No decimals for larger values
    }
    
    // Replace with Arabic digits and add % sign
    return toArabicDigits(int.parse(formattedValue.split('.')[0])) + 
           (formattedValue.contains('.') ? '.' + toArabicDigits(int.parse(formattedValue.split('.')[1])) : '') + 
           '٪';
  }
  
  /// Format verse count with appropriate Arabic term
  static String formatVerseCount(int count) {
    return '${toArabicDigits(count)} آية';
  }
  
  /// Format day count
  static String formatDayCount(int count) {
    return toArabicDigits(count);
  }
}
