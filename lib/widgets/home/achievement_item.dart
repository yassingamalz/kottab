import 'package:flutter/material.dart';
import 'package:kottab/config/app_colors.dart';

class AchievementItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Color bgColor;

  const AchievementItem({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icon with background
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 28,
          ),
        ),

        const SizedBox(height: 12),

        // Title with fixed width to prevent overflow
        SizedBox(
          width: 90,
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
