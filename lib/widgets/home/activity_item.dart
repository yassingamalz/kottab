import 'package:flutter/material.dart';
import 'package:kottab/config/app_colors.dart';
import 'package:kottab/utils/date_formatter.dart';

import '../../config/app_theme.dart';

enum ActivityType {
  memorization,
  review,
  challenge,
}

class ActivityItem extends StatelessWidget {
  final ActivityType type;
  final String surahName;
  final String verseRange;
  final String description;
  final DateTime time;

  const ActivityItem({
    super.key,
    required this.type,
    required this.surahName,
    required this.verseRange,
    required this.description,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    // Configure colors and icons based on type
    late final Color bgColor;
    late final IconData iconData;
    late final String actionText;

    switch (type) {
      case ActivityType.memorization:
        bgColor = AppColors.primary;
        iconData = Icons.bolt;
        actionText = 'حفظ';
        break;
      case ActivityType.review:
        bgColor = AppColors.blue;
        iconData = Icons.refresh;
        actionText = 'مراجعة';
        break;
      case ActivityType.challenge:
        bgColor = Colors.amber;
        iconData = Icons.emoji_events;
        actionText = 'تحدي';
        break;
    }

    final timeFormatted = DateFormatter.formatArabicTime(time);
    final dateFormatted = DateFormatter.getRelativeDateString(time);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline vertical line and icon
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  iconData,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              // Vertical timeline line
              Container(
                width: 2,
                height: 40,
                color: Colors.grey.shade200,
              ),
            ],
          ),

          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row with time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$actionText $surahName $verseRange',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            timeFormatted,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                          Text(
                            dateFormatted,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Description
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}