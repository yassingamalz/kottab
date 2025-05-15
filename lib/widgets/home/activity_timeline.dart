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
                  fontSize: 18, // Increased font size
                ),
              ),
              SeeAllButton(onPressed: onViewAll),
            ],
          ),

          const SizedBox(height: 18), // Increased spacing

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
      padding: const EdgeInsets.only(bottom: 18), // Increased spacing between items
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 36, // Increased size
                height: 36, // Increased size
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  activity.icon,
                  color: iconColor,
                  size: 18, // Increased size
                ),
              ),
              Container(
                width: 2,
                height: 40,
                color: Colors.grey.shade200,
              ),
            ],
          ),

          const SizedBox(width: 14), // Increased spacing

          // Activity content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14), // Increased padding
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
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14, // Increased font size
                        ),
                      ),
                      Text(
                        activity.timeAgo,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12, // Increased font size
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6), // Increased spacing

                  // Description
                  Text(
                    activity.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13, // Increased font size
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
