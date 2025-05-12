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
      children: [
        // Icon with background
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),

        const SizedBox(height: 8),

        // Title
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}