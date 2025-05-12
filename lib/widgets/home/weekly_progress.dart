import 'package:flutter/material.dart';
import 'package:kottab/config/app_colors.dart';
import 'package:kottab/utils/date_formatter.dart';

import '../../config/app_theme.dart';

class WeeklyProgress extends StatelessWidget {
  final List<DailyProgressData> weekData;

  const WeeklyProgress({
    super.key,
    required this.weekData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'تقدم الأسبوع',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to detailed weekly progress
                  },
                  child: Text(
                    'مشاهدة الكل',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Weekly progress rings
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              weekData.length,
                  (index) => DayProgressRing(
                data: weekData[index],
                isToday: index == weekData.length - 1, // Assuming the last day is today
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DailyProgressData {
  final String dayName;
  final double progress;
  final bool isToday;

  const DailyProgressData({
    required this.dayName,
    required this.progress,
    this.isToday = false,
  });
}

class DayProgressRing extends StatelessWidget {
  final DailyProgressData data;
  final bool isToday;

  const DayProgressRing({
    super.key,
    required this.data,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color ringColor = isToday ? AppColors.primary : Colors.blueGrey.shade300;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Progress ring
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                value: data.progress,
                backgroundColor: Colors.grey.shade100,
                color: ringColor,
                strokeWidth: 5,
              ),
            ),

            // Today indicator dot
            if (isToday)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          data.dayName.substring(0, 1), // First letter of day name
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}