import 'package:flutter/material.dart';
import 'package:kottab/config/app_colors.dart';
import 'package:kottab/utils/arabic_numbers.dart';

class TodayFocus extends StatelessWidget {
  final List<FocusTaskData> tasks;
  final VoidCallback? onContinue;

  const TodayFocus({
    super.key,
    required this.tasks,
    this.onContinue,
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
          // Header with target info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تركيز اليوم',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time,
                      color: AppColors.primary,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '٢٠ آية',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Task cards
          ...tasks.map((task) => _buildTaskCard(context, task)).toList(),

          const SizedBox(height: 16),

          // Continue button
          ElevatedButton(
            onPressed: onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.bolt, size: 16),
                const SizedBox(width: 8),
                Text(
                  'متابعة الحفظ',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, FocusTaskData task) {
    Color borderColor;
    Color progressColor;
    Color iconBgColor;
    Color iconColor;
    IconData icon;

    // Set colors and icons based on task type
    switch (task.type) {
      case TaskType.newMemorization:
        borderColor = AppColors.primaryLight;
        progressColor = AppColors.primary;
        iconBgColor = AppColors.primaryLight;
        iconColor = AppColors.primary;
        icon = Icons.bolt;
        break;
      case TaskType.recentReview:
        borderColor = AppColors.secondaryLight;
        progressColor = AppColors.secondary;
        iconBgColor = AppColors.secondaryLight;
        iconColor = AppColors.secondary;
        icon = Icons.refresh;
        break;
      case TaskType.oldReview:
        borderColor = AppColors.tertiaryLight;
        progressColor = AppColors.tertiary;
        iconBgColor = AppColors.tertiaryLight;
        iconColor = AppColors.tertiary;
        icon = Icons.replay;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Task header with completion status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // Status indicator
              task.isCompleted
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'تم إكماله',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Text(
                      '${ArabicNumbers.toArabicDigits(task.completedVerses)}/${ArabicNumbers.toArabicDigits(task.totalVerses)} آية',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
            ],
          ),

          const SizedBox(height: 12),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: task.progress,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

enum TaskType {
  newMemorization,
  recentReview,
  oldReview,
}

class FocusTaskData {
  final String title;
  final TaskType type;
  final int completedVerses;
  final int totalVerses;
  final double progress;
  final bool isCompleted;

  const FocusTaskData({
    required this.title,
    required this.type,
    required this.completedVerses,
    required this.totalVerses,
    required this.progress,
    this.isCompleted = false,
  });
}
