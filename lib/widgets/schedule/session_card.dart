import 'package:flutter/material.dart';
import 'package:kottab/config/app_colors.dart';
import 'package:kottab/providers/schedule_provider.dart';

import '../../config/app_theme.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/schedule_provider.dart' as ScheduleProvider;

class SessionCard extends StatelessWidget {
  final ScheduleProvider.ScheduledSession session;

  const SessionCard({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    // Configure colors and text based on session type
    late final Color bgColor;
    late final Color textColor;
    late final String typeText;
    late final IconData icon;

    switch (session.type) {
      case ScheduleProvider.SessionType.newMemorization:
        bgColor = AppColors.primaryLight;
        textColor = AppColors.primary;
        typeText = 'جديد';
        icon = Icons.bolt;
        break;
      case ScheduleProvider.SessionType.recentReview:
        bgColor = AppColors.blueLight;
        textColor = AppColors.blue;
        typeText = 'مراجعة 1';
        icon = Icons.refresh;
        break;
      case ScheduleProvider.SessionType.oldReview:
        bgColor = AppColors.purpleLight;
        textColor = AppColors.purple;
        typeText = 'مراجعة 2';
        icon = Icons.repeat;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Session type
          Text(
            typeText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 4),

          // Surah and verse range
          Text(
            'سورة ${session.surahId}: ${session.verseRange}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          // Completed indicator
          if (session.isCompleted)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Icon(
                Icons.check_circle,
                color: textColor,
                size: 14,
              ),
            ),
        ],
      ),
    );
  }
}