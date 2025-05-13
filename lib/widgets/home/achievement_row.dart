import 'package:flutter/material.dart';
import 'package:kottab/config/app_colors.dart';
import 'package:kottab/widgets/shared/see_all_button.dart';

class AchievementRow extends StatelessWidget {
  final List<AchievementItem> achievements;
  final VoidCallback? onViewAll;

  const AchievementRow({
    super.key,
    required this.achievements,
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
                'الإنجازات',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SeeAllButton(onPressed: onViewAll),
            ],
          ),

          const SizedBox(height: 16),

          // Achievement items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: achievements.map((achievement) => _buildAchievementItem(context, achievement)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementItem(BuildContext context, AchievementItem achievement) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            achievement.icon,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          child: Text(
            achievement.title,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class AchievementItem {
  final String title;
  final IconData icon;

  const AchievementItem({
    required this.title,
    required this.icon,
  });
}
