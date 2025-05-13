import 'package:flutter/material.dart';
import 'package:kottab/config/app_colors.dart';
import 'package:kottab/widgets/home/activity_timeline.dart';

class ActivityDetailScreen extends StatelessWidget {
  const ActivityDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data for activities
    final activities = [
      ActivityItem(
        type: ActivityType.memorization,
        surah: "البقرة",
        verseRange: "51-60",
        description: "أكملت حفظ 10 آيات جديدة",
        timeAgo: "منذ 30 دقيقة",
        icon: Icons.bolt,
      ),
      ActivityItem(
        type: ActivityType.review,
        surah: "البقرة",
        verseRange: "41-50",
        description: "راجعت 10 آيات بنجاح",
        timeAgo: "منذ ساعة",
        icon: Icons.refresh,
      ),
      ActivityItem(
        type: ActivityType.challenge,
        surah: "الفاتحة",
        verseRange: "1-7",
        description: "أكملت تحدي المراجعة اليومي",
        timeAgo: "منذ يوم",
        icon: Icons.emoji_events,
      ),
      ActivityItem(
        type: ActivityType.memorization,
        surah: "آل عمران",
        verseRange: "1-10",
        description: "بدأت حفظ آيات جديدة",
        timeAgo: "منذ 3 أيام",
        icon: Icons.bolt,
      ),
      ActivityItem(
        type: ActivityType.review,
        surah: "البقرة",
        verseRange: "30-40",
        description: "راجعت 10 آيات بنجاح",
        timeAgo: "منذ 4 أيام",
        icon: Icons.refresh,
      ),
      ActivityItem(
        type: ActivityType.review,
        surah: "البقرة",
        verseRange: "20-29",
        description: "راجعت 10 آيات بنجاح",
        timeAgo: "منذ 5 أيام",
        icon: Icons.refresh,
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('سجل النشاط'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'جميع الأنشطة',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              Text(
                'سجل نشاطاتك في التطبيق',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Filter options
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildFilterChip(
                      context,
                      label: 'الكل',
                      isSelected: true,
                    ),
                    _buildFilterChip(
                      context,
                      label: 'حفظ',
                      isSelected: false,
                    ),
                    _buildFilterChip(
                      context,
                      label: 'مراجعة',
                      isSelected: false,
                    ),
                    _buildFilterChip(
                      context,
                      label: 'تحديات',
                      isSelected: false,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Activity list
              activities.map((activity) => _buildActivityItem(context, activity)).toList(),
            ],
          ),
        ),
      ),
    );
  }
  
  // Build filter chip
  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primaryLight,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (_) {
        // Would handle filter selection
      },
    );
  }
  
  // Build activity item
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
