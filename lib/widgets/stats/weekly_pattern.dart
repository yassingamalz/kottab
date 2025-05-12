import 'package:flutter/material.dart';
import 'package:kottab/config/app_colors.dart';
import 'package:kottab/utils/arabic_numbers.dart';
import 'package:kottab/utils/date_formatter.dart';

class WeeklyPattern extends StatelessWidget {
  final List<MapEntry<String, int>> weekData;
  final int maxValue;

  const WeeklyPattern({
    super.key,
    required this.weekData,
    required this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'أنماط المراجعة الأسبوعية',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: 16),

        // Weekly bars
        Column(
          children: weekData.map((entry) {
            final double percentage = maxValue > 0 ? entry.value / maxValue : 0.0;
            final String arabicDayName = _getArabicDayName(entry.key);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  // Day name
                  SizedBox(
                    width: 64,
                    child: Text(
                      arabicDayName,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),

                  // Progress bar
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: Colors.grey.shade100,
                        color: AppColors.primary,
                        minHeight: 8,
                      ),
                    ),
                  ),

                  // Value
                  SizedBox(
                    width: 32,
                    child: Text(
                      ArabicNumbers.toArabicDigits(entry.value),
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Convert English day name to Arabic
  String _getArabicDayName(String englishDay) {
    switch (englishDay) {
      case 'Monday':
        return 'الإثنين';
      case 'Tuesday':
        return 'الثلاثاء';
      case 'Wednesday':
        return 'الأربعاء';
      case 'Thursday':
        return 'الخميس';
      case 'Friday':
        return 'الجمعة';
      case 'Saturday':
        return 'السبت';
      case 'Sunday':
        return 'الأحد';
      default:
        return englishDay;
    }
  }
}