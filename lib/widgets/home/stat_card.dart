import 'package:flutter/material.dart';
import 'package:kottab/config/app_colors.dart';
import 'package:kottab/utils/arabic_numbers.dart';

import '../../config/app_theme.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String suffix;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final double progress;
  final Color progressColor;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.suffix,
    required this.description,
    required this.icon,
    required this.progress,
    this.iconColor = AppColors.primary,
    this.bgColor = AppColors.primaryLight,
    this.progressColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row with icon
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Value with suffix
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    suffix,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
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

          // Progress indicator circle at top right
          Positioned(
            top: 0,
            right: 0,
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade100,
                color: progressColor,
                strokeWidth: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}