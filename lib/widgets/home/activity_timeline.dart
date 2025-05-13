import 'package:flutter/material.dart';
import 'package:kottab/config/app_colors.dart';
import 'package:kottab/widgets/shared/see_all_button.dart';

class ActivityTimeline extends StatelessWidget {
  final List<ActivityItem> activities;
  final VoidCallback? onViewAll;

  const ActivityTimeline({
    super.key,
    required this.activities,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with "See All" button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'النشاط الأخير',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SeeAllButton(onPressed: onViewAll),
            ],
          ),

          const SizedBox(height: 16),

          // Activity items
          ...activities.map((activity) => _buildActivityItem(context, activity)).toList(),
        ],
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, ActivityItem activity) {
    // Set colors based on activity type
    Color iconBgColor;
    Color iconColor;

    switch (activity.type) {
      case ActivityType.memorization:
        iconBgColor = AppColors.primaryLight;
        iconColor = AppColors.primary;
        break;
      case ActivityType.review:
        iconBgColor = AppColors.secondaryLight;
        iconColor = AppColors.secondary;
        break;
      case ActivityType.challenge:
        iconBgColor = AppColors.tertiaryLight;
        iconColor = AppColors.tertiary;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  activity.icon,
                  color: iconColor,
                  size: 16,
                ),
              ),
              Container(
                width: 2,
                height: 40,
                color: Colors.grey.shade200,
              ),
            ],
          ),

          const SizedBox(width: 12),

          // Activity content
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
                  // Title and time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getActivityTypeText(activity.type) + ' ' + activity.surah + ' ' + activity.verseRange,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        activity.timeAgo,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Description
                  Text(
                    activity.description,
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

  String _getActivityTypeText(ActivityType type) {
    switch (type) {
      case ActivityType.memorization:
        return 'حفظ';
      case ActivityType.review:
        return 'مراجعة';
      case ActivityType.challenge:
        return 'تحدي';
    }
  }
}

enum ActivityType {
  memorization,
  review,
  challenge,
}

class ActivityItem {
  final ActivityType type;
  final String surah;
  final String verseRange;
  final String description;
  final String timeAgo;
  final IconData icon;

  const ActivityItem({
    required this.type,
    required this.surah,
    required this.verseRange,
    required this.description,
    required this.timeAgo,
    required this.icon,
  });
}
