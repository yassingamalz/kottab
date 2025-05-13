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

          // Achievement items - now using a GridView for better spacing and alignment
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              return _buildAchievementItem(context, achievements[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementItem(BuildContext context, AchievementItem achievement) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icon with circle background
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            achievement.icon,
            color: AppColors.primary,
            size: 28,
          ),
        ),
        const SizedBox(height: 12),
        // Title text with fixed width
        SizedBox(
          width: 90,
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
